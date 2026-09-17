# NL convergence failure in `Buildings.Templates.Plants.HeatPumps.Validation.HardCase1`

Diagnostic record, 2026-09-16/17. Reversible air-to-water HP plant, 3 units, dedicated pumps, `Variable1Only` distribution. Dymola 2026x Refresh 1, CVode, tol 1e-6, 0–86400 s.

---

## Q1 — Would reformulating `CheckValve.mo` with `from_dp=false` help the idle-branch failure pattern?

No. Take the closed valve's row in each form and apply Dymola's own row scaling (divide by `J_sum`, which is what the solver actually drives down):

| form | residual | ∂r/∂p | ∂r/∂m | `J_sum` | **scaled ∂r/∂p** |
|---|---|---|---|---|---|
| `from_dp=true` | `m − g(p_a−p_b)` | `g′` ≈ 1.7e-7 | 1 | ≈ 1 | **1.7e-7** |
| `from_dp=false` | `(p_a−p_b) − f(m)` | 1 | `f′` ≈ 3.1e6 | ≈ `f′` | **3.2e-7** |

Same number to within the factor the two regularizations differ by (`0.375` vs `1/1.40625`). The unscaled Jacobians look entirely different — one row nearly zero in `p`, the other nearly infinite in `m` — but scaling maps one onto the other, because both encode the same physical statement: this valve's conductance is ~1e-7 kg/s/Pa, so it tells you almost nothing about the node pressure.

Absolute slopes at the plant's check-valve sizing (`m_flow_nominal=23.9`, `dpValve_nominal=1E4`, `l=1E-3`, `deltaM=0.02`): `ddp/dm ≈ 5.95e6` Pa/(kg/s) at `dp=0` as built, versus `≈ 3.14e6` if reformulated. Same order of magnitude.

The existing quintic-Hermite transition is also already well behaved — min `dm/ddp` over the transition ≈ 1.68e-7 > 0 (strictly monotonic, invertible), and max `m` over the transition equals `m2_flow` exactly (no overshoot). There is no local defect to repair.

**The earlier φ-scaling experiment tested the converse and confirms it.** Scaling the isolation valve's regularization band with φ softened its `from_dp=false` row (`J_sum` 1.2e5 → 3.4e3) — and the failure moved straight onto the `from_dp=true` check-valve rows, with `valChe[3].dp` becoming culprit in 9/9 simulation blocks at a gap of 1.02 against a header pressure row. Both formulations took a turn as culprit at the same node. Neither cured it.

With compliance in place `from_dp=true` is the *better* form: both ends of the idle check valve become known, so `m = g(Δp)` evaluates explicitly and the leakage leaves the nonlinear block entirely. `dp = f(m)` would make it implicit again, requiring a Newton solve against `f′ ≈ 3e6` to recover ~0.4 g/s.

---

## Q2 — Demonstrate the cause from `HardCase1.log`

### The failing block

```
Nonlinear solver summary, accumulated amounts:
 Tag                                            , Calls, Residues, Iterations, Jacobians
 initialization.nonlinear[3]                    :    11,     1225,       1225,       136
 simulation.nonlinear[1]                        :  6645,    45624,      45624,      9622
 simulation.nonlinear[2]                        :  6626,    19878,      13252,         0
 simulation.nonlinear[4]                        :  6626,    13385,      13385,      6626
 simulation.nonlinear[5]                        :  6626,    16059,      16059,      6626
```

`simulation.nonlinear[1]` is the only pathological block: 6.9 residuals and 1.45 Jacobians per call, against 2.0 and 1.0 for the healthy ones.

### The CHW side is idle for the whole run

Every CHW-side discrete transition, all 86400 s:

```
   1.80  valChiWatIso[1] 1->0
   1.80  valChiWatIso[2] 1->0
   1.80  valChiWatIso[3] 1->0
```

No CHW pump ever starts; no CHW isolation valve ever reopens. The HW side stages up three times:

```
19159.752  pumHeaWat[1] 0->1      20151.752  pumHeaWat[2] 0->1      21143.752  pumHeaWat[3] 0->1
19251.752  hp[1]        0->1      20243.752  hp[2]        0->1      21235.752  hp[3]        0->1
19278.553  valHeaWatIso[1] 0->1   20270.553  valHeaWatIso[2] 0->1   21262.553  valHeaWatIso[3] 0->1
```

### First simulation failure

