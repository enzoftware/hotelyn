# california_ui — Widgetbook

An interactive catalog of every `california_ui` component, built with
[Widgetbook](https://widgetbook.io).

## Run

From the repo root:

```bash
melos run widgetbook
```

This regenerates `lib/main.directories.g.dart` and launches the catalog in
Chrome. Because melos runs it through its own I/O pipe (not a real
terminal), `flutter run`'s interactive hot-reload keys (`r`/`R`/`q`) may not
respond — use Ctrl+C to stop it. For full interactive hot-reload support,
run it directly from this directory instead:

```bash
flutter run -d chrome
```

## Add a new use-case

1. Create a file in `lib/use_cases/`, e.g. `california_avatar_use_cases.dart`.
2. Write one or more `@widgetbook.UseCase` functions covering the
   component's meaningful states/variants — favor `context.knobs.*` for
   interactive properties over hardcoded values, so the component can be
   exercised live in the Widgetbook UI.
3. Regenerate `main.directories.g.dart`:

   ```bash
   melos run widgetbook:generate
   ```

Use-cases are grouped in the sidebar by the `type:` argument's location
inside `california_ui`'s own `lib/src/` tree (e.g. everything typed against
a class in `theme/` groups under "theme"), not by where the use-case file
itself lives.
