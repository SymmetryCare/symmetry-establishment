# Changelog

All notable changes to this repo. Newest first.

## 2026-09-11 - register the twelve missing app-wide providers

Opening Manage HR > Work Schedule > Define Holidays threw
`ProviderNotFoundException` for `DefineHolidaysProvider`: the screen has a
`Consumer<T>` but no provider of `T` anywhere above it, so the screen went
down as soon as it was built.

An audit of the whole module - every `Consumer`/`Consumer2`/`Selector`,
`context.watch/read/select`, and `Provider.of` against every place a provider
is created - turned up **twelve** types consumed with no provider above them,
each one a screen that would crash the first time it was opened:

Ten of them are in symmetry-hr's own `main.dart` and were simply not carried
over when this entrypoint was written: `HrManageProvider` (19 call sites),
`HrOnboardingProvider` (14), `HrProgressMultiStape` (9),
`HrEnrollEmployeeProvider` (5), `HrEnrollOfferLatterProvider` (5),
`HrRegisterProvider` (3), `HRLicenseProvider` (2), `HRBankingProvider`,
`HrSearchProviderManager`, `PageIndexProvider`.

Two belong to Establishment-only screens and have no HR counterpart:
`DefineHolidaysProvider` and `DeleteUserProvider` (the See All user table's
delete action).

Three further names the scan flagged - `AuthProvider`, `ButtonProvider`,
`AddNewOrgDocButtonProviider` (note the typo) - appear only inside
commented-out code, so nothing was added for them.

### Verified

`flutter analyze`: 0 errors. Drove a debug build through every entry in the
module menu - Users, Visits, Designation Settings, Work Schedule (both
Shifts & Batches and Define Holidays), Employee Documents, Pay Rate, Document
Definition - and each screen renders with no `ProviderNotFoundException` and
no error widget. Both release artifacts rebuilt.

### Not ours

`workWeekShiftScheduleGet` returns **404**. Its path
(`/workWeekShiftSchedule/findByWeekDay/{weekDay}/{companyId}`) is byte-identical
to symmetry-hr's, so it is not one of this repo's reconstructed endpoints - the
route is missing on the API being pointed at.

## 2026-09-11 - web/index.html loads the JS libraries the plugins need

`GoogleMap` threw `TypeError: Cannot read properties of undefined (reading
'maps')` the moment Company Identity tried to build a map. `google_maps_flutter_web`
is a wrapper over the Google Maps JavaScript API: it reads `window.google.maps`
during build, and nothing was loading that script.

symmetry-hr's `index.html`, which this repo's was copied from, has no such tag
because HR has no map screens - it only carries the two map *providers*.
Establishment renders real maps (office locations, zones, the location picker),
so it needs the loader.

Added to `web/index.html`, both **synchronous and ahead of**
`flutter_bootstrap.js` - deferring either one turns the dependency into a race
that only loses on slow connections:

- **Google Maps JS API** - same public browser key the deployed app uses. A
  Maps browser key is necessarily visible to the client; it is protected by an
  HTTP-referrer restriction on the Google Cloud side, not by secrecy.
- **PDF.js** (+ worker) - same class of bug, not yet hit: `pdfx` calls
  `globalThis.pdfjsLib`, and Onboarding opens acknowledgement and health-record
  PDFs through `PdfDocument.openData`. It would have failed at open time.

### Verified

Ran the release build and drove it: `window.google.maps.Map` and
`globalThis.pdfjsLib` both defined, and Company Identity -> Add New Office ->
Pick Location renders a live, fully tiled Google map with a draggable marker -
no exception. Both artifacts rebuilt (`web-standalone`, `web-shell`).

## 2026-09-10 - real assets imported from Symmetry-Application-FE

The 30 dashboard images that shipped as generated placeholder tiles are now the
real artwork, copied from the `Symmetry-Application-FE` monolith at the same
paths. Also fixed `assets/png/action_needed.png`, which had come across from
symmetry-hr as a **zero-byte** file; the monolith's copy is 1221 bytes.

Only asset files were taken from the monolith - no code.

### Verified

- Placeholders identified by content hash (all 30 were byte-identical), so the
  replacement is exhaustive rather than by memory of which ones were stubbed.
- Full re-sweep of the module for asset references, including interpolated
  paths: **74 distinct assets**, all present on disk, none zero-byte, all
  covered by a `pubspec.yaml` declaration.
- Served the release build and fetched all 74 through the running app:
  **74/74 HTTP 200, no empty responses**, 2.5 MB total.
- Dashboard rendered at 1600x900: hero illustration, the key in the Encryption
  Key donut and every metric-card icon now show real art instead of grey tiles.
- 19 of the 74 are HR-era icons that postdate the monolith fork and exist only
  in symmetry-hr; they were already correct and were left alone.
