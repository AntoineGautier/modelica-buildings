#!/usr/bin/env python3
"""Compare two Dymola result files over the trajectories listed in
Resources/Scripts/Dymola/.../AirToWaterReversibleHeatRecovery.mos.

Run A is drawn solid, run B dotted.  Panels can be folded away individually.

    python3 plot_compare_hardcase1.py           # Dash app on 127.0.0.1:8051
    python3 plot_compare_hardcase1.py --html    # static HTML, all panels
"""
import sys

sys.path.insert(0, "/home/reituag/gitrepo/BuildingsPy")

import plotly.graph_objects as go
from buildingspy.io.outputfile import Reader
from plotly.subplots import make_subplots

RUN_A = ("Buildings/HardCase1.mat", "Base")
RUN_B = ("HardCase1Leakage.mat", "Leakage")
RUN_B = ("HardCase1Linearized.mat", "Linearized")
RUN_B = ("HardCase1Compliance.mat", "Compliance")
OUT = "AirToWaterReversibleHeatRecovery_compare.html"
PORT = 8051

K = 273.15

# Panels: (title, unit, kind, [(variable, legend name[, lane label]), ...], offset, scale)
# kind: "lin" continuous, "stp" stepped, "bin" stepped binary shown as a
# timing diagram with one lane per signal.
PANELS = [
    ("Outdoor air temperature and lockouts", "°C", "lin", [
        ("pla.ctl.ctl.TOut", "TOut"),
        ("pla.ctl.ctl.TOutChiWatLck", "TOutChiWatLck"),
        ("pla.ctl.ctl.TOutHeaWatLck", "TOutHeaWatLck"),
    ], -K, 1),
    ("Capacity requirement vs. installed capacity", "kW", "lin", [
        ("pla.ctl.ctl.chaStaHea.capReq.QReq_flow", "QReq_flow heating"),
        ("pla.ctl.ctl.chaStaCoo.capReq.QReq_flow", "QReq_flow cooling"),
        ("pla.capHea_nominal", "capHea_nominal"),
        ("pla.capCoo_nominal", "capCoo_nominal"),
    ], 0, 1e-3),
    ("Load signals", "1", "lin", [
        ("loaHea.u", "loaHea.u"),
        ("loaHea.yLoa_actual", "loaHea.yLoa_actual"),
        ("loaCoo.u", "loaCoo.u"),
        ("loaCoo.yLoa_actual", "loaCoo.yLoa_actual"),
    ], 0, 1),
    ("Plant requests", "count", "stp", [
        ("pla.ctl.ctl.nReqPlaHeaWat", "nReqPlaHeaWat"),
        ("pla.ctl.ctl.nReqPlaChiWat", "nReqPlaChiWat"),
    ], 0, 1),
    ("Plant enable", "", "bin", [
        ("pla.ctl.ctl.enaHea.y1", "enaHea.y1", "Hea"),
        ("pla.ctl.ctl.enaCoo.y1", "enaCoo.y1", "Coo"),
    ], 0, 1),
    ("Stage index", "stage", "stp", [
        ("pla.ctl.ctl.idxStaHea.y", "idxStaHea.y"),
        ("pla.ctl.ctl.idxStaCoo.y", "idxStaCoo.y"),
    ], 0, 1),
    ("Heat pump enable", "", "bin", [
        ("pla.ctl.ctl.y1Hp[1]", "y1Hp[1]", "[1]"),
        ("pla.ctl.ctl.y1Hp[2]", "y1Hp[2]", "[2]"),
        ("pla.ctl.ctl.y1Hp[3]", "y1Hp[3]", "[3]"),
    ], 0, 1),
    ("Heat pump heating mode", "", "bin", [
        ("pla.ctl.ctl.y1HeaHp[1]", "y1HeaHp[1]", "[1]"),
        ("pla.ctl.ctl.y1HeaHp[2]", "y1HeaHp[2]", "[2]"),
        ("pla.ctl.ctl.y1HeaHp[3]", "y1HeaHp[3]", "[3]"),
    ], 0, 1),
    ("Dedicated primary HW pumps", "", "bin", [
        ("pla.ctl.ctl.y1PumHeaWatPriDedHp[1]", "y1PumHeaWatPriDedHp[1]", "[1]"),
        ("pla.ctl.ctl.y1PumHeaWatPriDedHp[2]", "y1PumHeaWatPriDedHp[2]", "[2]"),
        ("pla.ctl.ctl.y1PumHeaWatPriDedHp[3]", "y1PumHeaWatPriDedHp[3]", "[3]"),
    ], 0, 1),
    ("Dedicated primary CHW pumps", "", "bin", [
        ("pla.ctl.ctl.y1PumChiWatPriDedHp[1]", "y1PumChiWatPriDedHp[1]", "[1]"),
        ("pla.ctl.ctl.y1PumChiWatPriDedHp[2]", "y1PumChiWatPriDedHp[2]", "[2]"),
        ("pla.ctl.ctl.y1PumChiWatPriDedHp[3]", "y1PumChiWatPriDedHp[3]", "[3]"),
    ], 0, 1),
    ("Reset requests", "count", "stp", [
        ("pla.ctl.ctl.nReqResHeaWat", "nReqResHeaWat"),
        ("pla.ctl.ctl.nReqResChiWat", "nReqResChiWat"),
    ], 0, 1),
    ("Remote differential pressure", "kPa", "lin", [
        ("pla.bus.dpHeaWatRem[1]", "dpHeaWatRem[1]"),
        ("pla.bus.dpHeaWatRemSet[1]", "dpHeaWatRemSet[1]"),
        ("pla.bus.dpChiWatRem[1]", "dpChiWatRem[1]"),
        ("pla.bus.dpChiWatRemSet[1]", "dpChiWatRemSet[1]"),
    ], 0, 1e-3),
    ("Heat pump part load ratio", "1", "lin", [
        ("pla.hp.hp[1].hp.PLR", "hp[1].PLR"),
        ("pla.hp.hp[2].hp.PLR", "hp[2].PLR"),
        ("pla.hp.hp[3].hp.PLR", "hp[3].PLR"),
    ], 0, 1),
    ("Heat pump power", "kW", "lin", [
        ("pla.hp.hp[1].hp.P", "hp[1].P"),
        ("pla.hp.hp[2].hp.P", "hp[2].P"),
        ("pla.hp.hp[3].hp.P", "hp[3].P"),
    ], 0, 1e-3),
    ("Primary HW pump power", "kW", "lin", [
        ("pla.pumPri.pumHeaWat.pum[1].P", "pumHeaWat[1].P"),
        ("pla.pumPri.pumHeaWat.pum[2].P", "pumHeaWat[2].P"),
        ("pla.pumPri.pumHeaWat.pum[3].P", "pumHeaWat[3].P"),
    ], 0, 1e-3),
    ("Primary CHW pump power", "kW", "lin", [
        ("pla.pumPri.pumChiWat.pum[1].P", "pumChiWat[1].P"),
        ("pla.pumPri.pumChiWat.pum[2].P", "pumChiWat[2].P"),
        ("pla.pumPri.pumChiWat.pum[3].P", "pumChiWat[3].P"),
    ], 0, 1e-3),
    ("HW inlet isolation valve flow", "kg/s", "lin", [
        ("pla.valIso.valHeaWatUniInlIso[1].m_flow", "valHeaWatUniInlIso[1]"),
        ("pla.valIso.valHeaWatUniInlIso[2].m_flow", "valHeaWatUniInlIso[2]"),
        ("pla.valIso.valHeaWatUniInlIso[3].m_flow", "valHeaWatUniInlIso[3]"),
    ], 0, 1),
    ("CHW inlet isolation valve flow", "kg/s", "lin", [
        ("pla.valIso.valChiWatUniInlIso[1].m_flow", "valChiWatUniInlIso[1]"),
        ("pla.valIso.valChiWatUniInlIso[2].m_flow", "valChiWatUniInlIso[2]"),
        ("pla.valIso.valChiWatUniInlIso[3].m_flow", "valChiWatUniInlIso[3]"),
    ], 0, 1),
    ("Heat pump flow", "kg/s", "lin", [
        ("pla.hp.hp[1].m_flow", "hp[1].m_flow"),
        ("pla.hp.hp[2].m_flow", "hp[2].m_flow"),
        ("pla.hp.hp[3].m_flow", "hp[3].m_flow"),
    ], 0, 1),
    ("Heat pump entering HW temperature", "°C", "lin", [
        ("pla.hp.hp[1].THeaWatEnt.T", "hp[1].THeaWatEnt"),
        ("pla.hp.hp[2].THeaWatEnt.T", "hp[2].THeaWatEnt"),
        ("pla.hp.hp[3].THeaWatEnt.T", "hp[3].THeaWatEnt"),
    ], -K, 1),
    ("Hot water temperatures", "°C", "lin", [
        ("pla.bus.THeaWatSupSet", "THeaWatSupSet"),
        ("pla.bus.THeaWatPriSup", "THeaWatPriSup"),
        ("pla.bus.THeaWatPriRet", "THeaWatPriRet"),
    ], -K, 1),
    ("Chilled water temperatures", "°C", "lin", [
        ("pla.bus.TChiWatSupSet", "TChiWatSupSet"),
        ("pla.bus.TChiWatPriSup", "TChiWatPriSup"),
        ("pla.bus.TChiWatPriRet", "TChiWatPriRet"),
    ], -K, 1),
    ("Minimum flow bypass valve", "", "lin", [
        ("pla.valChiWatMinByp.y_actual.y", "valChiWatMinByp.y_actual"),
        ("pla.valHeaWatMinByp.y_actual.y", "valHeaWatMinByp.y_actual"),
    ], 0, 1),
]