```
Warning: Failed to solve nonlinear system using Newton solver.
  Time: 20157.88290558289
  Tag: simulation.nonlinear[1]

  The nonlinear solver stopped since:
   * Iteration is not making good progress.
  Accumulated number of residual calculations: 9745
  Accumulated number of symbolic Jacobian calculations: 3667

  Jacobian inverse norm estimate: 1.84968e+08
  Condition number estimate: 2.9314e+08
  1-norm of the residual = 27.5692
  The estimates indicate that the Jacobian is close to singular,
  suggesting that there is no solution.

  Last value of the solution:
    pla.valIso.valHeaWatUniInlIso[1].port_b.p = 268274
    pla.pumPri.pumChiWat.valChe[3].dp = -718.773
    pla.valIso.valHeaWatUniInlIso[3].port_b.p = 353124
    VHeaWat_flow.port_a.m_flow = 14.929
    pla.pumPri.pumHeaWat.valChe[2].dp = -7366.72
    pla.valIso.port_bHeaWat.m_flow = -24.4586
    pla.valIso.port_aChiWat.m_flow = -0.00327533
    pla.port_aChiWat.m_flow = 0.00012244
  Last value of the residual:
    { 0.00213005, 0.00102783, -0.00530856, -0.00633782, 0.00193453,
      0.00283072, 27.5492, 0.00045952 }
```

This failure sits inside the 119 s window between `pumHeaWat[2]` starting (20151.75) and `valHeaWatIso[2]` opening (20270.55) — HW pump 2 running against its own closed isolation valve. Note `port_aChiWat.m_flow` at 1e-4…1e-3 kg/s against `port_bHeaWat.m_flow` at −24.5 kg/s in the same block.

### The idle branch decays into noise

Tracing from the result file across HW pressurization:

```
      t   valChe[3].dp   CHWleak m   idleNode p   HW m_flow
19159.8            0     0.000e+00      351325           0    all pumps off
19180.8        138.9     4.986e-04      331489      -13.35   HW pump 1 on
20151.8        170.2     9.092e-04      322883      -24.45
20153.8        119.2     1.385e-03      351165      -24.46   HW pump 2 on
21145.6        290.2     2.174e-03      351252      -43.34   HW pump 3 on
21235.8       -642.8     9.565e-06      302236      -55.92
21262.6       -13.96     3.841e-08      303020      -55.93   last HW iso valve opens
21300.0   -7.549e-09     3.820e-16      303136      -55.87
21563.7   -7.054e-09     3.548e-16      303808      -55.48
21743.8   -1.287e-08     6.460e-16      305183      -54.67
21833.8    8.436e-09    -4.103e-16      306296      -54.01
21945.6    1.403e-08    -7.079e-16      307939      -53.02
```

Three observations. While everything is off the branch sits at the exact trivial solution and converges fine, with the idle node holding 351325 Pa — its start value, determined by nothing. Once the HW side pressurizes the node wanders 302–351 kPa with no physical driver, kicked ~30 kPa by each pump start. After the last isolation valve opens it collapses to `dp ≈ 1e-8 Pa`, `m ≈ 1e-16 kg/s`, sign flipping randomly between samples — roundoff, not a solution, in the same block as a 53 kg/s flow. Seventeen decades.

### Terminal stall

```
   t        iso[1].p  iso[3].p   VHeaWat  valChe[2].dp  port_bHeaWat | valChe[3].dp  pla.port_aChiWat.m_flow
22018.04     309071    309072    35.4048     13630.2      -52.3193   |   -2786.2          -2.818e-06
22016.46     309046    309046    35.4225     13638.2      -52.3346   |   -2486.6           8.238e-05
22016.07     309040    309041    35.4270     13640.2      -52.3385   |   -2129.4           3.427e-06
22015.97     309039    309039    35.4281     13640.7      -52.3394   |   -2226.7          -6.704e-07
22015.94     309039    309039    35.4284     13640.9      -52.3397   |   -2241.4          -4.746e-06
22015.9351   309039    309039    35.4285     13640.9      -52.3397   |   -2241.4           5.200e-06
22015.9347   309038    309038    35.4285     13640.9      -52.3397   |   -2231.4           3.606e-05
22015.9346   309039    309039    35.4285     13640.9      -52.3398   |   -2243.3           4.083e-05
```

The HW unknowns go bit-identical while the integrator bisects; only the idle CHW quantities still move, rattling over two decades at random sign. Then:

```
SUNDIALS: CVODE CVode At t = 22015.9 repeated recoverable right-hand side function errors.
Integration terminated unsuccesfully at T = 22015.9
```

**Refinement to the hypothesis.** Of three failure clusters only the first coincides with staging, and it is a stage-*up*, not a stage-down. Clusters 2 (21690, 21861) and 3 (22014–22018, fatal) have no discrete transition within 750 s. The fatal case is the quiescent one. So the idle branch has no determined solution at *any* time once the active loop is pressurized; staging merely perturbs it hard enough to expose it early.

