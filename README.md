# symmetry-establishment

Establishment module (company identity, offices, coverage, masters).

See **CONTEXT.md** for the full brief (purpose, stack, auth, how to run) and **CHANGELOG.md** for the log.

Part of the SymmetryCare platform. GitHub: https://github.com/SymmetryCare/symmetry-establishment

## Run standalone

```sh
flutter run -d chrome \
  --dart-define=API_ENDPOINT=https://dev.symmetry.care \
  --dart-define=APP_VERSION=standalone-dev
```

## Build behind symmetry-shell

Served at `/establishment/` on the shell's origin, opening already signed in:

```sh
flutter build web --base-href=/establishment/ \
  --dart-define=SHELL_PATH=/ \
  --dart-define=API_ENDPOINT=/api \
  --dart-define=APP_VERSION=1.1.0
```

The shell must be built with `establishment` in `--dart-define=DEPLOYED_MODULES`
or its Establishment icon stays disabled.

## URLs

Every page and tab has its own real path — no `#` — relative to the base href.
The full list is in `lib/app/router/em_routes.dart`, for example:

```
/establishment/dashboard/general-setting
/establishment/company-identity
/establishment/users
/establishment/hr/employee-documents/compensation
/establishment/org-documents/vendor-contracts/snf
```

`/establishment/`, a page without its tab, an unknown tab or an old route name
(`/establishmentDesktop`) is sent to the matching page. Old `#` links
(`/establishment/#/establishmentDesktop`) are rewritten in `web/index.html`.

## Deploy: the server must serve index.html for every Establishment path

Refreshing a page, pressing Enter in the address bar or opening a copied link
asks the server for that path, and no such file exists. The server must answer
any path under `/establishment/` that is not a real file with
`/establishment/index.html`; Establishment then opens on that page.

nginx:

```nginx
location /establishment/ {
  try_files $uri $uri/ /establishment/index.html;
}
```

Without this rule every page except `/establishment/` itself is a 404 on
refresh — or, if the server falls back to the site root, the shell loads
instead of Establishment. Standalone at the site root, the same rule applies to
`/` and `/index.html`.
