# NL convergence failures in Templates

TODO:
- Mention alternatives:
  - Leakage: sensitivity to event grid (e.g. suppressing assert blocks!), or NL scale (HardCase1NLoadsLeakage failing)


----

The analysis is based on the three plant templates from

- https://github.com/lbl-srg/modelica-buildings/pull/4657: AWHP plant
- https://github.com/lbl-srg/modelica-buildings/pull/3167: chiller plant
- https://github.com/lbl-srg/modelica-buildings/pull/3364: boiler plant

The template validation models are simulated with `pla(linearized=false)` for all valid plant configurations using the scripts under `Buildings/Resources/Scripts/travis/templates`.

Two types of configuration fail.

1. AWHP plant: separate dedicated primary pumps (one for CHW, one for HW), primary-only or primary-secondary distribution (both failing). This fails with both OCT and Dymola (CVode solver).
2. Chiller plant: WSE with heat exchanger bypass valve, headered primary pumps, primary-only distribution. This fails with Dymola (CVode solver). (OCT cannot translate the chiller plant controller.)

---

## 1. AWHP plant template

Fatal NL solver failure at t = 22015.9 s.

```
Warning: Failed to solve nonlinear system using Newton solver.
  Time: 22015.93464026791
  Tag: simulation.nonlinear[1]
  The nonlinear solver stopped since:
   * Number of calls to nonlinear solver DymNL has reached or exceeded
     the maximum allowed number of function calls= 900
  Jacobian inverse norm estimate: 801468
  Condition number estimate: 1.26339e+06
  1-norm of the residual = 15.9088
  The estimates indicate that the Jacobian is close to singular, suggesting that there is no solution.

  Last value of the solution:
    pla.valIso.valHeaWatUniInlIso[1].port_b.p = 309039
    pla.pumPri.pumChiWat.valChe[3].dp = -2243.27
    pla.valIso.valHeaWatUniInlIso[3].port_b.p = 309039
    VHeaWat_flow.port_a.m_flow = 35.4285
    pla.pumPri.pumHeaWat.valChe[2].dp = 13640.9
    pla.valIso.port_bHeaWat.m_flow = -52.3398
    pla.valIso.port_aChiWat.m_flow = -0.00111231
    pla.port_aChiWat.m_flow = 4.08264E-05
  Last value of the residual:
    { -0.000218064, -0.000278686, -0.000101332, 8.24992E-05, -0.000277594,
      0.000579542, 15.9073, -2.91588E-05 }

SUNDIALS: CVODE CVode At t = 22015.9 repeated recoverable right-hand side function errors.
Integration terminated unsuccesfully at T = 22015.9
```

### Block at cause

`simulation.nonlinear[1]` stands out with the highest number of residuals and Jacobians evaluations per call.

```
 Tag                                            , Calls, Residues, Iterations, Jacobians
 initialization.nonlinear[3]                    :    11,     1225,       1225,       136
 simulation.nonlinear[1]                        :  6645,    45624,      45624,      9622
 simulation.nonlinear[2]                        :  6626,    19878,      13252,         0
 simulation.nonlinear[4]                        :  6626,    13385,      13385,      6626
 simulation.nonlinear[5]                        :  6626,    16059,      16059,      6626
```

The CHW loop (load side of the primary pump check valves) is idle for the whole run: CHW isolation valves closed, primary CHW pumps off.
There is no specific staging event triggering the solver failure.

### Iteration variables and residual equations

From `dsmodel.mof` (variables and equations of the idle CHW circuit are flagged with `<-- idle`):

```
simulation.nonlinear[1]:

Iteration variables                                    Residual equations (row order as printed in the log)
1  pla.valIso.valHeaWatUniInlIso[1].port_b.p           1  0 = junHeaWatSup.ports[1].m_flow - m_che(pumHeaWat.valChe[1].dp)
2  pla.pumPri.pumChiWat.valChe[3].dp         <-- idle  2  0 = junHeaWatSup.ports[3].m_flow - m_che(pumHeaWat.valChe[3].dp)
3  pla.valIso.valHeaWatUniInlIso[3].port_b.p           3  0 = pumPri.ports_bChiWat[1].m_flow + m_che(pumChiWat.valChe[1].dp)               <-- idle
4  VHeaWat_flow.port_a.m_flow                          4  0 = pumPri.ports_bChiWat[2].m_flow + m_che(pumChiWat.valChe[2].dp)               <-- idle
5  pla.pumPri.pumHeaWat.valChe[2].dp                   5  0 = junHeaWatRet.ports[2].m_flow + f_dp(valHeaWatUniInlIso[2].lin.dp, k, m_turb)
6  pla.valIso.port_bHeaWat.m_flow                      6  0 = junChiWatRet.ports[2].m_flow + f_dp(valChiWatUniInlIso[2].lin.dp, k, m_turb) <-- idle
7  pla.valIso.port_aChiWat.m_flow            <-- idle  7  0 = junChiWatBypSup.port_3.m_flow + f_dp(valChiWatMinByp.lin.dp, kVal, m_turb)   <-- idle
8  pla.port_aChiWat.m_flow                   <-- idle  8  0 = junHeaWatBypSup.port_3.m_flow + f_dp(valHeaWatMinByp.lin.dp, kVal, m_turb)
```