---

## Q3/Q4 — Why can't the solver progress? And isn't the condition number fine?

The condition number objection was correct and forced a revision.

### All 18 simulation failures

```
        time      ||J^-1||       cond      |r|_1   stop reason
        init     8.151e+11   2.272e+07     299.1   maxcalls
 20157.88290     1.850e+08   2.931e+08     27.57   progress
 20160.27506     1.219e+08   1.924e+08      11.7   progress
 20159.48140     1.849e+08   2.931e+08     14.83   progress
 20160.20254     1.888e+08   2.999e+08     16.14   progress
 20160.06503     1.860e+08   2.955e+08     17.27   progress
 20167.49885     3.443e+08   5.419e+08     26.79   progress
 20166.80713     2.234e+08   3.504e+08     9.249   progress
 21690.26598     8.220e+05   2.867e+06    0.3666   maxcalls
 21861.08277     8.615e+07   1.153e+08     2.969   maxcalls
 22014.08024     1.039e+06   1.870e+06     16.81   maxcalls
 22018.04390     8.404e+05   2.590e+06     4.185   maxcalls
 22016.46193     4.404e+06   5.064e+06      22.6   maxcalls
 22016.06644     8.245e+05   1.526e+06     4.615   maxcalls
 22015.96757     6.232e+08   1.773e+09     2.043   maxcalls
 22015.94285     8.014e+05   1.422e+06     5.428   maxcalls
 22015.93667     8.014e+05   2.239e+06     1.483   maxcalls
 22015.93512     6.238e+08   8.787e+08     5.683   maxcalls
 22015.93474     6.239e+08   8.568e+08     14.95   maxcalls
 22015.93464     8.015e+05   1.263e+06     15.91   maxcalls
```

Two modes, which I had conflated. The **first cluster** (survived) runs at cond 2–5e8 and stops on `not making good progress`. The **terminal cluster** (fatal) frequently runs at cond ≈ 1.3e6 — where the linear algebra is perfectly sound — and stops on `maximum allowed number of function calls`. The run did not die of ill-conditioning.

### Row-norm analysis

Row scale factors, first cluster and terminal failure:

```
                first cluster        terminal
row 1   J_sum=334.832            J_sum=529.818
row 2   J_sum=5.42149            J_sum=407.176
row 3   J_sum=90.4671            J_sum=269.265
row 4   J_sum=91.3169            J_sum=270.375
row 5   J_sum=95.0253            J_sum=282.416
row 6   J_sum=16.844             J_sum=16.8456     ← constant
row 7   J_sum=1.65736e+07        J_sum=1.65737e+07 ← constant
row 8   J_sum=51.5558            J_sum=91.2626
Condition estimate  4.278e+08        9.255e+08
```

Two rows are structural constants across the entire run. Row 7 is pinned to six digits over ~6700 Jacobian evaluations spanning every staging event:

```
3672 ×  J_sum=1.65737e+07
2820 ×  J_sum=1.65736e+07
 208 ×  J_sum=1.65735e+07
```

It is `O(1/l²)` on the closed isolation valves' leakage conductance (`l = 1E-4`), which never changes. Ratio to the smallest row: `1.65737e7 / 16.8456 = 9.84e5`.

**Row scaling inverts which row looks like the culprit.** Raw, row 7 dominates by five decades (`|r|₁ = 15.91`, essentially all of it row 7). Scaled, row 7 drops to the same order as rows 1–5 and 8 while row 6 comes out on top. That is why the diagnosis flipped: the two numbers describe the same state and disagree by six decades.

The exact arithmetic — including the row scales printed immediately before that residual rather than from a neighbouring iterate, and the `+1` guard term in the scale factor — is in **Q8**, which reproduces Dymola's own `Scaled residual` to seven digits and identifies the row and the variable.

### The real diagnostic

First cluster:
```
Scaled residual 0.4382016519688745
Old Residual 0.005926955821160649
Predicted relative decrease 1
Actual relative decrease -72.933679479167

Predicted relative decrease 0.5790656000186933
Actual relative decrease -50.47200540557327

Predicted relative decrease 0.3683882061877675
Actual relative decrease -34.32736018235349
```

Terminal cluster:
```
Scaled residual 2.330951404801547E-05
Old Residual    2.313790109719105E-05
Predicted relative decrease  0.01580147540007537
Actual relative decrease    -0.007416962761815027
```

