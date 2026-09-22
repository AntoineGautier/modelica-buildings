# NL convergence failures in Templates

TODO:
- Mention alternatives:
  - Leakage: not robust solution due to sensitivity to event grid (e.g. suppressing assert blocks!), or NL scale (HardCase1NLoadsLeakage failing) or structure (Chillers.Validation.HardCase1Leakage failing) + impact of leakage flow (0.2 kg/s ) on HP inlet temperatures
  - Linearize valve flow functions: significant impact on trajectories e.g. when primary pumps are maxed out before staging up, the loop ∆p is no more feedback controlled but rather driven by pump VS valve characteristic, which impacts load valve opening, CHW/HW requests, temperature reset, capacity requirement, HP staging


----

The analysis is based on the three plant templates from

- https://github.com/lbl-srg/modelica-buildings/pull/4657: AWHP plant
- https://github.com/lbl-srg/modelica-buildings/pull/3167: chiller plant
- https://github.com/lbl-srg/modelica-buildings/pull/3364: boiler plant

The template validation models are all simulated with `pla(linearized=false)` for all valid plant configurations using the scripts under `Buildings/Resources/Scripts/travis/templates`. 

- Test branch: https://github.com/AntoineGautier/modelica-buildings/tree/issue3759_templateNumerics

Several simulation failures were fixed by 

- correcting the control sequences (e.g. chiller enabled with no CW pump enabled): https://github.com/lbl-srg/modelica-buildings/pull/4705, https://github.com/lbl-srg/modelica-buildings/pull/4696, https://github.com/lbl-srg/modelica-buildings/pull/4693, https://github.com/lbl-srg/modelica-buildings/pull/2299
- fixing a bug in the HP model: https://github.com/ibpsa/modelica-ibpsa/issues/2162

After that, two types of configuration still fail.

1. AWHP plant: separate dedicated primary pumps (one for CHW, one for HW), primary-only or primary-secondary distribution (both failing). This fails with both OCT and Dymola (CVode solver). Completes successfully with Dassl solver.
2. Chiller plant: WSE with heat exchanger bypass valve, headered primary pumps, primary-only distribution. This fails with Dymola (CVode solver). (OCT cannot translate the chiller plant controller). Completes successfully with Dassl solver.

---

## 1. AWHP plant template

```
Warning: Failed to solve nonlinear system using Newton solver.
  Time: 22015.93464026791
  Tag: simulation.nonlinear[1]
   * Number of calls to nonlinear solver DymNL has reached or exceeded
     the maximum allowed number of function calls= 900
  Jacobian inverse norm estimate: 801468
  Condition number estimate: 1.26339e+06
  1-norm of the residual = 15.9088
  Last value of the solution:
    pla.pumPri.pumChiWat.valChe[3].dp = -2243.27
    pla.valIso.port_aChiWat.m_flow = -0.00111231
    pla.port_aChiWat.m_flow = 4.08264E-05
    ...
  Last value of the residual (unscaled!):
    { -0.000218064, -0.000278686, -0.000101332, 8.24992E-05, -0.000277594,
      0.000579542, 15.9073, -2.91588E-05 }
SUNDIALS: CVODE CVode At t = 22015.9 repeated recoverable right-hand side function errors.
```

All three HPs are in heating mode for the whole run: CHW isolation valves closed, CHW pumps off. 

⇒ The CHW loop is hydronically isolated from the HW side by the CHW isolation valves at HP inlet and the primary CHW pump check valves (exposed to the counter pressure differential of the primary HW pumps). 

### The block

`simulation.nonlinear[1]` is the torn 8×8 system of the isolation/check-valve network. It is well posed whenever one of the six elements that close off the CHW loop is open; it degenerates only in the operating state where the CHW isolation valves are closed and the CHW pumps are off. 

From `dsmodel.mof` (idle-loop items flagged):

