# symmetry-establishment

> Establishment / settings module (company identity, offices, coverage, masters).

- **Org:** SymmetryCare · **Repo:** `symmetry-establishment` · **GitHub:** https://github.com/SymmetryCare/symmetry-establishment
- **Type:** Flutter feature package
- **Stack:** Flutter/Dart
- **Status:** initialized — see CHANGELOG.md

## What this repo is
Establishment / settings module (company identity, offices, coverage, masters).

## Where the code came from
Symmetry-Application-FE lib/presentation/screens/em_module.

## Structure
lib/ (screens, widgets, providers for this module)

## Auth
Uses the shared token from symmetry-ui-kit; talks to symmetry-core-api with the id.symmetry.care Bearer token.

## Configuration / keys
Backend base URLs via ui-kit config.

## How to run
```
Developed in isolation; the shell composes it via melos/path dependency.
```

## Depends on (sibling repos)
- symmetry-ui-kit
- symmetry-contracts (dart)

## Used by
- symmetry-shell (composes this module)

## Read these first
lib/ root screen for the module.

## Notes
Extracted from the Application-FE monolith; wire routes through the shell.

---
_This CONTEXT.md is the machine- and human-readable brief for the repo. Keep it current; log every change in CHANGELOG.md._
