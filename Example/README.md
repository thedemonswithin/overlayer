# OverlayerExample

A small SwiftUI app that exercises the full Overlayer API:

- every example toast type (Success / Error / Info / Warning), per-toast `position`, `lifetime` (incl. `.sticky`) and `haptic`;
- the visible-count limit and queue (the “Show 6” button), plus `dismissAll`;
- a **custom toast** (`DownloadToastModel` + view) with an action button, registered independently;
- **loading**: blocking spinner, determinate progress (`LoadingProgress` updated live), non-blocking pass-through, nested stack, and a **custom loader** with a Cancel button via `LoadingContext`;
- live **container config** (`Overlayer.toastContainerConfiguration`);
- the **passthrough** behaviour — a `TextField` stays interactive while toasts are on screen.

Toast interactions to try by hand: tap to pause/resume, press-and-hold to pause while held, swipe toward the edge (with rubber-band) to dismiss, or use the close button.

## Run

Open `OverlayerExample.xcodeproj` and run on an iOS 16+ simulator or device. It references the Overlayer package locally (`path: ..`), so it builds straight against the sources in this repo — no published version needed.

The project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
cd Example
xcodegen generate
```

If your `.gitignore` excludes `*.xcodeproj`, either force-add the generated project (`git add -f Example/OverlayerExample.xcodeproj`) or commit only `project.yml` and regenerate with XcodeGen.