```
Iteration variables                                    Residual equations (all flow balances, kg/s)
1  valIso.valHeaWatUniInlIso[1].port_b.p               1  junHeaWatSup.ports[1].m_flow - m_che(pumHeaWat.valChe[1].dp)
2  pumPri.pumChiWat.valChe[3].dp             <-- idle  2  junHeaWatSup.ports[3].m_flow - m_che(pumHeaWat.valChe[3].dp)
3  valIso.valHeaWatUniInlIso[3].port_b.p               3  pumPri.ports_bChiWat[1].m_flow + m_che(pumChiWat.valChe[1].dp)               <-- idle
4  VHeaWat_flow.port_a.m_flow                          4  pumPri.ports_bChiWat[2].m_flow + m_che(pumChiWat.valChe[2].dp)               <-- idle
5  pumPri.pumHeaWat.valChe[2].dp                       5  junHeaWatRet.ports[2].m_flow + m_flow_dp(valHeaWatUniInlIso[2].lin.dp, ...)
6  valIso.port_bHeaWat.m_flow                          6  junChiWatRet.ports[2].m_flow + m_flow_dp(valChiWatUniInlIso[2].lin.dp, ...) <-- idle
7  valIso.port_aChiWat.m_flow                <-- idle  7  junChiWatBypSup.port_3.m_flow + m_flow_dp(valChiWatMinByp.lin.dp, ...)     <-- idle
8  port_aChiWat.m_flow                       <-- idle  8  junHeaWatBypSup.port_3.m_flow + m_flow_dp(valHeaWatMinByp.lin.dp, ...)
```

The idle loop has two algebraic pressure variables, its absolute level and its supply–return difference. Neither appears by name among the unknowns: the tearing carries the level as `valChe[3].dp` (offset from the HW node `valHeaWatUniInlIso[3].port_b.p`) and the difference as `R_load · port_aChiWat.m_flow`, the *inverse* law of the closed load valve:

```
R_load = 0.375 · deltaM · Δp_nom / (l² · ṁ_nom) = 3.14e8 Pa/(kg/s)      (l = 1e-4, ṁ_nom = 71.7, Δp_nom = 3e4)
```

Every residual reaches the pressure level only through a closed element, whose conductance is `g = 1.40625 · l² · ṁ_nom / (deltaM · Δp_nom)`: 1.7e-7 kg/s/Pa for a reverse-biased check valve (`l = 1e-3`), 1.7e-8 for a closed isolation valve (`l = 1e-4`). So the `valChe[3].dp` column of the Jacobian is O(1e-7) against row norms of 17–1200.

### What the log says

**1. The block is near-singular for the whole idle period, and converges anyway.** Over the run Dymola evaluated the Jacobian 12,521 times; the condition estimate is above 1e8 in 67 % of them, and is 8.349e8, constant to six digits, during the fatal calls. 

The same block converged in ~6,600 calls at that condition number. So neither `cond` nor `‖J⁻¹‖` explains why this call fails and the others did not; they only measure the leak-only column, i.e. that an O(1 kg/s) error in any residual is worth O(1 kPa) of pressure level in a Newton step.

**2. The failure chain: an HW-side residual at the start of a call becomes a kPa error on the CHW pressure level, and from there the solver stalls.**

Every call is warm-started from the previous solution, so its initial residual is the effect of the inputs that changed since. In every case below that residual sits in rows 1 and 2 (HW pump check valves) while the idle rows start at zero. The first Newton step turns it into 0.2–1 kPa of CHW level per kg/s, and in three of the four cases the full step *increases* the residual: the linear model does not hold over the step.

| call | start residual, rows 1,2 | first step on the level | actual / predicted decrease | outcome |
| --- | --- | --- | --- | --- |
| 21690.27 s | 0.50 kg/s | +513 Pa | −0.40 / 1 | stalls (900 calls); CVode retries with a smaller step, residual 0.12 kg/s, converges in 13 iterations |
| 21861.08 s | 0.18 kg/s | +190 Pa | +0.78 / 1 | stalls; retry at 0.045 kg/s converges in 7 iterations |
| 22014.08 s | 43 kg/s | −9370 Pa | −0.22 / 1 | stalls; the retry from the identical point converges in ~45 iterations |
| 22015.9346 s, 9 calls | 26.2 kg/s | −4660 Pa | −0.38 / 1 | all stall; CVode gives up |