# Signals of the .mos script that neither run records.
ABSENT = [
    "pla.ctl.ctl.y1PumHeaWatSec[1:2]", "pla.ctl.ctl.y1PumChiWatSec[1:2]",
    "pla.bus.VHeaWatSec_flow", "pla.bus.VChiWatSec_flow",
    "pla.bus.THeaWatSecSup", "pla.bus.THeaWatSecRet",
    "pla.bus.TChiWatSecSup", "pla.bus.TChiWatSecRet",
    "pla.bus.hrc.y1", "pla.bus.hrc.y1Coo", "pla.hrc.hrc.chi.PLR",
    "pla.bus.hrc.TChiWatSet", "pla.bus.hrc.THeaWatSet",
    "pla.bus.TChiWatRetUpsHrc", "pla.bus.THeaWatRetUpsHrc",
]

LIGHT = dict(
    surface="#fcfcfb", primary="#0b0b0b", secondary="#52514e", muted="#84837c",
    grid="#e8e7e2", zero="#d4d3cc",
    series=["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4"],
)
DARK = dict(
    surface="#1a1a19", primary="#ffffff", secondary="#c3c2b7", muted="#8f8e85",
    grid="#2f2f2d", zero="#3d3d3a",
    series=["#3987e5", "#d95926", "#199e70", "#c98500", "#d55181"],
)