`m_che(dp)` is the check-valve characteristic (quintic hermite), `f_dp` is `Buildings.Fluid.BaseClasses.FlowModels.basicFlowFunction_dp`. All eight residuals are flow laws; the unit of every residual is kg/s.

### Topology of the idle CHW circuit

The pressure level is pinned on the HW loop with:

```mo
  Fluid.Sources.Boundary_pT bouHeaWat(
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal + 101325, ...)
```

The CHW loop is hydronically disconnected from the HW loop by

- the closed CHW isolation valves (HW return),
- the primary CHW pump check valves (HW supply) exposed to the counter pressure of the primary HW pumps.

The CHW loop absolute pressure level and the supply–return difference are algebraic quantities (no pressure state).
After tearing (`dsmodel.mof`, torn part, verbatim):

```
pipChiWat.dp := basicFlowFunction_m_flow(pla.port_aChiWat.m_flow, 0.2267, 21.51);
loaCoo.con.val.valEqu.dp := basicFlowFunction_m_flow(pla.port_aChiWat.m_flow, loaCoo.con.val.valEqu.k, loaCoo.con.val.valEqu.m_flow_turbulent);

pla.valIso.valChiWatUniInlIso[2].lin.dp := pla.pumPri.pumChiWat.pum[3].dpMachine
  -(pipChiWat.dp+pla.pumPri.pumChiWat.valChe[3].dp+loaCoo.con.val.valEqu.dp+pla.valIso.valHeaWatUniInlIso[2].port_b.p)
  +pla.valIso.valHeaWatUniInlIso[3].port_b.p;
pla.valIso.valChiWatUniInlIso[1].lin.dp := pla.valIso.valChiWatUniInlIso[2].lin.dp + valHeaWatUniInlIso[2].port_b.p - valHeaWatUniInlIso[1].port_b.p;
pla.valIso.valChiWatUniInlIso[3].lin.dp := pla.valIso.valChiWatUniInlIso[2].lin.dp + valHeaWatUniInlIso[2].port_b.p - valHeaWatUniInlIso[3].port_b.p;
pla.valIso.junChiWatRet.ports[1].m_flow := -basicFlowFunction_dp(valChiWatUniInlIso[1].lin.dp, valChiWatUniInlIso[1].lin.k, ...);
pla.valIso.junChiWatRet.ports[3].m_flow := -basicFlowFunction_dp(valChiWatUniInlIso[3].lin.dp, valChiWatUniInlIso[3].lin.k, ...);
pla.valIso.junChiWatRet.ports[2].m_flow := -(junChiWatRet.ports[1].m_flow + pla.valIso.port_aChiWat.m_flow + junChiWatRet.ports[3].m_flow);

pla.valChiWatMinByp.lin.dp := pipChiWat.dp + loaCoo.con.val.valEqu.dp;
pla.junChiWatBypSup.port_3.m_flow := pla.port_aChiWat.m_flow - pla.valIso.port_aChiWat.m_flow;
```

Rewritten with `m_load ≡ pla.port_aChiWat.m_flow` (plant CHW return flow), `m_ret ≡ pla.valIso.port_aChiWat.m_flow` (CHW return-header flow into the isolation valves), `p_i ≡ valHeaWatUniInlIso[i].port_b.p` (HP inlet nodes, HW-pressurized):

- **Supply–return difference** `Δp_loop = dp_load(m_load) + dp_pipe(m_load)` — the _inverse_ law of the closed load valve, evaluated at the CHW loop flow
- **Absolute level** `p_sup = p_3 + pum[3].dpMachine − valChe[3].dp` — set by CHW pump #3 check valve Δp
- **Isolation valve Δp** `dp_iso,i = p_sup − Δp_loop − p_i` — leakage flows
- Row 6: leak law of `valChiWatUniInlIso[2]` against the return-header mass balance: `f₁ + f₂ + f₃ − m_ret = 0`.
- Row 7: bypass law against the supply-header mass balance: `m_load − m_ret + f_byp(Δp_loop) = 0`.

**The two pressures in the block are not the floating ones.** The undetermined pressures are on the far side of the closed CHW valves, `junChiWatRet` and `junChiWatSup`, and they don't appear as pressures, but rather as `valChe[3].dp` and `R_load·m_load`.

The same block is used at every time step; it is well posed whenever any of the six connecting elements is open.
It degenerates only when the isolation valves are closed _and_ the pumps are off.

### Why Newton cannot converge?

#### a. The level is floating: column 2 of the Jacobian is numerically zero