These are different pathologies. In the first cluster the linear model claims it can eliminate the residual (`predicted 1`) and the step then overshoots by 30–70× — genuine ill-conditioning plus nonlinearity. In the terminal cluster the scaled residual is already 2.3e-5, only ~20× from tolerance, and **the model itself forecasts it can remove just 1.6%**. A Newton direction that cannot reduce the residual means `r` has a component outside `range(J)`: rank deficiency and inconsistency, not conditioning.

The first cluster also shows a closed limit cycle — iterates return to their start with a bit-identical residual:

```
valHeaWatUniInlIso[1].port_b.p = 268297   ← start
  Residual { 3.19744E-14, -3.90313E-18, 1.66533E-15, -0.0136478, 0.56896, ... }
    → 268274  (iso[3].p 351197 → 323783;  residual row 4:  -0.0136 → 40.4496)
    → 268744
    → 268980
    → 268297   ← same point, same residual verbatim
```

Why modest cond and rank deficiency coexist: Dymola's condition estimate is computed on the **row-scaled** matrix — precisely the operation that divides the degenerate row by its own row norm and makes it look like any other. Scaling changes the numbers, not the information content.

The caveat that stood here — whether the `Condition number estimate` in the failure header and the `Condition estimate of Jacobian matrix` printed after the scaling rows are the same quantity — is resolved in **Q8**. They are not: the header value is a cheap LU-based underestimate, low by ~660×.

---

## Q5 — The NL iteration variable listing

```
System simulation.nonlinear[1]:

The equation system depends on the following timevarying variables:
loaCoo.con.val.valEqu.k
loaHea.con.val.valEqu.k
pla.pumPri.pumChiWat.pum[1].motSpe.y
pla.pumPri.pumChiWat.pum[2].motSpe.y
pla.pumPri.pumChiWat.pum[3].motSpe.y
pla.pumPri.pumHeaWat.pum[1].motSpe.y
pla.pumPri.pumHeaWat.pum[2].motSpe.y
pla.pumPri.pumHeaWat.pum[3].motSpe.y
pla.valChiWatMinByp.lin.kVal
pla.valHeaWatMinByp.lin.kVal
pla.valIso.valChiWatUniInlIso[1].lin.k
pla.valIso.valChiWatUniInlIso[2].lin.k
pla.valIso.valChiWatUniInlIso[3].lin.k
pla.valIso.valHeaWatUniInlIso[1].lin.k
pla.valIso.valHeaWatUniInlIso[2].lin.k
pla.valIso.valHeaWatUniInlIso[3].lin.k

Iteration variables:
pla.port_aChiWat.m_flow(start = 0.0)                      ← CHW (dead)
pla.pumPri.pumChiWat.valChe[3].dp(start = 0.0)            ← CHW (dead)
pla.valIso.port_aChiWat.m_flow(start = 0.0)               ← CHW (dead)
pla.pumPri.pumHeaWat.valChe[2].dp(start = 0.0)              HW
pla.valIso.port_bHeaWat.m_flow(start = 0.0)                 HW
VHeaWat_flow.port_a.m_flow(start = 0.0)                     HW
pla.valIso.valHeaWatUniInlIso[1].port_b.p(start = 300000)   shared HP inlet node
pla.valIso.valHeaWatUniInlIso[3].port_b.p(start = 300000)   shared HP inlet node
```

**Three of the eight unknowns belong to a circuit switched off for the entire run.** Split 3 CHW / 3 HW / 2 shared. The solver is asked at every step for a full simulated day to determine three quantities nothing determines.

All three CHW isolation-valve conductances enter as inputs. When those valves are shut, `lin.k = l·k_nominal` with `l = 1E-4`, and those `k` values are the *only* coupling between the CHW unknowns and anything else — the structural source of the `J_sum = 1.657e7` constant. All three CHW pump speeds are also inputs, all zero.

The listing is alphabetical, so it does not pin the row↔unknown pairing; that still rests on Dymola's convention of printing the residual in solver order.

Sizes:
```
Continuous time states: 89 scalars
Sizes of nonlinear systems of equations: {52, 43, 43, 3, 3, 3}
Sizes after manipulation of the nonlinear systems: {8, 1, 1, 1, 1, 1}

Initialization problem
Sizes of nonlinear systems of equations: {3, 3, 58, 1, 1, 49, 49}
Sizes after manipulation of the nonlinear systems: {1, 1, 9, 0, 0, 1, 1}
```

A 52-equation system torn to 8 iteration variables — each residual back-substitutes through ~44 equations, so its noise floor accumulates along that chain rather than being one subtraction's worth of epsilon.

**Every failure reports `symbolic Jacobian calculations`**, never numerical. With an exact analytic Jacobian, `Predicted relative decrease = 0.016` cannot be blamed on finite-difference noise. The linearization is correct and still says it can remove only 1.6%. The true Jacobian is rank-deficient.

