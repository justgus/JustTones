# JustTones

JustTones is a SwiftUI pitch-reference tone generator for iPhone with an Apple Watch companion, targeting iOS 27.x and watchOS 27.x.

Project behavior and scope are defined in [`AGENTS.md`](AGENTS.md), [`docs/Product-Brief.md`](docs/Product-Brief.md), and [`docs/Requirements-Specification.md`](docs/Requirements-Specification.md). Canonical Agile planning and requirements data lives in `.airframe/state/`.

Launch the graphical Agile Cockpit for planning, human verification, and authorized close transitions:

```sh
.airframe/scripts/ac-launch-cockpit.sh
```

The launcher opens the installed Cockpit from the sibling Airframe project and points it at JustTones’ canonical state. It clears only derived Cockpit caches first so externally added requirements appear correctly. Relaunch after changing canonical requirements while Cockpit is already open. Do not set `AIRFRAME_STORE_PATH`; doing so selects a separate fixture store.

The Xcode project has not yet been created. Initial implementation work is planned in Airframe Sprint `SP-001` and awaits activation.