- `flutter analyze` - 0 errors. Both release artifacts rebuilt
  (`build/web-standalone`, `build/web-shell`).

## 2026-09-10 - fix: blank screen after login was an unbounded-flex layout crash

Root cause, from the debug-build stack trace: **"RenderFlex children have
non-zero flex but incoming width constraints are unbounded"**, thrown by the
`Row` that lays out the app bar's nav slot.

`hh_emr_appbar` puts the caller's `body` widgets into a Row inside a horizontal
`SingleChildScrollView` under `ConstrainedBox(minWidth: slot.maxWidth)` - so the
incoming width is `minWidth..Infinity`. That is fine for HR, whose nav items
size themselves, but `em_desktop_screen` passed an `Expanded(flex: 1, ...)`
into it. A flex child cannot resolve against an unbounded width, so layout
threw; every box under the failure then reported `RenderBox was not laid out`,
and a render tree with no sizes paints as a blank page.

- **`em_desktop_screen`**: the nav is now `Padding > Row(mainAxisSize.min,
  spacing: AppPadding.p30)` instead of `Expanded > Container > Row(spaceBetween)`.
  `spaceBetween` also needs a bounded width to divide up, so the even spacing
  comes from the Row's own `spacing`.
- **`hh_emr_appbar`**: unchanged behaviour - it is HR's shared widget and its
  scrolling is what keeps a too-wide nav usable. The constraint it imposes on
  callers ("every widget in `body` must size itself") is now written down at
  the slot, since nothing said so and violating it costs a blank screen.
- **`responsive_app_bar` / `responsive_screen`**: both pushed the measured
  width into a GetX `ScreenSizeController` from inside their `LayoutBuilder`
  callbacks and read the `RxBool`s straight back. Assigning an `Rx` notifies
  listeners, and the callback runs during layout, so that mutated observable
  state mid-layout. Nothing outside those two builders ever read the flags, so
  the branch is computed from `constraints` directly now, with no side effect.
  Their old `else` branch also returned an empty `Scaffold` for a width of
  exactly 800 - a second, narrower blank screen - which is gone with it.

### Why this was not caught earlier

The failing assertions are `assert`s: they fire in debug and are compiled out
of release. Earlier verification here used `flutter build web` (release), where
the same broken layout silently produces an unsized tree - a blank page with no
console error - which is exactly the symptom reported. Reproduction needed
`flutter run` (debug), matching how it was hit.

### Verified

Driven in a debug build (assertions on) against a stub backend, signed in, at
several viewport widths:

- **1920x900** (the width in the reported trace): dashboard renders, **0 layout
  errors**. Company Identity opens clean too.
- 1440x900: renders, 0 layout errors.
- 1280x850: renders; one remaining `RenderFlex overflowed` warning from a
  dashboard card (`dashboard/widgets/screens/widgets/general_setting_const.dart:127`).
- 1100x800: renders; the same card overflows by 64px.

Those remaining warnings are cosmetic (yellow stripe, no crash), come from the
extracted dashboard card rather than the app bar, and do not occur at 1920.
They are **not fixed here** - narrowing that card is a separate change and the
design intent for it is not documented.

- `flutter analyze` - 0 errors in symmetry-establishment, symmetry-hr and
  symmetry-shell.
- Release artifacts rebuilt: `build/web-standalone` (`<base href="/">`) and
  `build/web-shell` (`<base href="/establishment/">`).

## 2026-09-10 - white screen: diagnosis aids, and one confirmed cause ruled in

Chasing a reported blank screen after login. Both login paths were driven
end-to-end through the UI against a stub backend - email -> OTP, and
email -> "Don't have authentication application with me?" -> password - and
both reach the Establishment dashboard. The reported failure was **not
reproduced**, so what follows is what was ruled in and out, not a confirmed
fix for it.

### Ruled out as the cause

- The post-login route (fixed earlier today; verified reaching the module).
- `FrontendConfigStore` being null. Tested directly by disabling the loader
  added earlier and re-running the password login: it still reached the
  dashboard. That fix stands - 343 null-assertions with no loader is a real
  latent crash - but it is not this bug.
- `--base-href` / serving under a subpath, and service workers, in a local
  reproduction of the `/establishment/` layout.

### Confirmed cause of *a* blank screen

Building without `--base-href=/establishment/` and serving at
`/establishment/` produces exactly this symptom. `index.html` gets
`<base href="/">`, so the bundle is requested from the origin root:

```
GET /establishment/       -> 200
GET /flutter_bootstrap.js -> 404   <- nothing renders, blank page
```

Hit accidentally while testing, and worth checking first in any deployment:
the Network tab shows a lone 404 for `flutter_bootstrap.js` or `main.dart.js`.