Chain: dead circuit → unknowns survive the tearing → only coupling is a fixed leakage conductance → rows degenerate → `r ∉ range(J)` → residual floor → 1000 calls → give up.

---

## Q6 — The Compliance variant

```
System simulation.nonlinear[1]:

The equation system depends on the following timevarying variables:
loaCoo.con.val.valEqu.k
pla.pumPri.pumChiWat.pum[1..3].motSpe.y
pla.pumPri.pumHeaWat.pum[1..3].motSpe.y
pla.valChiWatMinByp.lin.kVal
pla.valIso.comChiWatSup.p                    ← now a state, supplied as input
pla.valIso.comHeaWatSup.p                    ← now a state, supplied as input
pla.valIso.valChiWatUniInlIso[1..3].lin.k
pla.valIso.valHeaWatUniInlIso[1..3].lin.k

Iteration variables:
pla.port_aChiWat.m_flow(start = 0.0)
pla.pumPri.pumChiWat.valChe[1].dp(start = 0.0)
pla.pumPri.pumChiWat.valChe[2].dp(start = 0.0)
pla.pumPri.pumChiWat.valChe[3].dp(start = 0.0)
pla.pumPri.pumHeaWat.valChe[1].dp(start = 0.0)
pla.pumPri.pumHeaWat.valChe[2].dp(start = 0.0)
pla.pumPri.pumHeaWat.valChe[3].dp(start = 0.0)
pla.valIso.port_aChiWat.m_flow(start = 0.0)

System simulation.nonlinear[2]:
The equation system depends on the following timevarying variables:
loaHea.con.val.valEqu.k
pla.valIso.comHeaWatSup.p

Iteration variables:
VHeaWat_flow.port_a.m_flow(start = 0.0)
```

**Both floating node pressures are gone from the block.** `valHeaWatUniInlIso[1].port_b.p` and `[3].port_b.p` are no longer unknowns; `comChiWatSup.p` and `comHeaWatSup.p` appear instead as time-varying inputs, i.e. states. What remains contains **no absolute pressure at all** — only six check-valve pressure *drops*, each bracketed by two now-known endpoints, plus the two CHW return flows. `VHeaWat_flow.port_a.m_flow` was evicted into its own scalar block.

```
                              baseline              compliance
Continuous time states        89                    91
Nonlinear systems             {52, 43, 43, 3,3,3}   {45, 3, 43, 43, 3,3,3}
  after manipulation          { 8,  1,  1, 1,1,1}   { 8, 1,  1,  1, 1,1,1}
Init nonlinear systems        {3,3,58,1,1,49,49}    {3,3,51,1,49,3,1,49}
  after manipulation          {1,1, 9,0,0, 1, 1}    {1,1, 5,0, 1,1,0, 1}
```

Note the block got structurally *wider* in valve count (all six check valves instead of two) yet is far better posed. The problem was never the check valves — independently confirming Q1.

```
 Tag                        , Calls, Residues, Iterations, Jacobians
 initialization.nonlinear[1]:     1,        9,          9,         1
 initialization.nonlinear[2]:     1,        9,          9,         1
 initialization.nonlinear[3]:     1,        2,          2,         1
 initialization.nonlinear[4]:     1,        3,          2,         0
 initialization.nonlinear[5]:     1,        2,          2,         1
 initialization.nonlinear[6]:     1,        3,          2,         0
 simulation.nonlinear[1]    : 96022,   317424,     317424,     96155
 simulation.nonlinear[2]    : 96022,   250482,     250482,     96022

SUCCESSFUL simulation of ...HardCase1Compliance
```

Zero NL failures. Per-call health improves from 6.87 residuals / 1.45 Jacobians to 3.31 / 1.00. Initialization is the sharpest contrast: the baseline burned 1225 residuals and 136 Jacobians on `initialization.nonlinear[3]` and still failed at `|r|₁ = 299`; under compliance every init block converges in one call with 2–9 residuals.

---

## Q7 — Clean timings (NL debug logging suppressed)

The debug flags dump full Jacobians; logs ran 40–426 MB and the CPU figures were measuring disk I/O.

```
                 with NL debug    clean      ratio
Linearized           53.37 s      3.48 s      15×
Leakage              53.31 s      3.39 s      16×
Compliance           86.72 s      4.07 s      21×
baseline              5.78 s      0.37 s      16×
```

Not a uniform tax — Compliance was penalized hardest precisely because it takes the most steps, so the *ranking* was distorted, not just the magnitudes. Step counters are unaffected (bit-identical between logged and clean runs), so every counter-based conclusion above stands.

