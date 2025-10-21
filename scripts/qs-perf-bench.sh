#!/usr/bin/env bash
set -euo pipefail

# Simple unattended benchmark for qs-wallpapers picker startup
# Results saved under docs/qs-perf-results/$(date +%Y%m%d-%H%M%S)

RUNS=${RUNS:-3}
STAMP=$(date +%Y%m%d-%H%M%S)
OUTDIR="docs/qs-perf-results/${STAMP}"
mkdir -p "$OUTDIR"

echo "[bench] Writing results to $OUTDIR" >&2

# 1) Shell-only (no QML) perf logs
for i in $(seq 1 "$RUNS"); do
  echo "[bench] shell-only run $i" >&2
  QS_PERF=1 qs-wallpapers --shell-only 2>"$OUTDIR/shell-only.$i.log" || true
  sleep 0.2
done

# 2) Full picker print-only (auto quits after model load) perf logs
for i in $(seq 1 "$RUNS"); do
  echo "[bench] print-only run $i" >&2
QS_PERF=1 QS_DEBUG=1 QS_AUTO_QUIT=1 qs-wallpapers-apply --print-only &>"$OUTDIR/print-only.$i.log" || true
  sleep 0.5
done

echo "[bench] Done. Logs in $OUTDIR" >&2