`valChe[3].dp` fixes the loop's absolute pressure. It enters the residuals only through the six closed elements, each with a leakage slope.
For a closed valve `k = l·k_nom = l·ṁ_nom/√Δp_nom` and `m_flow_turbulent = δ·ṁ_nom` (`δ = deltaM = 0.02`), so `dp_turbulent = δ²·Δp_nom/l²` — 4e7 Pa here — and a closed valve is always inside the regularized band of `basicFlowFunction_dp`, where

```
g_closed = 1.40625·k²/m_turb = 1.40625 · l² · ṁ_nom / (δ·Δp_nom)
```

| element                                           | `l`  | `ṁ_nom` | `Δp_nom` | slope `g`       |
| ------------------------------------------------- | ---- | ------- | -------- | --------------- |
| `pumChiWat.valChe[1..3]` reverse (`k_min` branch) | 1e-3 | 23.9    | 1e4      | 1.68e-7 kg/s/Pa |
| `valChiWatUniInlIso[1..3]` closed                 | 1e-4 | 23.9    | 1e3      | 1.68e-8 kg/s/Pa |

So every entry of the `valChe[3].dp` column is ≤ 1.7e-7, while the row norms are 17–1200. After Dymola's row scaling the column is O(1e-9). That is the direction `d = e_{valChe[3].dp}` with `J·d ≈ 0`, and it is what the header numbers report:

- `cond / ‖J⁻¹‖ = 1.26339e6 / 801468 = 1.58 = ‖J‖₁`, which for an 8×8 matrix with unit row sums must lie in [1, 8]. Both estimates are therefore computed on the **row-scaled** matrix — scaling has already been applied and the singularity survives it.
- `‖J⁻¹‖₁ = 8.0e5` on a row-equilibrated matrix (healthy: O(1)–O(10)) means a unit step along some direction changes the scaled residual by ~1e-6.
- The sharper estimate printed after the scale lines, `Condition estimate of Jacobian matrix 8.349e8`, is constant to six digits across the whole stall while row 7's own norm swings by two decades (table in 3b). A singularity invariant to a 100× rescaling of one row is structural. The header value `1.26e6` is a cheap LU-based estimator and undershoots by ~660×; it is the number one reads in the error message, which is why the condition number "did not look that bad".

The consequence: Newton has no handle on the level. Over the last 24 Jacobian evaluations `valChe[3].dp` creeps from −2253.3 to −2243.6 Pa — about 10 Pa per solver call — toward its consistent value, which is 2.25 kPa away (in the accepted solutions of `HardCase1.mat` the loop sits at `valChe[3].dp = 1.4e-8 Pa`, `m_load = 4e-23 kg/s`: the true solution is the trivial one).

#### b. The supply–return difference is the inverse of a closed valve: rows 6 and 7 are steep, kinked, and parallel in `m_load`

With `x = m/m_turb`, `basicFlowFunction_m_flow` in its laminar band is `dp = (0.375 + …)·dp_turb·x`, so the closed load valve (`l = 1e-4`, `ṁ_nom = 71.7`, `Δp_nom = 3e4`, `k = 4.14e-5`, `m_turb = 1.434`) has

```
R_load = 0.375 · dp_turb / m_turb = 0.375 · δ·Δp_nom / (l² · ṁ_nom) = 3.14e8 Pa/(kg/s)
```

This is where the leakage parameter bites hardest: `R_load ∝ 1/l²`. Row 7 inherits it (`g_byp·R_load ∝ 1/l_load²`); in row 6 the `l`'s cancel (`3·g_iso·R_load ∝ l_iso²/l_load²`), which is why 15.8 is an O(10) number despite both factors being extreme.

A loop flow of 7.6e-5 kg/s — numerical zero next to the 52 kg/s HW flow in the same block — is back-substituted into a 24 kPa supply–return difference. Every loop equation then sees `m_load` through this one factor:

```
∂r6/∂m_load = 3 · g_iso · R_load             = 3 · 1.68e-8 · 3.14e8 = 15.8      (log: J_sum row 6 = 16.85 = 15.8 + 1 for m_ret)
∂r7/∂m_load = 1 + g_byp(Δp_loop) · R_load
   bypass in √ regime, Δp_loop = 24 kPa:  g_byp = k/(2√Δp) = 0.1405/(2·155) = 4.5e-4  →  1.4e5
   bypass in laminar band, |Δp_loop| < 14 Pa: g_byp = 1.40625·k²/m_turb = 0.0528   →  1.66e7
```

The bypass changes regime at `Δp_loop = dp_turb = 14 Pa`, i.e. at `m_load = 14 / 3.14e8 = 4.5e-8 kg/s`. Jacobian evaluations in the stall (excerpt), each paired with the iterate it was taken at:

```
 log line      m_load        m_ret   valChe3.dp    J_sum6      J_sum7
 1234995   7.6360e-05  -1.1155e-03    -2253.30   16.8491      142453
 1235096   4.4768e-07  -1.1148e-03    -2253.30   16.8479  1.86028e+06
 1235229   7.5899e-05  -1.1133e-03    -2252.72   16.8491      142884
 1235330  -1.3585e-08  -1.1127e-03    -2252.72   16.8479  1.48088e+07
 1235463   7.7745e-05  -1.1185e-03    -2250.87   16.8491      141178
 1235564   1.8318e-06  -1.1180e-03    -2250.87   16.8479      919661
 1235697   7.2012e-05  -1.1126e-03    -2250.26   16.8490      146689
 1235798  -3.8907e-06  -1.1118e-03    -2250.26   16.8480      631035
 1236149   7.7757e-05  -1.1327e-03    -2247.94   16.8492      141167
 1236330   5.6334e-07  -1.1312e-03    -2248.27   16.8479  1.65835e+06
 1237149   7.5932e-05  -1.1155e-03    -2246.02   16.8491      142853
 1237250   1.9226e-08  -1.1149e-03    -2246.02   16.8479  1.31978e+07
 1237617   7.2095e-05  -1.1119e-03    -2243.56   16.8491      146604
 1237718  -3.8078e-06  -1.1111e-03    -2243.56   16.8480      637866
```

`J_sum7 = 1.42e5` whenever `m_load ≈ 7.6e-5` and up to `1.48e7` when `m_load → 0` (at `m_load = −1.36e-8`, `Δp_loop = −4.3 Pa`, the laminar polynomial gives `1.26·k²/m_turb·R_load = 1.49e7`). The reconstruction holds to two digits at both ends. The residual values follow too: at `m_load = 7.2e-5`, `Δp_loop = 2.26e4 Pa`, the open bypass "should" carry `k·√Δp = 21.1 kg/s`, and the printed `r7 = 21.14`; the three isolation valves at `dp_iso ≈ −20.4 kPa` leak `3·1.68e-8·(−20356) = −1.03e-3`, against `m_ret = −1.112e-3`, giving `r6 = 8.6e-5` (printed `8.45e-5`).

**What rows 6 and 7 say, given the level Newton cannot move.** With `valChe[3].dp` frozen at −2.25 kPa, the isolation valves leak `m_ret ≈ −1.1e-3 kg/s` into the loop. Row 6 can balance that only with `Δp_loop ≈ −20 kPa`, i.e. `m_load ≈ +7e-5`; row 7 can balance it only with `f_byp(Δp_loop) ≈ 1.1e-3`, i.e. `m_load ≈ 0`. Two equations that are, after scaling, both ≈ `e_{m_load}` and disagree on its root by 1.4e-4 kg/s. The only variable that would reconcile them is the level, and its column is ~1e-9.

Finite-difference check from two consecutive iterates that differ only in `m_load` (log lines 1237599 → 1237621, `Δm_load = −2.53e-5`):

| row    | ∂r/∂m_load    | `J_sum`    | share of row norm | row's root in `m_load` |
| ------ | ------------- | ---------- | ----------------- | ---------------------- |
| 3      | 1.01e+01      | 242.7      | 0.04              | +7.7e-05               |
| 4      | −1.01e+01     | 243.8      | 0.04              | +7.5e-05               |
| **6**  | **−1.58e+01** | **16.85**  | **0.94**          | **+7.7e-05**           |
| **7**  | **1.62e+05**  | **146604** | **~1**            | **−5.8e-05**           |
| others | ≤ 25          | 107–1204   | ≤ 0.03            | —                      |

#### c. How the iteration actually stalls

Within one solver call `m_load` is driven from 7.6e-5 through zero (where the row-7 coefficient grows 100× and the Jacobian is re-evaluated), then walks back up in 15–25 % steps:

```
 iterate    m_load      |r|₁ printed   scaled norm   predicted / actual decrease
   −3      -3.81e-06       4.857         7.253e-05        —
   −2       8.80e-06       7.386         6.193e-05     0.158 / 0.146
   −1       2.06e-05      11.293         5.332e-05     0.058 / 0.139
  final     4.08e-05      15.909         4.096e-05     0.232 / 0.232
```

until the 900-call budget is spent. The next call starts again near `m_load ≈ 7.6e-5` because the level has moved only ~10 Pa. The integrator halves its step, re-calls, gets the same outcome, and eventually gives up.

Note the printed `1-norm of the residual` **grows** while the solver is converging. Dymola scales row _i_ by `J_sum_i + 1` and converges on the Euclidean norm of the scaled vector:

| row | `|r_i|` printed | `J_sum_i` | scaled |
|---|---|---|---|
| 6 | 5.795e-04 | 16.848 | **3.247e-05** |
| 7 | 15.9073 | 637866 | 2.494e-05 |
| 1–5, 8 | 3e-5 … 3e-4 | 107 … 1204 | 2e-7 … 9e-7 |