def read(path):
    """Return a lazily-caching accessor over one result file."""
    r = Reader(path, "dymola")
    names = set(r.varNames())
    cache = {}

    def get(name):
        if name not in cache:
            t, v = r.values(name)
            cache[name] = ([x / 3600.0 for x in t], list(v))
        return cache[name]

    return get, names


_RUNS = None


def runs():
    """Read both result files once, on first use."""
    global _RUNS
    if _RUNS is None:
        _RUNS = (read(RUN_A[0]), read(RUN_B[0]))
    return _RUNS


_PANELS = None


def panels():
    """The panels whose signals both runs actually record."""
    global _PANELS
    if _PANELS is None:
        (_, namesA), (_, namesB) = runs()
        _PANELS = [
            (title, unit, kind, keep, off, sca)
            for title, unit, kind, sigs, off, sca in PANELS
            for keep in [[s for s in sigs if s[0] in namesA and s[0] in namesB]]
            if keep
        ]
    return _PANELS


ROW_PX = 210   # vertical budget per panel
MARG_T = 34
MARG_B = 56


def make_figure(selected, theme):
    """Build the whole figure over `selected` panel indices, in `theme` colors."""
    (getA, _), (getB, _) = runs()
    chosen = [panels()[i] for i in selected]
    n = max(len(chosen), 1)

    fig = make_subplots(
        rows=n, cols=1, shared_xaxes=True,
        vertical_spacing=min(0.012 * 16 / n, 0.5),
        subplot_titles=[p[0] for p in chosen] or [""],
    )

    for row, (title, unit, kind, sigs, off, sca) in enumerate(chosen, start=1):
        lane = len(sigs) - 1
        for slot, sig in enumerate(sigs):
            var, label = sig[0], sig[1]
            for get, run, dash in ((getA, RUN_A[1], "solid"),
                                   (getB, RUN_B[1], "dot")):
                t, v = get(var)
                if kind == "bin":
                    y, cd, hov = ([lane - slot + 0.78 * x for x in v], v,
                                  "%{customdata:.0f}")
                else:
                    y, cd, hov = ([(x + off) * sca for x in v], None,
                                  "%{y:.4g}")
                fig.add_trace(
                    go.Scatter(
                        x=t, y=y, customdata=cd,
                        name=f"{label} · {run}",
                        legend=f"legend{row if row > 1 else ''}",
                        mode="lines",
                        line=dict(
                            color=theme["series"][slot % 5], width=1.9, dash=dash,
                            shape="hv" if kind in ("stp", "bin") else "linear",
                        ),
                        hovertemplate=f"<b>{label}</b> · {run}<br>{hov} {unit}"
                                      "<extra></extra>",
                    ),
                    row=row, col=1,
                )
        if kind == "bin":
            fig.update_yaxes(
                row=row, col=1, range=[-0.35, len(sigs) - 0.1],
                tickmode="array", tickvals=list(range(len(sigs))),
                ticktext=[(s[2] if len(s) > 2 else s[1]) for s in reversed(sigs)],
                zeroline=False,
            )
        else:
            fig.update_yaxes(row=row, col=1, title_text=unit, title_standoff=4)
        # Keep a panel's own zoom when other panels are folded in or out.
        fig.update_yaxes(row=row, col=1, uirevision=title)

    fig.update_layout(
        height=MARG_T + MARG_B + ROW_PX * n, width=None,
        margin=dict(l=70, r=270, t=MARG_T, b=MARG_B),
        hovermode="x", showlegend=True,
        paper_bgcolor=theme["surface"], plot_bgcolor=theme["surface"],
        font=dict(color=theme["secondary"]),
    )
    fig.update_xaxes(
        showspikes=True, spikemode="across", spikesnap="cursor",
        spikethickness=1, spikedash="solid", spikecolor=theme["muted"],
        dtick=2, range=[0, 24], uirevision="time",
        gridcolor=theme["grid"], linecolor=theme["grid"],
        zerolinecolor=theme["zero"], tickcolor=theme["grid"],
    )
    fig.update_yaxes(
        gridcolor=theme["grid"], linecolor=theme["grid"],
        zerolinecolor=theme["zero"], tickcolor=theme["grid"],
    )
    if chosen:
        fig.update_xaxes(row=n, col=1, title_text="time (h)")

    # One legend per panel, parked in the right margin beside its own panel.
    for row in range(1, len(chosen) + 1):
        dom = fig.get_subplot(row, 1).yaxis.domain
        fig.update_layout({f"legend{row if row > 1 else ''}": dict(
            x=1.005, xanchor="left", y=dom[1], yanchor="top",
            font=dict(size=10.5, color=theme["secondary"]),
            bgcolor="rgba(0,0,0,0)", borderwidth=0,
            tracegroupgap=0, itemsizing="constant",
        )})
    for ann in fig.layout.annotations:
        ann.update(font=dict(size=13, color=theme["primary"]),
                   x=0, xanchor="left")
    return fig


