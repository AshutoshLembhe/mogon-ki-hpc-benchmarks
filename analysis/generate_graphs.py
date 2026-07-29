#!/usr/bin/env python3
"""Generate the graphs embedded in the repository README."""

from __future__ import annotations

import os
import re
import tempfile
from pathlib import Path

os.environ.setdefault(
    "MPLCONFIGDIR", str(Path(tempfile.gettempdir()) / "mogon-ki-matplotlib")
)

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter


ROOT = Path(__file__).resolve().parents[1]
GRAPH_DIR = ROOT / "assets" / "graphs"
BENCHMARKS = ("EP", "CG", "FT", "MG", "IS", "BT", "SP", "LU")
LINE_STYLES = ("-", "--", "-.", ":")
MARKERS = ("o", "s", "^", "D", "v", "P", "X", "*")
GRAY_LEVELS = ("0.00", "0.18", "0.32", "0.46", "0.58", "0.68", "0.78", "0.88")


def configure_style() -> None:
    plt.rcParams.update(
        {
            "figure.facecolor": "white",
            "axes.facecolor": "white",
            "axes.edgecolor": "black",
            "axes.labelcolor": "black",
            "axes.titleweight": "bold",
            "font.size": 10,
            "grid.color": "0.82",
            "grid.linestyle": ":",
            "grid.linewidth": 0.8,
            "legend.frameon": False,
            "savefig.facecolor": "white",
            "savefig.bbox": "tight",
            "text.color": "black",
            "xtick.color": "black",
            "ytick.color": "black",
        }
    )


def save_figure(fig: plt.Figure, filename: str) -> None:
    GRAPH_DIR.mkdir(parents=True, exist_ok=True)
    fig.savefig(GRAPH_DIR / filename, dpi=200, pad_inches=0.15)
    plt.close(fig)


def parse_npb_results(model: str) -> dict[str, dict[int, float]]:
    if model == "mpi":
        result_dir = ROOT / "npb" / "mpi" / "results"
        filename_pattern = re.compile(r"npbB-(\d+)r\.")
    elif model == "openmp":
        result_dir = ROOT / "npb" / "openmp" / "results"
        filename_pattern = re.compile(r"ompB-(\d+)t\.")
    else:
        raise ValueError(f"Unsupported NPB model: {model}")

    results: dict[str, dict[int, float]] = {name: {} for name in BENCHMARKS}

    for path in sorted(result_dir.glob("*.out")):
        size_match = filename_pattern.search(path.name)
        if not size_match:
            continue

        resource_count = int(size_match.group(1))
        text = path.read_text(encoding="utf-8", errors="replace")

        for benchmark in BENCHMARKS:
            summary_match = re.search(
                rf"\b{benchmark} Benchmark Completed\.?(?P<summary>.{{0,1200}})",
                text,
                flags=re.DOTALL,
            )
            if not summary_match:
                continue

            summary = summary_match.group("summary")
            class_match = re.search(r"Class\s*=\s*([A-Z])", summary)
            time_match = re.search(
                r"Time in seconds\s*=\s*([0-9]+(?:\.[0-9]+)?)", summary
            )
            verification_match = re.search(
                r"Verification\s*=\s*SUCCESSFUL", summary
            )

            if (
                class_match
                and class_match.group(1) == "B"
                and time_match
                and verification_match
            ):
                results[benchmark][resource_count] = float(time_match.group(1))

    return {name: values for name, values in results.items() if values}