2-norm = 4.09594e-05 (log: `Scaled residual 4.095940326241184E-05`); 1-norm of the printed vector = 15.9089 (log: `15.9088`). The headline `15.9` is row 7 alone and is a _flow_ of 15.9 kg/s through the open bypass implied by a numerically-zero loop flow; in the solver's metric it is smaller than row 6. Neither the header condition number nor the printed residual is the right thing to read; `predicted relative decrease` and the row-scaled residual are.

### Fix: a pressure state on the loop

`Buildings.Templates.Components.Routing.Compliance` at the CHW supply junction — i.e. _inside_ the idle loop, on the load side of the check valves — `C = 1e-5 kg/Pa`:

```
port_a.p = p;
C * der(p) = port_a.m_flow;
```

With `comChiWatSup` (and `comHeaWatSup`) in `ValvesIsolation`, the same block becomes:

```
System simulation.nonlinear[1]:
The equation system depends on the following timevarying variables:
  ...
  pla.valIso.comChiWatSup.p            ← state
  pla.valIso.comHeaWatSup.p            ← state
  ...
Iteration variables:
  pla.pumPri.pumChiWat.valChe[1..3].dp
  pla.pumPri.pumHeaWat.valChe[1..3].dp
  pla.valIso.port_aChiWat.m_flow
  pla.port_aChiWat.m_flow

Residual equations:
  0 = pumChiWat.pum[i].dpMachine - (pumChiWat.valChe[i].dp + comChiWatSup.p) + valHeaWatUniInlIso[i].port_b.p     i = 1..3
  0 = junHeaWatRet.ports[2].m_flow + f_dp(valHeaWatUniInlIso[2].lin.dp, ...)
  0 = junChiWatRet.ports[i].m_flow + f_dp(valChiWatUniInlIso[i].lin.dp, ...)                                     i = 1..3
  0 = junChiWatBypSup.port_3.m_flow + f_dp(valChiWatMinByp.lin.dp, ...)

Torn part:
  pla.valIso.valChiWatUniInlIso[i].lin.dp := pla.valIso.comChiWatSup.p - pla.valChiWatMinByp.lin.dp - valHeaWatUniInlIso[i].port_b.p;
```

The level is now a known input at every residual evaluation, and the CHW check-valve Δp's are determined by _linear_ pressure-balance rows (coefficient 1) instead of by leakage slopes. Both node pressures `valHeaWatUniInlIso[1,3].port_b.p` leave the block; `VHeaWat_flow.port_a.m_flow` is evicted to its own scalar block. The `R_load·m_load` back-substitution is still there, but with the level pinned the loop equations are consistent and `m_load` converges to zero.

```
                              baseline              compliance
Continuous time states        89                    91
Nonlinear systems             {52, 43, 43, 3,3,3}   {45, 3, 43, 43, 3,3,3}
  after manipulation          { 8,  1,  1, 1,1,1}   { 8, 1,  1,  1, 1,1,1}

 Tag                        , Calls, Residues, Iterations, Jacobians
 initialization.nonlinear[1..6]:  1 call each, 2–9 residues      (baseline: init.nonlinear[3] 1225 residues, failed, |r|₁ = 299)
 simulation.nonlinear[1]    : 96022,   317424,     317424,     96155
 simulation.nonlinear[2]    : 96022,   250482,     250482,     96022

SUCCESSFUL simulation of ...HardCase1Compliance
```

Zero NL failures; 3.3 residuals and 1.0 Jacobians per call.

### Cost (NL debug logging off; the debug log itself inflates CPU 15–21× and non-uniformly)

| variant             | CPU (s) | accepted | rejected | f-evals | Jac  | NL conv. failures | outcome              |
| ------------------- | ------- | -------- | -------- | ------- | ---- | ----------------- | -------------------- |
| baseline            | 0.37    | 1263     | 72       | 1973    | 94   | 69                | **FAILED** @ 22015.9 |
| Leakage             | 3.39    | 15932    | 564      | 24309   | 1353 | 886               | OK                   |
| Linearized          | 3.48    | 16895    | 575      | 25737   | 1388 | 926               | OK                   |
| Compliance `C=1E-5` | 4.07    | 21158    | 824      | 31234   | 1410 | 894               | OK                   |
| Compliance `C=1E-4` | 4.07    | 20188    | 1004     | 30992   | 1522 | 1005              | OK                   |

`Leakage` raises `l` from 1e-4 to 1e-3 on the isolation and bypass valves only (the load valve keeps 1e-4): the singular column of §3a grows 100×, `R_load` is unchanged, and the run passes — consistent with the column, not the steep row, being the operative defect. Per simulated second Compliance costs ~25 % more f-evaluations than the Leakage/Linearized variants. `C = 1e-4` is not better (more rejected steps, Jacobians and convergence failures); `C = 1e-5` stays the default. The initialization improvement is real in iteration count but free in time (init CPU 0.31–0.33 s for every variant).

