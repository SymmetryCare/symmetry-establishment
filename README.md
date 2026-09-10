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
