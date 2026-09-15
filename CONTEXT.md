# symmetry-establishment

> Establishment / settings module (company identity, offices, coverage, masters).

- **Org:** SymmetryCare · **Repo:** `symmetry-establishment` · **GitHub:** https://github.com/SymmetryCare/symmetry-establishment
- **Type:** Flutter application (module app)
- **Stack:** Flutter/Dart
- **Status:** runnable standalone and shell-hosted — see CHANGELOG.md

## What this repo is
Establishment / settings module (company identity, offices, coverage, masters).

## Where the code came from
Symmetry-Application-FE `lib/presentation/screens/em_module`, plus the shared
layer (app scaffolding, API client, token manager, login flow, legacy shared
widgets) taken from **symmetry-hr**, which had already de-monolithed it.

## Structure
Mirrors symmetry-hr:

- `lib/main.dart` — `EstablishmentApplication`; gates `initialRoute` on the
  access token, exactly as HR does
- `lib/app` — config, resources, API client, `TokenManager`, `ShellLink`
- `lib/presentation` — the login flow and shared widgets
- `lib/modules/establishment` — this module: `presentation/screens` (the EM
  screens), `data/api` (managers + repository), `data/models`, `providers`,
  `resources`
- `web/`, `config/establishment.env`, `images/`

## Auth
Same mechanism as HR. `TokenManager` stores the session in
`SharedPreferences`, which on web is `localStorage`, scoped to the **origin** —
that is the whole single-sign-on story, and why every module app must be served
from a path on the shell's origin rather than its own subdomain.

## Two shapes, both supported
Decided at build time, defaulting to standalone so a build that forgets the
flags behaves like a plain standalone app rather than linking somewhere that
may not be deployed:

- **Standalone** — served at the site root, its own login screen:
  ```
  flutter build web --dart-define=API_ENDPOINT=/api --dart-define=APP_VERSION=1.1.0
  ```
- **Shell-hosted** — symmetry-shell at `/`, this app at `/establishment/`, one
  origin. Opens already signed in; the header's module selector returns to the
  picker and logout goes back to the shell's login:
  ```
  flutter build web --base-href=/establishment/ --dart-define=SHELL_PATH=/ \
    --dart-define=API_ENDPOINT=/api --dart-define=APP_VERSION=1.1.0
  ```
  The shell must also be built with `establishment` in `DEPLOYED_MODULES`, or
  its Establishment icon stays disabled.

## How to run
```
flutter run -d chrome --dart-define=API_ENDPOINT=https://dev.symmetry.care --dart-define=APP_VERSION=standalone-dev
```

## Configuration / keys
`API_ENDPOINT` / `APP_VERSION` via `--dart-define`; non-secret runtime values in
`config/establishment.env`.

## Depends on (sibling repos)
- symmetry-hr (source of the shared layer, duplicated here — see Notes)
- symmetry-ui-kit, symmetry-contracts (not yet wired)

## Used by
- symmetry-shell (opens this module from the header's settings icon)

## Read these first
`lib/main.dart`, then
`lib/modules/establishment/presentation/screens/em_desktop_screen.dart`.

## Notes
The shared layer is **duplicated** from symmetry-hr, not shared through a
package — the same duplication that already exists between the shell and HR.
The `TokenManager` key names are what make single sign-on work, so they must
stay identical across the three copies until `symmetry-ui-kit` exists.

Some files did not exist in any repo here and were **reconstructed from their
call sites** against the endpoints in `establishment_repository.dart`. Each one
says so in its header comment. Their request/response field names are inferred
and should be checked against the live API:

- `data/api/managers/establishment_manager/`: `newpopup_manager.dart`,
  `work_schedule_manager.dart`, `role_manager.dart`, `ci_visit_manager.dart`,
  `master_designation_s_dd.dart`,
  `manage_insurance_manager/insurance_vendor_contract_manager.dart`
- `data/models/establishment_data/`: `ci_manage_button/newpopup_data.dart`,
  `work_schedule/work_week_data.dart`, `role_manager/role_manager_data.dart`,
  `company_identity/ci_visit_data.dart`
- `resources/`: `em_dashboard_string_manager.dart`, `em_dashboard_theme.dart`
- `providers/`: `em_main_provider.dart`, `delete_popup_provider.dart`

All referenced artwork is real: the 30 dashboard images that were briefly
placeholder tiles were imported from the `Symmetry-Application-FE` monolith,
along with one zero-byte file (`assets/png/action_needed.png`). Every asset the
module references (74 files) is present, non-empty and declared in
`pubspec.yaml`.

---
_This CONTEXT.md is the machine- and human-readable brief for the repo. Keep it current; log every change in CHANGELOG.md._