| variant | CPU (s) | accepted | rejected | f-evals | Jac | NLcf | state ev | outcome |
|---|---|---|---|---|---|---|---|---|
| baseline | 0.37 / 0.38 | 1263 | 72 | 1973 | 94 | 69 | 13 | **FAILED** @ 22015.9 |
| Leakage | 3.39 / 5.05 | 15932 | 564 | 24309 | 1353 | 886 | 139 | OK |
| Linearized | 3.48 / 3.76 | 16895 | 575 | 25737 | 1388 | 926 | 134 | OK |
| Compliance `C=1E-5` | 4.07 / 4.13 | 21158 | 824 | 31234 | 1410 | 894 | 143 | OK |
| Compliance `C=1E-4` | 4.07 / 5.14 | 20188 | 1004 | 30992 | 1522 | 1005 | 147 | OK |

CPU varies ±25–50% between identical repetitions; step counters are exactly reproducible and are the metric to use. Normalized f-evaluations per simulated second: Leakage 1.00×, Linearized 1.06×, Compliance 1.28×, HighC 1.27×. **Compliance costs ~21–28%, not the 63% the dirty numbers implied.**

**The `C = 1E-4` suggestion was wrong.** I predicted raising C would lengthen τ = C/g and cut cost. Rejected steps 824 → 1004, Jacobian evaluations 1410 → 1522, NL convergence failures 894 → 1005 — all worse; accepted steps and f-evaluations essentially unchanged. The junction pressure is not behaving as a first-order lag against a fixed conductance. No free tuning win; `C = 1E-5` is the better default.

Also corrected: the initialization improvement is real in iteration count but free in time — init CPU is 0.31–0.33 s for every variant including the baseline. It is a robustness result, not a performance one.

*Caveat on the baseline row: its low counters are an artifact of dying at 25% of the run. All three fixes take ~3–4× more steps per unit time than the baseline was taking before it failed — it was taking large steps precisely because it was mis-resolving the idle branch, right up until it couldn't.*

---

## Q8 — How do the estimates corroborate a degenerate direction `J·d ≈ 0`, how do they relate to the unscaled residual, and which variable is at cause?

Source: the terminal stall window, `HardCase1.log:1237595-1238010`, i.e. the last failure in the table above (t = 22015.93464, `cond 1.263e6`, `|r|₁ = 15.91`).

```
Warning: Failed to solve nonlinear system using Newton solver.
  Time: 22015.93464026791
  Tag: simulation.nonlinear[1]

  The nonlinear solver stopped since:
   * Number of calls to nonlinear solver DymNL has reached or exceeded
     the maximum allowed number of function calls= 900
  Accumulated number of residual calculations: 45624
  Accumulated number of symbolic Jacobian calculations: 9622

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
```

### Both estimates are computed on the row-equilibrated Jacobian

`cond / ‖J⁻¹‖ = 1.26339e6 / 801468 = 1.5763`, so `‖J‖₁ ≈ 1.58`. For an 8×8 matrix whose rows have been divided by their own row-sums, `‖J‖₁` (max column sum) must lie in [1, 8]. The raw matrix has entries up to 1e5. So the pair in the failure header describes the **scaled** system — which matters, because it means the 1.26e6 is what survives equilibration, not a units artifact.

`‖J⁻¹‖₁ = 8.01e5` against `‖J‖₁ = 1.58` says there is a unit-norm direction `d` with `‖J d‖ ≈ 1.25e-6`. On an equilibrated matrix a healthy value is O(1)–O(10). That direction is `J d ≈ 0`.

### The degeneracy is structural, not a transient scaling artifact

The log prints a second, sharper estimate immediately after the scale lines. Over the terminal stall:

| line | `J_sum` row 6 | `J_sum` row 7 | `Condition estimate of Jacobian matrix` |
|---|---|---|---|
| 1236679 | 16.8491 | 1.43252e5 | 834877168.5 |
| 1236780 | 16.8479 | 1.96391e6 | 834933739.7 |
| 1236913 | 16.8491 | 1.42422e5 | 834876622.6 |
| 1237014 | 16.8479 | 1.79679e6 | 834933648.9 |
| 1237147 | 16.8491 | 1.42853e5 | 834877074.8 |
| 1237248 | 16.8479 | **1.31978e7** | 834934010.0 |
| 1237381 | 16.8491 | 1.41228e5 | 834874794.9 |
| 1237482 | 16.8479 | 9.33603e5 | 834932157.5 |
| 1237615 | 16.8491 | 1.46604e5 | 834879231.4 |
| 1237716 | 16.8480 | 6.37866e5 | 834931850.9 |

