# Changelog

All notable changes to this repo. Newest first.

## 2026-09-10 - runnable standalone app, and hostable behind symmetry-shell

The repo was a bare copy-out of the monolith's `lib/presentation/screens/em_module`:
no `main.dart`, no `web/`, a pubspec declaring only `flutter`, and 584 imports
pointing at `package:prohealth/...`. It could not be built or run. It is now a
Flutter app shaped like symmetry-hr, in both of HR's shapes.

- **Shared layer taken from symmetry-hr** (not the monolith): app scaffolding,
  `AppConfig`, the Dio client, `TokenManager`, the login flow, and the legacy
  shared widgets. HR had already de-monolithed these, so this repo starts from
  the cleaned versions rather than re-extracting. It is a copy, like the one
  the shell and HR already keep of each other.
- **Restructured to HR's layout**: the EM screens moved from `lib/em_module` to
  `lib/modules/establishment/presentation/screens`, alongside `data/api`,
  `data/models`, `providers` and `resources` - the same shape as
  `lib/modules/hr`. Every import was rewritten to
  `package:symmetry_establishment/...`. 475 files.
- **`lib/main.dart`** - `EstablishmentApplication`, mirroring HR's: loads
  `config/establishment.env`, initialises Firebase, and gates `initialRoute` on
  the access token so a signed-in user lands on the module and everyone else on
  the login screen.
- **`app/services/shell/shell_link.dart`** - HR's `ShellLink`, retargeted at
  `/establishment/`. `--dart-define=SHELL_PATH=/` marks a build as hosted
  behind the shell; the define is **empty by default**, so a build that does
  not pass it behaves like a standalone app. Shell-hosted, the header's module
  selector returns to the picker and logout redirects to the shell's login
  instead of stranding the user on a second login form at `/establishment/`.
- Shell-hosted, Establishment opens **already signed in**: `TokenManager` reads
  the session the shell wrote, because `localStorage` is shared across paths on
  one origin. Same mechanism as HR, and it breaks the same way if a module is
  moved to its own subdomain.
- **Three dead imports dropped** (present, never referenced): the EMR desktop
  screen and calendar popup, and the scheduler's slider provider. The first of
  these was pulling the whole EMR/scheduler/OASIS half of the monolith into
  this module's dependency graph.
- **Retired the base64 downloader** in the four vendor-contract screens and
  moved every download to the current `downloadFile(...)` / `PdfDownloadButton`
  API with an explicit `apiPath`, which is the migration HR already made. The
  old `DowloadFile` class is commented out in HR too.
- Dropped `CustomRadioListTileSMp`: unused here, and its only dependency was
  the scheduler module's provider, which is not part of this repo.

### Reconstructed files

Fourteen files existed in no repo in this workspace. They were rebuilt from
their call sites, against the endpoints already present in
`establishment_repository.dart`, in the idiom of the sibling managers. Each
carries a header comment saying so. **Their request/response field names are
inferred and need checking against the live API** - the shapes compile and the
endpoints are right, but the JSON keys are a best reading:

- managers: `newpopup_manager`, `work_schedule_manager`, `role_manager`,
  `ci_visit_manager`, `master_designation_s_dd`,
  `insurance_vendor_contract_manager`
- models: `newpopup_data`, `work_week_data`, `role_manager_data`,
  `ci_visit_data`
- resources: `em_dashboard_string_manager` (107 display strings, wording
  derived from the identifiers), `em_dashboard_theme` (10 text styles)
- providers: `em_main_provider`, `delete_popup_provider` (a dialog, not a
  `ChangeNotifier`; delegates to the shared `DeletePopup`)

`ci_org_doc_manager.dart` came from symmetry-shell, the only repo here that
carried it.

### Placeholder assets

30 dashboard images (`images/em_dashboard/*`, and a few at `images/` root) are
in none of these repos. They are **generated placeholder tiles** so the app
builds and runs; they need the real artwork before this is shown to anyone.

### Verified

- `flutter analyze` - **0 errors** (matching symmetry-hr's baseline).
- `flutter build web --base-href=/establishment/ --dart-define=SHELL_PATH=/` -
  builds, `<base href="/establishment/">`.
- `flutter build web` with no shell flags - builds, `<base href="/">`.
- Not exercised against a live backend: no request in the reconstructed
  managers has been run against a real API.

## 2026-08-16 — repo initialized
- Created under the SymmetryCare org with the agreed name.
- Added CONTEXT.md (repo brief) and this changelog.
- Initial code import from source (see CONTEXT.md > Where the code came from).