### New: an opt-in error surface

`app/services/config/error_surface.dart`, installed at the top of `main()` and
**off by default**, so production behaviour is unchanged. Built with

```
flutter build web --dart-define=DEBUG_ERRORS=true
```

a build-time exception renders the message, the widget being built and the top
of the stack instead of a blank page, and every framework error is printed to
the console. Verified by injecting a deliberate null-assert into
`ResponsiveScreenEM.build`: the page showed "This screen failed to build -
Null check operator used on a null value" with the stack. The injected fault
was removed afterwards; `grep FORCE_CRASH lib` is clean.

### Verified

- `flutter analyze` - 0 errors.
- Shell-hosted build serves and boots correctly at `/establishment/`.

## 2026-09-10 - frontend config was never loaded (white screen after login)

The Establishment screens read `FrontendConfigStore.data!` - a hard null
assertion - in **343 places**: document type ids, department ids, expiry-type
labels. Nothing in this repo ever populated that store. symmetry-shell loads it
from the API and caches it; symmetry-hr gets away without a loader only because
its demo shim (`demo_employee.dart`, which this repo does not have) seeds it.
Establishment had neither, so every one of those 343 sites was a guaranteed
throw - and a thrown exception during build is a white screen.

- Ported `appconfige_manager.dart` from symmetry-shell - the real loader, which
  also caches the raw response under `frontend_config_data`.
- Added `app/services/config/frontend_config_boot.dart` and awaited it in
  `main()` **before `runApp`**, so the store is non-null before the first
  screen builds. Three sources, in order:
  1. the `SharedPreferences` cache - which on web is origin-scoped
     `localStorage`, so a shell-hosted build at `/establishment/` inherits the
     config the shell already fetched, exactly like the session token;
  2. compiled-in defaults if there is no cache, because a standalone first run
     has nobody to inherit from and a wrong-but-present id renders a working
     screen where a null one renders nothing;
  3. the live API, refreshed after the first frame and written back to the
     cache.
- `main.dart` now owns a `navigatorKey` (the refresh needs a context that
  outlives any one screen; the app bar already imported `main.dart` expecting
  one).

Note the config endpoint is an absolute URL on `auth.symmetry.care`, not
`API_ENDPOINT`, so it resolves the same in every deployment shape.

### Verified

- Full login driven through the UI against a stub backend: email -> OTP ->
  Establishment dashboard, with the user in the app bar; Company Identity opens
  too. No exceptions in the browser console.
- Console confirms the sequence: defaults seeded, then
  `Frontend config loaded from API. salesId: 2`, then cached.
- `flutter analyze` - 0 errors. Both build shapes still build with the right
  `<base href>`.
- **Not reproduced:** the reported white screen itself. Against a stub the
  establishment endpoints return empty collections, so the `data!` paths never
  execute and the screen rendered even before this fix. This addresses the one
  mechanism that certainly produces a white screen on those paths, but it is
  not confirmed to be the same one. If it recurs, the browser console's first
  exception will name the file and line.

## 2026-09-10 - fix: login succeeded but the login screen stayed up

The login flow came over from symmetry-hr with HR's destination still in it.
On success it called `Navigator.pushReplacementNamed(context,
HRHomeScreen.routeName)` - `/hrDesktop`, a route this app's `_generateRoute`
does not name - so it fell through to `default:`, which tested `isSignedIn`.
That field is a snapshot taken in `main()` before the first frame, so it was
still `false`, and the fallback rebuilt `LoginScreen`. The login had actually
worked and the token was written; only the navigation was wrong.

- Six login screens (`login_password_*`, `email_verification_*`) now navigate
  to `RouteStrings.emDesktop`. The unused `HRHomeScreen` imports went with it.
- `email_verification_web` also called `setRoute(RouteStrings.hrDesktop)` on
  one branch. Both branches of that department check already went to the same
  place - this app serves one module - so the branch is collapsed and the
  recorded route is `emDesktop`.
- Hardened the fallback so this cannot silently recur: `_generateRoute` now
  tests a live `_hasSession` flag instead of the boot snapshot. `main()` seeds
  it, routing to the module sets it, and routing to the login screen (logout,
  session expiry) clears it. `isSignedIn` still decides `initialRoute`, which
  is the one place a boot snapshot is correct.
- `RouteStrings.home` is handled as an alias for the module home.

### Verified

- Every named-route push in the app cross-checked against the router: no
  unhandled targets remain.
- Ran the built app against a static server in a browser: signed out it shows
  the login screen; with a session in `localStorage` it boots straight to the
  Establishment dashboard.
- `flutter analyze` - 0 errors.
- Not verified: a real login against a live backend, which needs credentials
  and a reachable API.

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