Row 7's own magnitude swings **two decades** between adjacent iterates and the condition estimate does not move in the 6th significant digit. A near-singularity invariant to a 100× change in one row's scale is a fixed rank defect, not a scaling artifact.

This also settles the Q3/Q4 caveat and the original "the condition number isn't that bad" objection: there are two estimates and they disagree by 662×. `Condition number estimate: 1.26339e+06` in the failure header is the cheap LU-based 1-norm estimator, which underestimates. The accurate value is `8.349e+08`. The number printed in the error message is the optimistic one.

### Relation to the unscaled residual — the ranking inverts

Dymola scales row *i* by `J_sum_i + 1` (the `+1` is a zero-row guard) and converges on the **Euclidean** norm of the result:

| row | `|r_i|` as printed | `J_sum_i` | scaled `r_i` |
|---|---|---|---|
| 1 | 2.181e-04 | 1203.66 | -1.810e-07 |
| 2 | 2.787e-04 | 881.855 | -3.157e-07 |
| 3 | 1.013e-04 | 242.651 | -4.159e-07 |
| 4 | 8.250e-05 | 243.776 | +3.370e-07 |
| 5 | 2.776e-04 | 291.557 | -9.489e-07 |
| **6** | **5.795e-04** | **16.848** | **+3.247e-05** |
| **7** | **15.9073** | **637866** | **+2.494e-05** |
| 8 | 2.916e-05 | 107.157 | -2.696e-07 |

2-norm = **4.095941e-05**, matching the log's `Scaled residual 4.095940326241184E-05` to 7 digits; 1-norm of the raw column = 15.90887, matching `1-norm of the residual = 15.9088`. The reconstruction is exact, so the scale factors and the norm convention are confirmed.

Two consequences:

- **The headline `15.9088` is 99.99% row 7 alone**, and in the solver's own metric row 7 (2.49e-5) is *smaller* than row 6 (3.25e-5), whose unscaled residual is 27,000× less. Row 7 is a pressure-balance row across a path whose resistance is 1.4e5–1.5e7 Pa/(kg/s); a flow error of 1e-4 kg/s renders as ~16 Pa. Ranking rows by the printed residual is backwards.
- **The printed residual grows while the solver converges.** Last four iterations:

  | | `|r|₁` printed | scaled norm | predicted / actual decrease |
  |---|---|---|---|
  | −3 | 4.857 | 7.253e-05 | — |
  | −2 | 7.386 | 6.193e-05 | 0.1584 / 0.1461 |
  | −1 | 11.293 | 5.332e-05 | 0.0583 / 0.1390 |
  | final | 15.909 | 4.096e-05 | 0.2318 / 0.2318 |

  Predicted ≈ actual, so the linear model is accurate — this is *not* a linesearch breakdown, unlike the first cluster in Q3/Q4. It is Newton degenerating to **linear convergence at ~0.8 per step** instead of quadratic: the signature of a Jacobian singular *at the root*, not merely ill-conditioned en route. It then hit `maximum allowed number of function calls = 900`.

### The variable at cause

Between the iterates at `HardCase1.log:1237599` and `:1237621` every printed unknown is identical to six digits except the two CHW flows, and `pla.valIso.port_aChiWat.m_flow` moves 600× less than `pla.port_aChiWat.m_flow`. That gives a clean finite-difference column for the latter, Δm = −2.5307e-05 kg/s:

```
pla.valIso.port_aChiWat.m_flow = -0.00111192      -0.00111188
pla.port_aChiWat.m_flow        =  7.20954E-05      4.67887E-05
Residual { -2.68551e-4,  3.37876e-4, -5.32015e-5,  3.4075e-5,
           -7.14633e-6,  8.44585e-5,  21.1384,     2.64215e-5 }
Residual { -9.04813e-4,  9.49964e-4, -3.09143e-4,  2.89955e-4,
           -1.64073e-5,  4.84771e-4,  17.0292,     2.24525e-5 }
```

| row | ∂r/∂m | `J_sum` | **concentration** `|∂r/∂m| / J_sum` | root in m |
|---|---|---|---|---|
| 1 | 2.51e+01 | 1203.7 | 0.021 | +8.28e-05 |
| 2 | −2.42e+01 | 881.8 | 0.027 | +8.61e-05 |
| 3 | 1.01e+01 | 242.7 | 0.042 | +7.74e-05 |
| 4 | −1.01e+01 | 243.8 | 0.041 | +7.55e-05 |
| 5 | 3.66e-01 | 291.6 | 0.001 | +9.16e-05 |
| **6** | **−1.58e+01** | **16.85** | **0.939** | **+7.74e-05** |
| **7** | **1.62e+05** | **146604** | **1.108** | **−5.81e-05** |
| 8 | 1.57e-01 | 107.2 | 0.001 | −9.64e-05 |