def plot_npb_speedup(model: str, filename: str) -> None:
    timings = parse_npb_results(model)
    resource_label = "MPI ranks" if model == "mpi" else "OpenMP threads"
    title_model = "MPI" if model == "mpi" else "OpenMP"

    fig, ax = plt.subplots(figsize=(9.2, 5.5))
    all_resources: set[int] = set()
    max_speedup = 1.0

    for index, benchmark in enumerate(BENCHMARKS):
        values = timings.get(benchmark, {})
        if 1 not in values or len(values) < 2:
            continue

        resources = sorted(values)
        speedups = [values[1] / values[count] for count in resources]
        all_resources.update(resources)
        max_speedup = max(max_speedup, max(speedups))
        ax.plot(
            resources,
            speedups,
            label=benchmark,
            color=GRAY_LEVELS[index],
            linestyle=LINE_STYLES[index % len(LINE_STYLES)],
            marker=MARKERS[index],
            linewidth=1.8,
            markersize=5,
        )

    ordered_resources = sorted(all_resources)
    ax.plot(
        ordered_resources,
        ordered_resources,
        color="black",
        linestyle=(0, (6, 4)),
        linewidth=1.2,
        label="Ideal",
    )

    ax.set_xscale("log", base=2)
    ax.set_yscale("log", base=2)
    ax.set_xticks(ordered_resources)
    ax.get_xaxis().set_major_formatter(ScalarFormatter())
    y_limit = max(max_speedup, max(ordered_resources))
    y_ticks = [2**power for power in range(0, 10) if 2**power <= y_limit]
    ax.set_yticks(y_ticks)
    ax.get_yaxis().set_major_formatter(ScalarFormatter())
    ax.set_xlabel(resource_label)
    ax.set_ylabel("Speedup relative to 1")
    ax.set_title(f"NPB Class B {title_model} speedup")
    ax.grid(True, which="major")
    ax.legend(ncol=3, loc="upper left")
    fig.text(
        0.5,
        0.01,
        "Only successfully verified benchmark completions are plotted.",
        ha="center",
        fontsize=9,
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    save_figure(fig, filename)


def parse_lulesh_openmp(kind: str) -> list[tuple[int, float]]:
    results: list[tuple[int, float]] = []
    for path in sorted((ROOT / "lulesh" / "openmp" / "results").glob(f"omp-{kind}-*.out")):
        text = path.read_text(encoding="utf-8", errors="replace")
        threads_match = re.search(r"Num threads:\s*(\d+)", text)
        elapsed_match = re.search(
            r"Elapsed time\s*=\s*([0-9]+(?:\.[0-9]+)?(?:e[+-]?[0-9]+)?)\s*\(s\)",
            text,
            flags=re.IGNORECASE,
        )
        iteration_match = re.search(r"Iteration count\s*=\s*100", text)
        if threads_match and elapsed_match and iteration_match:
            results.append(
                (int(threads_match.group(1)), float(elapsed_match.group(1)))
            )
    return sorted(results)


def plot_lulesh_strong() -> None:
    timings = parse_lulesh_openmp("strong")
    base_time = dict(timings)[1]
    threads = [count for count, _ in timings]
    speedups = [base_time / seconds for _, seconds in timings]

    fig, ax = plt.subplots(figsize=(8.6, 5.1))
    ax.plot(
        threads,
        speedups,
        color="black",
        marker="o",
        linewidth=2,
        label="Measured",
    )
    ax.plot(
        threads,
        threads,
        color="0.55",
        linestyle=(0, (6, 4)),
        linewidth=1.5,
        label="Ideal",
    )
    ax.set_xscale("log", base=2)
    ax.set_yscale("log", base=2)
    ax.set_xticks(threads)
    ax.get_xaxis().set_major_formatter(ScalarFormatter())
    ax.set_yticks([1, 2, 4, 8, 16, 32, 64, 128])
    ax.get_yaxis().set_major_formatter(ScalarFormatter())
    ax.set_xlabel("OpenMP threads")
    ax.set_ylabel("Speedup relative to 1 thread")
    ax.set_title(r"LULESH OpenMP strong scaling ($120^3$ fixed mesh)")
    ax.grid(True, which="major")
    ax.legend(loc="upper left")
    fig.tight_layout()
    save_figure(fig, "lulesh-openmp-strong-speedup.png")


def plot_lulesh_weak() -> None:
    timings = parse_lulesh_openmp("weak")
    threads = [count for count, _ in timings]
    elapsed = [seconds for _, seconds in timings]
    baseline = elapsed[0]

    fig, ax = plt.subplots(figsize=(8.6, 5.1))
    ax.plot(
        threads,
        elapsed,
        color="black",
        marker="s",
        linewidth=2,
        label="Measured",
    )
    ax.axhline(
        baseline,
        color="0.55",
        linestyle=(0, (6, 4)),
        linewidth=1.5,
        label="Ideal constant runtime",
    )
    ax.set_xscale("log", base=2)
    ax.set_xticks(threads)
    ax.get_xaxis().set_major_formatter(ScalarFormatter())
    ax.set_xlabel("OpenMP threads")
    ax.set_ylabel("Elapsed time (s)")
    ax.set_title("LULESH OpenMP weak-scaling runtime")
    ax.grid(True, which="major")
    ax.legend(loc="upper left")
    fig.text(
        0.5,
        0.01,
        r"Mesh sizes: $30^3$, $60^3$, $90^3$, $120^3$, and $151^3$.",
        ha="center",
        fontsize=9,
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    save_figure(fig, "lulesh-openmp-weak-runtime.png")


def parse_io500_scores() -> list[tuple[int, float, float]]:
    results: list[tuple[int, float, float]] = []
    paths = {
        1: ROOT / "io500" / "results" / "1-rank" / "result_summary.txt",
        4: ROOT / "io500" / "results" / "4-ranks" / "result_summary.txt",
    }
    score_pattern = re.compile(
        r"\[SCORE\s*\]\s+Bandwidth\s+([0-9.]+)\s+GiB/s\s+:\s+"
        r"IOPS\s+([0-9.]+)\s+kiops\s+:\s+TOTAL\s+([0-9.]+)\s+\[INVALID\]"
    )
    for ranks, path in paths.items():
        text = path.read_text(encoding="utf-8", errors="replace")
        match = score_pattern.search(text)
        if match:
            results.append((ranks, float(match.group(1)), float(match.group(2))))
    return results


def plot_io500_diagnostics() -> None:
    scores = parse_io500_scores()
    ranks = [str(row[0]) for row in scores]
    bandwidth = [row[1] for row in scores]
    metadata = [row[2] for row in scores]

    fig, axes = plt.subplots(1, 2, figsize=(9.2, 4.8))
    panels = (
        (axes[0], bandwidth, "Bandwidth score", "GiB/s"),
        (axes[1], metadata, "Metadata score", "kIOPS"),
    )

    for ax, values, title, unit in panels:
        bars = ax.bar(ranks, values, color=("0.78", "0.35"), edgecolor="black")
        ax.set_xlabel("MPI ranks")
        ax.set_ylabel(unit)
        ax.set_title(title)
        ax.grid(True, axis="y")
        ax.bar_label(bars, fmt="%.3f", padding=3, fontsize=9)
        ax.set_ylim(0, max(values) * 1.2)

    fig.suptitle("IO500 diagnostic comparison (invalid 30-second runs)", weight="bold")
    fig.text(
        0.5,
        0.01,
        "These are not official IO500 scores; the required standard stonewall duration is 300 seconds.",
        ha="center",
        fontsize=9,
    )
    fig.tight_layout(rect=(0, 0.05, 1, 0.94))
    save_figure(fig, "io500-diagnostic-scores.png")


def main() -> None:
    configure_style()
    plot_npb_speedup("mpi", "npb-class-b-mpi-speedup.png")
    plot_npb_speedup("openmp", "npb-class-b-openmp-speedup.png")
    plot_lulesh_strong()
    plot_lulesh_weak()
    plot_io500_diagnostics()
    print(f"Generated five graphs in {GRAPH_DIR.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