### Cost with a distributed load — `HardCase1NLoads`, 12 terminal units per loop

The table above uses one aggregated load per loop. `HardCase1NLoads` replaces it with `nLoa=12` throttled terminal units tapped off supply/return mains, remote ∆p sensed just upstream of the last unit; sizing is preserved so the design operating point is identical for any `nLoa`.

| variant (`nLoa=12`)  | CPU (s) | accepted | rejected | f-evals | Jac  | NL conv. failures | Newton failures         | outcome |
| -------------------- | ------- | -------- | -------- | ------- | ---- | ----------------- | ----------------------- | ------- |
| baseline             | 37.7    | 16895    | 518      | 25879   | 1363 | 887               | 1 init + 12 sim         | OK      |
| Compliance `C=1E-5`  | 32.6    | 19306    | 722      | 29191   | 1427 | 946               | 0                       | OK      |

**The overhead is not bounded to the plant.** Nothing between the plant supply junction and the terminal valves carries a pressure state, so every branch takeoff adds algebraic pressure nodes to the *same* block: the torn `simulation.nonlinear[1]` goes 8 (aggregated) → 10 (`nLoa=1`) → 13 (`nLoa=4`) → 31 (`nLoa=12`), roughly two iteration variables per terminal unit, and CPU goes 3–4 s → 33–38 s. The `nLoa=12` iteration set is 5 plant unknowns (`valIso.valHeaWatUniInlIso[i].port_b.p`, `pumPri.pum*.valChe[i].dp`, …) plus 25 distribution `dp`/`m_flow` variables.

**The baseline no longer fails.** All 12 `simulation.nonlinear[1]` Newton failures (cond. 5e6–1.6e14, same near-singular signature as §3a) are recovered by CVode step reduction; only initialization keeps an unrecovered `nonlinear[25]` residual. This is the event-grid luck of §1 — at `nLoa=1` the same defect kills the run at 22015.9 s, at `nLoa=12` it does not.

**Compliance reverses sign at scale.** With one aggregated load it costs ~20 % CPU; at `nLoa=12` it *saves* 14 % (32.6 vs 37.7 s) despite taking more steps, more f-evaluations and more Jacobians. The gain is per-evaluation, not per-step: the compliance gives the CHW and HW supply nodes their own pressure states, which cuts the single 31-variable block into two smaller independent ones, and cost per f-evaluation drops from 1.46 to 1.12 ms (−23 %). Newton failures drop to zero. So the more components are exposed to the plant supply pressure, the more the compliance pays for itself — the `nLoa=1` penalty is the worst case, not the trend.

### Side note — would `from_dp=false` in `CheckValve.mo` help?

No. A closed valve's row reads `m − g(Δp)` with `∂/∂Δp = g' ≈ 1.7e-7` in one form and `Δp − f(m)` with `∂/∂m = f' ≈ 3e6` in the other. Dymola divides each row by its own norm, after which both rows carry the same information: this element's conductance is ~1e-7 kg/s/Pa, so it says almost nothing about the pressure on its far side. The floating level (§3a) is a property of the network — six closed elements around a loop with no pressure state — not of how any one of them is written. With the compliance in place, `from_dp=true` is the better form: both ends of the idle check valve are known, `m = g(Δp)` evaluates explicitly, and the leakage leaves the nonlinear block.

---

## 2. Chiller plant template

Water-cooled chiller plant, 2 parallel chillers, headered primary pumps, `Variable1Only`, waterside economizer `HeatExchangerWithValve`. Sources: `ChillerHardCase1.log`, `ChillerHardCase1.mof`, result files from a rerun (`/tmp/chi_diag/base`, `/tmp/chi_diag/comp`). Same fatal signature — `simulation.nonlinear[1]`, `cond 5.1e8`, "close to singular, suggesting that there is no solution", CVode gives up at 30820.8 s — and `pla(intChi(use_cpl=true))` cures it. But it is not the same defect.

### Physical state at failure

```
                    30700      30800      30815    30819 (base)  | 30821 (Compliance)
byp.kVal            3.023      0.2505    0.03053    0.03053      |  0.0003023  ← floor l·k_nom
byp.m               13.4       7.42      1.63       1.65         |  0.00025
iso1.k              0.2019     0.2315    0.2321     0.2321       |  0.2327     ← open
iso1.m              0.89       6.86      12.57      12.56        | 14.23
pum1.m              14.31      14.30     14.23      14.23        | 14.25
che2.dp            -52870    -52110    -52810     -52810         |    —        ← pump 2 off, reverse
p_suc / com.p      351.3k     350.5k    348.4k     348.4k        | 347.6k
p_ret              351.3k     351.3k    351.3k     351.3k        | 351.3k
```

WSE-only operation from ~30000 s (chillers isolated, chiller bypass `intChi.valChiWatChiBypPar` open, pump 1 circulating through the HX). Chiller 1 is enabled: its isolation valve opens 30600–30700, _then_ the bypass strokes closed 30800–30821, and the run dies when `kVal` reaches its leakage floor `l·k_nom = 1e-4 · 95.6/√1000 = 3.0e-4`.