Rows 6 and 7 — the only two rows carrying meaningful scaled residual — put **94% and ~100% of their entire row norm into the single column `pla.port_aChiWat.m_flow`**. After equilibration they are therefore both ≈ ±`e_m`: **near-duplicate rows**. That is the rank-1 defect, and it explains why it is scale-invariant — normalizing row 7 to unit norm leaves it pointing at `e_m` whether its raw magnitude is 1.4e5 or 1.3e7. (Row 7's concentration of 1.108 exceeds 1 because the finite difference spans an interval over which the slope itself varies from 9.7e5 down to 2.3e5; take it as ≈1.)

And the two duplicated rows are **inconsistent**: row 6 wants `m = +7.74e-05 kg/s`, row 7 wants `m = −5.81e-05 kg/s`, roots 1.36e-04 kg/s apart. Two equations, one effective unknown, no common root — exactly what Dymola reports as *"close to singular, suggesting that there is no solution."*

The linesearch probe confirms it independently. Along the Newton direction over α ∈ [−0.084, +0.092] the scaled norm only wanders in [3.75e-05, 4.55e-05], never approaching zero, with its minimum at the interval boundary:

```
Search direction{ -5.421E-05, 0.000196422, -9.96558E-05, -3.14915E-10, 2.57407E-06,
  4.85495E-09, -2.94299E-09, 2.02519E-08 }

 alpha        ||r||_scaled     r_6          r_7
  0           4.0959e-05    3.2471e-05   2.4938e-05
 +0.0919      4.5535e-05    3.9679e-05   2.2291e-05
 -0.0836      3.7529e-05    2.5918e-05   2.7121e-05
```

Components 6 and 7 move in exact anti-correlation; all other components stay pinned at 1e-07. Residual can only be shuttled between rows 6 and 7, never removed.

**The variable at cause is `pla.port_aChiWat.m_flow`** — the plant CHW inlet flow, 4.08e-05 kg/s against a 52 kg/s HW flow, i.e. numerical zero, on the branch closed at both ends since t = 1.8 s. Over the stall it drifts −3.8e-06 → 8.8e-06 → 2.06e-05 → 4.08e-05, doubling each iteration with no restoring force. Its two companions in the dead branch, `pla.valIso.port_aChiWat.m_flow` (−1.11e-03) and `pla.pumPri.pumChiWat.valChe[3].dp` (−2243 Pa), contribute nothing that could restore rank.

### What this supersedes

The Q3/Q4 row-norm table paired the terminal residual with row scales from a neighbouring iterate (`J_sum₇ = 1.657e7`) rather than the ones printed immediately before it (`6.37866e5`), and reported the 1-norm of the scaled vector against Dymola's 2-norm. Corrected here. The physical conclusion is unchanged; what is new is that the culprit row is now identified empirically rather than inferred, and `J_sum₇` is **not** constant at the terminal stall — it alternates 1.4e5 ↔ 1.5e7 between consecutive iterates, because the leakage law is being sampled in its regularization band where the derivative is violently nonlinear. Duplicate row *and* unbounded coefficient.

---

## Summary

The idle CHW branch has no pressure reference. Its unknowns survive the tearing into `simulation.nonlinear[1]`, where their only coupling to the system is a leakage conductance — `J_sum₇` runs from 1.4e5 to 1.5e7 Pa/(kg/s) depending on where the regularized leakage law is sampled. Two rows of the block (6 and 7) end up with 94% and ~100% of their row norm in the single column `pla.port_aChiWat.m_flow`, so after equilibration they are near-duplicate rows demanding mutually inconsistent values of it (+7.7e-05 vs −5.8e-05 kg/s). `r` therefore has a component outside `range(J)`, the residual acquires a floor Newton cannot cross, convergence degrades from quadratic to linear at ~0.8 per step, and the solver exhausts its call budget.

The condition number in the failure header looks benign for two compounding reasons: it is computed after row scaling, which divides the degenerate row by its own norm, and it is a cheap LU-based estimator that undershoots the true value by ~660× (1.26e6 reported vs 8.35e8 actual). The printed `1-norm of the residual` is unscaled and is 99.99% one row, so it *grows* monotonically while the solver is in fact making slow progress. Neither number is the right one to read; `predicted relative decrease` and the row-scaled residual are.

The `Compliance` element fixes it by making the supply-junction pressures states, removing both pressure unknowns from the algebraic block: not by conditioning those rows better, but by deleting them.