Two facts from the table. Recovery is not decided by the start alone: at 22014.08 s the first attempt and the retry begin at the same point with the same residual; the first cycles through the same three trial points until its budget is spent, the retry takes the same three and then finds the solution. And the nine fatal calls all begin at the same warm start with the same 26.2 kg/s residual, for CVode step sizes from 2 s down to 0.1 ms. What changed on the HW side between that warm start and these calls is not in the log, and the result file ends 70 s earlier.

**3. What the stall looks like.** Once the level is off by kPa, every coupling back to it runs through a leak law whose slope changes 100× within 14 Pa (bypass, regularized band) or across the 5 kPa blend of the check valves, so each step lands on slopes other than the ones it was computed with. In the fatal calls the iterate settles at a level of −2.1 to −2.8 kPa and a loop flow of ~7e-5 kg/s. There the row-scaled residual floors at 3e-5 … 1.7e-4, carried by rows 6 and 7 (the isolation-valve and bypass balances, which a wrong level makes inconsistent); predicted and actual decreases alternate in sign, and Dymola's line-search dump shows the scaled norm flat to 1e-8 over α = ±1e-3: no descent direction. Nine calls, 9,369 iterations, 1,278 Jacobians.

The headline `1-norm of the residual = 15.9` is row 7 alone: a loop flow of 4.1e-5 kg/s through `R_load = 3.1e8` is a 13 kPa supply–return difference, at which the open bypass carries 15.9 kg/s. In the solver's row-scaled metric that row is 2.5e-5, smaller than row 6. It is a symptom of the wrong level, not a second defect.

Side note: the event instants stored in the last 400 s of the run are state events fired by the idle loop's numerical noise (CHW flows of 1e-23 kg/s and a cooling capacity requirement of 1e-11 W crossing zero). None changes a physical quantity; each restarts CVode.

### Fix: a pressure state on the loop

**Why `Leakage` passes.** Raising `l` from 1e-4 to 1e-3 on the isolation and bypass valves only (load valve unchanged) multiplies the level column by 100 and leaves `R_load` alone; the run completes. Consistent with the column, not the steep row, being the operative defect.



`Buildings.Templates.Components.Routing.Compliance` at the CHW supply junction, inside the idle loop, `C = 1e-5 kg/Pa` (`C * der(p) = port_a.m_flow`). With `comChiWatSup` (and `comHeaWatSup`) in `ValvesIsolation` the block becomes:

```
Iteration variables:  pumChiWat.valChe[1..3].dp, pumHeaWat.valChe[1..3].dp, valIso.port_aChiWat.m_flow, port_aChiWat.m_flow
Residual equations:
  0 = pumChiWat.pum[i].dpMachine - (pumChiWat.valChe[i].dp + comChiWatSup.p) + valHeaWatUniInlIso[i].port_b.p     i = 1..3
  0 = junHeaWatRet.ports[2].m_flow + m_flow_dp(valHeaWatUniInlIso[2].lin.dp, ...)
  0 = junChiWatRet.ports[i].m_flow + m_flow_dp(valChiWatUniInlIso[i].lin.dp, ...)                                     i = 1..3
  0 = junChiWatBypSup.port_3.m_flow + m_flow_dp(valChiWatMinByp.lin.dp, ...)
```

With the level a state, an HW-side imbalance can no longer be traded for kPa of CHW level inside a Newton step. The leakage laws of the closed check valves are still in the block, but no unknown depends on them alone any more: the level is a state, and each `valChe[i].dp` is fixed by the first residual above, the pressure sum around its pump branch (`p_i + dpMachine − valChe[i].dp = comChiWatSup.p`), in which it enters with coefficient −1. In the baseline `valChe[3].dp` appeared only in flow-balance rows, through the leak law, with coefficient `g ≈ 1.7e-7`. The leak flows are still evaluated, but only as O(1e-7) contributions to flow-balance rows that other terms dominate. In the baseline the leak laws were the only equations tying the level to the rest, whichever way they were written. The `R_load · m_flow` back-substitution is still there, but with the level pinned the loop rows are consistent and the loop flow converges to zero.