**Nothing is floating.** The pump suction header (`rouSupPar.port_aComLeg`, where `com` attaches) is tied to the return header through the open chiller-1 isolation valve carrying 12.6 kg/s at 2.9 kPa. Both ends of the closing bypass are pressurized.

### Block at cause

```
Iteration variables                                   Residuals
 1  pla.pumChiWatPri.valChe[2].dp                     1  0 = pum[2].dpMachine - (valChe[2].dp + valChiWatMinByp.lin.dp + valChiWatChiIsoPar[1].lin.dp)
 2  pla.port_a.m_flow                                 2  0 = intChi.ports_bSup[1].m_flow + m_che(valChe[1].dp)
 3  pla.intChi.valChiWatChiBypPar.port_a.m_flow       3  0 = eco.hex.port_a2.m_flow - port_a.m_flow + eco.valChiWatByp.port_a.m_flow
```

First lines of the torn part:

```
pla.chi.valChiWatChiIsoPar[1].lin.dp := basicFlowFunction_m_flow(pla.intChi.valChiWatChiBypPar.port_a.m_flow,
                                                                 pla.intChi.valChiWatChiBypPar.lin.kVal, m_flow_turbulent);
pla.chi.chi[1]...extBusSig[5].u[1]   := basicFlowFunction_dp(valChiWatChiIsoPar[1].lin.dp, valChiWatChiIsoPar[1].lin.k, ...);   // chiller-1 flow
pla.chi.chi[2]...extBusSig[5].u[1]   := basicFlowFunction_dp(valChiWatChiIsoPar[1].lin.dp, valChiWatChiIsoPar[2].lin.k, ...);   // chiller-2 flow
```

Bypass, chiller 1 and chiller 2 form a parallel group between return header and suction header. Dymola chose **the bypass flow** as the group's iteration variable and computes the group's common Δp by **inverting the bypass valve's law** (the `inverse(...)` annotation on `basicFlowFunction_dp` permits it). Chiller flows, min-bypass flow, `valChiWatMinByp.lin.dp`, `valChe[1].dp` and the economizer Δp all follow from that Δp. So the whole block is back-substituted through one assignment, `Δp := basicFlowFunction_m_flow(m_byp, kVal_byp, m_turb_byp)`, whose slope in the laminar branch is `R_byp = 0.375·m_turb/kVal²`. That assignment does not change form when the valve strokes shut — only `kVal` does, from `k_nom = 3.0` down to its floor `l·k_nom = 3.0e-4`. `R_byp` therefore grows by `1/l² = 1e8`, from 0.08 to 7.8e6 Pa/(kg/s), and every quantity derived from the group Δp inherits that factor:

```
R_byp      = 0.375 · m_turb / kVal²          = 0.375 · 1.912 / (3.0e-4)²     = 7.8e6 Pa/(kg/s)
∂r1/∂m_byp ≈ R_byp · (1 + R_minByp · g_iso1) = 7.8e6 · (1 + 1.5e4 · 2.1e-3)  = 2.7e8   (log: J_sum row 1 = 2.13e8–2.19e8)
```

Rows 2 and 3 inherit the factor through the chiller-1 flow (`g_iso1·R_byp ≈ 1.7e4`) and the min-bypass Δp. Jacobian evaluations paired with iterates:

```
 log line   valChe2.dp   m_plant     m_byp       J_sum1     J_sum2     J_sum3      cond
 1277700    -57437.1    7.97084   5.5541e-04   2.175e+08  1.338e+04  2.565e+06  4.597e+08
 1277830    -57438.5    7.96993   5.3338e-04   2.125e+08  2.426e+06  8.923e+05  5.140e+08
 1278270    -57435.1    7.96789   5.5473e-04   2.175e+08  1.339e+04  2.721e+06  4.596e+08
 1278400    -57436.3    7.96734   5.3317e-04   2.125e+08  2.428e+06  8.958e+05  5.140e+08
 1278650    -57433.7    7.96645   5.5431e-04   2.174e+08  1.339e+04  2.867e+06  4.595e+08
 1278780    -57435.3    7.96593   5.3305e-04   2.125e+08  2.429e+06  8.975e+05  5.141e+08
```

A 2e-5 kg/s change in the bypass iterate moves the computed group Δp by 157 Pa, the chiller-1 flow by 0.33 kg/s, and the min-bypass Δp — hence `valChe[1].dp` — by **5.2 kPa**, walking check valve 1 across its entire 0–5000 Pa blend region: the 180× alternation in `J_sum2`. The `valChe[2].dp` column is `[1, ~3e-7, ~0]`, the `m_plant` column O(1)–O(1e3); after row scaling all three rows are ≈ `e_{m_byp}`, hence `‖J⁻¹‖ = 3e8`, `cond = 5e8`, and Dymola's "no solution" — a misreading here: the system is well posed, the Jacobian is merely scaled by the `1/l²` of that one torn assignment.