CSS = """
:root { color-scheme: dark; --surface:%(ds)s; --ink:%(dp)s; --ink2:%(dse)s;
        --ink3:%(dm)s; --rule:%(dg)s; }
body[data-theme="light"] { color-scheme: light; --surface:%(ls)s; --ink:%(lp)s;
        --ink2:%(lse)s; --ink3:%(lm)s; --rule:%(lg)s; }
html, body { margin:0; background:var(--surface); color:var(--ink);
  font:14px/1.5 ui-sans-serif,-apple-system,"Segoe UI",Roboto,sans-serif; }
header { display:flex; align-items:baseline; gap:16px; flex-wrap:wrap;
  padding:14px 20px 10px; border-bottom:1px solid var(--rule); }
header .note { color:var(--ink3); font-size:12.5px; }
#bar { display:flex; align-items:center; gap:8px; flex-wrap:wrap;
  padding:10px 20px; border-bottom:1px solid var(--rule); }
#bar .lab { color:var(--ink3); font-size:12.5px; }
#bar .sep { width:1px; align-self:stretch; background:var(--rule); margin:0 4px; }
button { font:inherit; font-size:12.5px; color:var(--ink2); background:transparent;
  border:1px solid var(--rule); border-radius:6px; padding:4px 10px; cursor:pointer; }
button:hover { color:var(--ink); }
#chips label { display:inline-block; font-size:12.5px; color:var(--ink3);
  border:1px solid var(--rule); border-radius:6px; padding:3px 9px;
  margin:0 6px 6px 0; cursor:pointer; opacity:.6; }
#chips label:has(input:checked) { color:var(--ink); border-color:var(--ink3); opacity:1; }
#chips input { position:absolute; opacity:0; width:0; height:0; }
#absent { padding:10px 20px 24px; color:var(--ink3); font-size:12.5px; }
code { font-size:12px; }
"""

