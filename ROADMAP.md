# Cheetah Roadmap

This document tracks features intentionally deferred while shipping the MVP.

## Current MVP Scope (DONE)

- Menu bar only app (no Dock icon).
- Runner animation in menu bar.
- Animation speed driven by CPU usage.
- Separate Settings window.
- Runner selection and menu CPU text toggle persisted in UserDefaults.

## Next Features (RunCat-style parity)

### 1. Rich System Info Dropdown (DONE)

- Add memory usage with percentage and human-readable used/total values. with more detail by lcicking on main Memory usage display.
- Show exact CPU usage with per-core detail by clicking on main CPU usage display.

### 2. App-Level Resource Insights (DONE)

- Show top CPU-consuming processes in dropdown.
- Show top memory-consuming processes in dropdown.
- Add refresh cadence controls for process sampling.

### 3. Runner UX Improvements

- Add search in runner picker for faster selection.
- Add favorites/recent runners.
- Add random runner mode.

### 4. Performance and Reliability

- Add explicit low-power mode behavior to reduce polling.
- Add fallback handling for metrics APIs that fail.
- Add diagnostics mode for troubleshooting unavailable metrics.