```
Warning: Failed to solve nonlinear system using Newton solver.
  Time: 30820.79078302091
  Tag: simulation.nonlinear[1]
  The nonlinear solver stopped since:
   * Number of calls to nonlinear solver DymNL has reached or exceeded
     the maximum allowed number of function calls= 400
  Jacobian inverse norm estimate: 2.9724e+08
  Condition number estimate: 5.14083e+08
  1-norm of the residual = 227.344
  The estimates indicate that the Jacobian is close to singular, suggesting that there is no solution.
  Last value of the solution:
    pla.pumChiWatPri.valChe[2].dp = -57435.3
    pla.port_a.m_flow = 7.96592
    pla.intChi.valChiWatChiBypPar.port_a.m_flow = 0.000552757
  Last value of the residual:
    { 208.826, -14.7577, -3.75946 }
```

### Same amplifier, different disease

|                                          | HP `HardCase1`                         | Chiller `HardCase1`                           |
| ---------------------------------------- | -------------------------------------- | --------------------------------------------- |
| closed element whose inverse law is used | load valve (`R_load = 3.1e8`)          | chiller bypass (`R_byp = 7.8e6`)              |
| what that inverse computes               | loop supply–return Δp                  | parallel-group Δp                             |
| is that Δp physically determined?        | **no** — loop cut off on all six sides | **yes** — chiller 1 open, 12.6 kg/s           |
| Jacobian defect                          | rank-1 deficient (level column ~1e-7)  | full rank, `cond 5e8` (all rows ∝ one column) |
| trigger                                  | all units in heating                   | bypass reaching its `l` floor                 |

With `use_cpl=true`:

```
Iteration variables: valChe[2].dp, outPumChiWatPri.port_b.m_flow, port_a.m_flow      (timevarying input: pla.intChi.com.p)
Residual 1:          0 = pum[2].port_b.p - (valChe[2].dp + valChiWatMinByp.lin.dp + bouChiWat.p)
```

The suction-header pressure is a state, so the group's Δp is `bouChiWat.p − com.p`, known at every residual evaluation; bypass, chiller-1 and chiller-2 flows are evaluated _forward_ (`m = f_dp(Δp, k)`, benign for a closed valve); the bypass flow leaves the iteration set; residual 1 is linear in `valChe[2].dp`. In the HP case the compliance supplied a missing state; here it removes the inversion by handing Dymola an explicit pressure it prefers to iterate on. The Compliance run passes through the identical transition (`kVal` reaches 3.0e-4 at 30827.5 s, `com.p = 347.6 kPa`, chiller 1 at 14.2 kg/s) and completes the day (14974 accepted steps, 331 NL convergence failures, no NL solver failure).

Two consequences. This case would presumably also respond to `l = 1e-3` on the bypass alone (`R_byp` down 100×, cond ~5e6) or to steering the tearing with `__Dymola_SimulationIterationVariables` — neither tested; both are fragile next to the compliance, which works regardless of what the tearing picks. And the class of failure is broader than "idle branch": any two-position valve whose flow the tearing picks as the iteration variable of a parallel group will do this when it closes, whether or not anything floats.

## Summary

When all three units run in heating mode, the CHW loop of a reversible plant is cut off from the pressure-referenced HW side by six closed elements (three closed isolation valves, three reverse-biased check valves behind stopped pumps). The loop has no pressure state, so its absolute level and its supply–return difference are algebraic and the tearing represents them through `valChe[3].dp` and through `R_load · pla.port_aChiWat.m_flow`, the inverse law of the closed load valve with `R_load = 3.1e8 Pa/(kg/s)`. The Jacobian column of the level is ~1e-7 (leakage slopes only, `∝ l²`): rank-deficient, `‖J⁻¹‖ = 8e5` after row scaling, `cond = 8.3e8` and invariant to the state. With the level stuck, rows 6 and 7 — both ≈ `e_{m_load}` after scaling — demand different values of the loop flow, and the row-7 coefficient jumps 100× across the bypass's regularization band. Newton crawls (~10 Pa of level per call), exhausts its budget, and CVode gives up. A `Compliance` element on the loop makes the level a state, removes the singular column, and the same block converges in ~3 residual evaluations per call.

The chiller plant's `HardCase1` (§7) shares the amplifier — a header Δp back-substituted through the inverse law of a closed valve, `∝ 1/l²` — but not the defect: there the Δp is physically determined (chiller 1 open) and the Jacobian is full rank at `cond 5e8`, because Dymola chose the closing bypass flow as the iteration variable of a parallel group and back-substitutes the whole block through the inverse of that valve's law. The same compliance fixes it by making the header pressure a state, so every branch of the group is evaluated forward from a known Δp and the closed valve is never inverted.