INDEX = """<!DOCTYPE html>
<html>
<head>{%%metas%%}<title>{%%title%%}</title>{%%favicon%%}{%%css%%}
<style>%s</style></head>
<body data-theme="light">{%%app_entry%%}<footer>{%%config%%}{%%scripts%%}
{%%renderer%%}</footer></body>
</html>
""" % (CSS % dict(ds=DARK["surface"], dp=DARK["primary"], dse=DARK["secondary"],
                  dm=DARK["muted"], dg=DARK["grid"],
                  ls=LIGHT["surface"], lp=LIGHT["primary"],
                  lse=LIGHT["secondary"], lm=LIGHT["muted"], lg=LIGHT["grid"]))


def build_app():
    from dash import Dash, Input, Output, State, dcc, html

    titles = [p[0] for p in panels()]
    app = Dash(__name__, title=f"{RUN_A[1]} vs {RUN_B[1]}")
    app.index_string = INDEX

    app.layout = html.Div([
        html.Header([
            html.Div([html.B(RUN_A[1]),
                      html.Span(f" {RUN_A[0]} — solid", className="note")]),
            html.Div([html.B(RUN_B[1]),
                      html.Span(f" {RUN_B[0]} — dotted", className="note")]),
            html.Button("Dark mode", id="theme-btn"),
        ]),
        html.Div([
            html.Span("Panels", className="lab"),
            dcc.Checklist(
                id="chips", options=[{"label": t, "value": i}
                                     for i, t in enumerate(titles)],
                value=list(range(len(titles))), inline=True,
            ),
            html.Span(className="sep"),
            html.Button("All", id="all-btn"),
            html.Button("None", id="none-btn"),
        ], id="bar"),
        dcc.Graph(id="chart", config={
            "displaylogo": False, "responsive": True,
            "toImageButtonOptions": {"format": "png", "scale": 2,
                                     "filename": f"{RUN_A[1]}_vs_{RUN_B[1]}"},
        }),
        html.Details([
            html.Summary("Signals in the .mos script that are absent "
                         "from both runs"),
            html.P("HardCase1 sets typDis_select1 = Variable1Only and "
                   "typ = Reversible, so the secondary loop, the secondary "
                   "pumps and the heat recovery chiller of the base model do "
                   "not exist:"),
            html.P([html.Code(", ".join(ABSENT))]),
        ], id="absent"),
        dcc.Store(id="theme", data="light"),
    ])

    @app.callback(Output("chips", "value"),
                  Input("all-btn", "n_clicks"), Input("none-btn", "n_clicks"),
                  prevent_initial_call=True)
    def _select(_all, _none):
        from dash import ctx
        return list(range(len(titles))) if ctx.triggered_id == "all-btn" else []

    @app.callback(Output("theme", "data"), Output("theme-btn", "children"),
                  Input("theme-btn", "n_clicks"), State("theme", "data"),
                  prevent_initial_call=True)
    def _theme(_n, cur):
        nxt = "light" if cur == "dark" else "dark"
        return nxt, ("Dark mode" if nxt == "light" else "Light mode")

    app.clientside_callback(
        "function(t) { document.body.dataset.theme = t; return window.dash_clientside.no_update; }",
        Output("theme", "id"), Input("theme", "data"))

    @app.callback(Output("chart", "figure"),
                  Input("chips", "value"), Input("theme", "data"))
    def _figure(selected, theme):
        return make_figure(sorted(selected or []),
                           LIGHT if theme == "light" else DARK)

    return app


if __name__ == "__main__":
    if "--html" in sys.argv:
        fig = make_figure(range(len(panels())), LIGHT)
        fig.write_html(OUT, include_plotlyjs="cdn")
        print(f"{OUT}: {len(panels())} panels, {len(fig.data)} traces")
    else:
        print(f"{len(panels())} panels — http://127.0.0.1:{PORT}")
        build_app().run(debug=False, port=PORT)