```
                              baseline              compliance
Continuous time states        89                    91
Nonlinear systems             {52, 43, 43, 3,3,3}   {45, 3, 43, 43, 3,3,3}
  after manipulation          { 8,  1,  1, 1,1,1}   { 8, 1,  1,  1, 1,1,1}
 simulation.nonlinear[1]    : 96022 calls, 317424 residues, 96155 Jacobians   (3.3 residuals, 1.0 Jacobian per call; 0 NL failures)
 initialization.nonlinear[1..6]: 1 call each, 2–9 residues                     (baseline: init.nonlinear[3] 1225 residues, failed)
```

### Cost (NL debug logging off; the debug log itself inflates CPU 15–21× and non-uniformly)

| variant             | CPU (s) | accepted | rejected | f-evals | Jac  | NL conv. failures | outcome              |
| ------------------- | ------- | -------- | -------- | ------- | ---- | ----------------- | -------------------- |
| baseline            | 0.37    | 1263     | 72       | 1973    | 94   | 69                | **FAILED** @ 22015.9 |
| Leakage             | 3.39    | 15932    | 564      | 24309   | 1353 | 886               | OK                   |
| Linearized          | 3.48    | 16895    | 575      | 25737   | 1388 | 926               | OK                   |
| Compliance `C=1E-5` | 4.07    | 21158    | 824      | 31234   | 1410 | 894               | OK                   |
| Compliance `C=1E-4` | 4.07    | 20188    | 1004     | 30992   | 1522 | 1005              | OK                   |

Per simulated second Compliance costs ~25 % more f-evaluations than Leakage/Linearized. `C = 1e-4` is not better (more rejected steps, Jacobians and convergence failures); `C = 1e-5` stays the default. Initialization CPU is 0.31–0.33 s for every variant.

### Cost with a distributed load: `HardCase1NLoads`, 12 terminal units per loop

`HardCase1NLoads` replaces the aggregated load with `nLoa=12` throttled terminal units tapped off supply/return mains, remote ∆p sensed upstream of the last unit; sizing is preserved so the design point is identical for any `nLoa`.

| variant (`nLoa=12`)  | CPU (s) | accepted | rejected | f-evals | Jac  | NL conv. failures | Newton failures         | outcome |
| -------------------- | ------- | -------- | -------- | ------- | ---- | ----------------- | ----------------------- | ------- |
| baseline             | 37.7    | 16895    | 518      | 25879   | 1363 | 887               | 1 init + 12 sim         | OK      |
| Compliance `C=1E-5`  | 32.6    | 19306    | 722      | 29191   | 1427 | 946               | 0                       | OK      |

- **The block grows with the distribution.** Nothing between the plant supply junction and the terminal valves carries a pressure state, so every takeoff adds algebraic pressure nodes to the same block: 8 (aggregated) → 10 (`nLoa=1`) → 13 (`nLoa=4`) → 31 (`nLoa=12`) iteration variables, CPU 3–4 s → 33–38 s.
- **The baseline no longer fails, by luck.** Its 12 Newton failures (cond 5e6–1.6e14, same signature) are all recovered by CVode step reduction. Same defect, different event grid.
- **Compliance pays for itself at scale.** It costs ~20 % CPU with one load and saves 14 % at `nLoa=12`, despite more steps and Jacobians: the supply-node states split the 31-variable block into two independent ones and the cost per f-evaluation drops 1.46 → 1.12 ms. Newton failures drop to zero.

### Side note: would `from_dp=false` in `CheckValve.mo` help?

No. A closed valve's row is `m − g(Δp)` with slope 1.7e-7 in one form and `Δp − f(m)` with slope 3e6 in the other; after Dymola's row scaling both say the same thing, that this element tells almost nothing about the pressure on its far side. The defect is the network (six closed elements around a loop with no pressure state), not the form of any one law. With the compliance in place the question is moot: the check-valve ∆p's are fixed by pressure balances, and the leak laws only feed flow balances they do not dominate.

### Is the HW compliance needed? `HardCase1ComplianceCHW`, `use_cpl=true, use_cplHw=false`

Only the CHW loop can lose its pressure reference, so in principle the HW compliance is redundant. It is not: besides pinning a level it **splits the block**. With both, the HW loop is its own 1×1 system (`0 = loaHea.val.dp − comHeaWatSup.p + pipHeaWat.dp + bouHeaWat.p`) and block 1 holds 8 CHW/check-valve unknowns; with CHW only, the HW supply pressure is rebuilt algebraically and the HW loop flow and min-bypass row join block 1 (9 unknowns). The run still completes (58.5 s, faster than either), but three Newton failures survive: `initialization.nonlinear[3]` (772 residues, rescued by global homotopy; 2 residues with both) and two at t = 19172.6 / 19174.3, the start of HW pump 1.

There the CHW side is dead (all pumps off, load valve shut) yet not idle: pump 1 pulls node 1 down 24.2 kPa below `comChiWatSup.p` and pushes 4.07e-4 kg/s through the closed `valChiWatUniInlIso[1]`, out through the min bypass. The compliance pinned the level but the supply–return ∆p is *still* the inverse law of the closed load valve, so `port_aChiWat.m_flow` must be resolved at 2.4e-11 with `∂r8/∂m_load = 1 + g_byp·R_load = 1.66e7` (log: `J_sum` row 8 = 1.65737e7). The HW transient in the same block keeps kicking it past the bypass breakpoint `dp_turb = 14.0 Pa` ⇔ `m_load = 4.5e-8`: at the stall the iterate sits at −9.58e-8, i.e. −30 Pa of loop ∆p and a phantom 0.77 kg/s of bypass flow — exactly the printed residual. `J_sum` row 8 alternates 5.3e5 ↔ 5e6 and the scaled residual limit-cycles between 1.2e-6 and 1.1e-5, never reaching tolerance; `cond = 2.2e6`, nowhere near singular. The trajectory is unaffected (both were rejected steps).

Keeping `use_cplHw=true` is the cheap answer. The amplifier itself — a ∆p obtained by inverting a shut valve — would only be removed by a second state on the CHW return, so that both the load branch and the min bypass are evaluated forward; untested.

---

## 2. Chiller plant template

### State at failure

WSE-only operation from ~30000 s. Chiller 1 is enabled: its isolation valve opens 30600–30700, then the chiller bypass strokes closed 30800–30821, and the run dies when `kVal` reaches its floor `l·k_nom = 3.0e-4`:

```
                    30700      30800      30815    30819 (base)  | 30821 (Compliance)
byp.kVal            3.023      0.2505    0.03053    0.03053      |  0.0003023  ← floor l·k_nom
byp.m               13.4       7.42      1.63       1.65         |  0.00025
iso1.m              0.89       6.86      12.57      12.56        | 14.23
che2.dp            -52870    -52110    -52810     -52810         |    —        ← pump 2 off, reverse
p_suc / com.p      351.3k     350.5k    348.4k     348.4k        | 347.6k
```

Nothing floats: the pump suction header is tied to the return header through the open chiller-1 isolation valve at 12.6 kg/s, and both ends of the closing bypass are pressurized.

### Block at cause

```
Iteration variables                                   Residuals
 1  pla.pumChiWatPri.valChe[2].dp                     1  0 = pum[2].dpMachine - (valChe[2].dp + valChiWatMinByp.lin.dp + valChiWatChiIsoPar[1].lin.dp)
 2  pla.port_a.m_flow                                 2  0 = intChi.ports_bSup[1].m_flow + m_che(valChe[1].dp)
 3  pla.intChi.valChiWatChiBypPar.port_a.m_flow       3  0 = eco.hex.port_a2.m_flow - port_a.m_flow + eco.valChiWatByp.port_a.m_flow

Torn part, first assignment:
pla.chi.valChiWatChiIsoPar[1].lin.dp := basicFlowFunction_m_flow(valChiWatChiBypPar.port_a.m_flow, valChiWatChiBypPar.lin.kVal, ...)
```

Bypass, chiller 1 and chiller 2 form a parallel group. Dymola picked the **bypass flow** as the group's iteration variable and computes the group ∆p by inverting the bypass law (based on the `inverse(...)` annotation). Chiller flows, min-bypass ∆p, `valChe[1].dp` and the economizer ∆p all follow. That assignment's slope is `R_byp = 0.375·m_turb/kVal²`, which grows by `1/l² = 1e8` as the valve closes, from 0.08 to 7.8e6 Pa/(kg/s), and every quantity derived from the group ∆p inherits the factor:

```
∂r1/∂m_byp ≈ R_byp · (1 + R_minByp · g_iso1) = 7.8e6 · (1 + 1.5e4 · 2.1e-3) = 2.7e8      (log: J_sum row 1 = 2.1e8)
```

The log confirms the timing: the block's condition estimate is 2e3–5e4 for the last half of the run and reaches 5e8 only in the final Jacobians as `kVal` hits its floor. A 2e-5 kg/s change in the bypass iterate moves the group ∆p by 157 Pa, the chiller-1 flow by 0.33 kg/s and `valChe[1].dp` by 5.2 kPa, walking check valve 1 across its whole 0–5000 Pa blend region (`J_sum` row 2 alternates 1.3e4 ↔ 2.4e6 between consecutive Jacobians). After row scaling all three rows are ≈ `e_{m_byp}`, hence `cond = 5e8` and Dymola's "no solution", a misreading: the system is well posed, the Jacobian is scaled by the `1/l²` of one torn assignment.

### Same amplifier, different disease

|                                          | HP `HardCase1`                                 | Chiller `HardCase1`                           |
| ---------------------------------------- | ---------------------------------------------- | --------------------------------------------- |
| closed element whose inverse law is used | load valve (`R_load = 3.1e8`)                  | chiller bypass (`R_byp = 7.8e6`)              |
| what that inverse computes               | loop supply–return Δp                          | parallel-group Δp                             |
| is that Δp physically determined?        | **no**: loop cut off on all six sides          | **yes**: chiller 1 open, 12.6 kg/s            |
| Jacobian defect                          | a column small because the physics is (leakage), all run long | a column large because of the variable choice, `cond` 5e4 → 5e8 as bypass closes |
| trigger                                  | HW-side mismatch at the start of a call        | bypass reaching its `l` floor                 |

With `use_cpl=true` the suction-header pressure is a state and the group ∆p is `bouChiWat.p − com.p`, a boundary value minus a state; bypass and chiller flows are evaluated forward (`m = m_flow_dp(Δp, k)`, benign for a closed valve), the bypass flow leaves the iteration set and residual 1 is linear in `valChe[2].dp`. The Compliance run passes through the identical transition (`kVal` reaches 3.0e-4 at 30827.5 s) and completes the day (14974 accepted steps, 331 NL convergence failures, no NL solver failure).

Two consequences. This case would presumably also respond to `l = 1e-3` on the bypass alone (`R_byp` down 100×) or to steering the tearing with `__Dymola_SimulationIterationVariables`, neither tested; both are fragile next to the compliance, which works regardless of what the tearing picks. And the class of failure is broader than "idle branch": any two-position valve whose flow the tearing picks as the iteration variable of a parallel group will do this when it closes, whether or not anything floats.

## Summary

HP plant: with all units in heating, the CHW loop is cut off by six closed elements and has no pressure state, so the tearing represents its level as `valChe[3].dp`, reachable only through leak conductances of 1e-7 kg/s/Pa, and its supply–return ∆p through the inverse law of the closed load valve (`R_load = 3.1e8`). The block is near-singular (`cond` 4e8–1e9) for the whole idle period and converges thousands of times regardless. It fails when a call starts with an imbalance on the HW side: 0.5 kg/s already costs a 500 Pa kick on the level and a 900-call stall that CVode recovers with a smaller step; the 26 kg/s mismatch at 22015.9346 s costs 4.7 kPa and cannot be recovered at any step size, because every path back to the right level runs through leak laws whose slope changes 100× over a few Pa. A `Compliance` element on the loop makes the level a state, removes the trade between HW residual and CHW level, and the same block converges in ~3 residual evaluations per call.

Chiller plant: the same amplifier (a header ∆p back-substituted through the inverse law of a closing valve, `∝ 1/l²`) with nothing floating: Dymola chose the bypass flow as the iteration variable of a parallel group, and the block's condition number climbs from 5e4 to 5e8 as the bypass reaches its leakage floor. The same compliance fixes it by making the header pressure a state, so every branch of the group is evaluated forward and the closed valve is never inverted.
