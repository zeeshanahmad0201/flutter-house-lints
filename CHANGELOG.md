# Changelog

## 0.3.0

- New rule `no_stateful_widget`: flags a class that extends `StatefulWidget`
  (from `package:flutter/`) or `StatefulHookWidget` (from
  `package:flutter_hooks/`), directly, as a plain, prefixed or `abstract`
  class or a class type alias. Use a `HookWidget` instead.
- Upgrading from 0.2.0: every existing `StatefulWidget` in `lib/` will now
  warn. Fix them, or exempt a file that truly needs one with
  `// ignore_for_file: flutter_house_lints/no_stateful_widget`.
- Moved into this package because the convention was missed in two PRs, so
  the rule set is no longer only raw Material components.

## 0.2.0

- New rule `no_raw_scaffold`: flags a raw `Scaffold`. `Scaffold.of`,
  `Scaffold.maybeOf` and `ScaffoldMessenger` are not flagged.
- `no_raw_dialog` now also flags calls to `showDialog`, `showGeneralDialog`
  and `showAdaptiveDialog`, not only the dialog classes.
- Upgrading from 0.1.0: expect new warnings on a raw `Scaffold` and on calls
  to those dialog functions. Exempt the shared scaffold and dialog service
  files with `// ignore_for_file: flutter_house_lints/no_raw_scaffold` and
  `// ignore_for_file: flutter_house_lints/no_raw_dialog`.
- README: `flutter analyze` does not print plugin diagnostics on Flutter
  3.47.9; run `dart analyze` in CI (corrects a wrong claim in 0.1.0's README).

## 0.1.0

- First release: nine warning rules, on by default, that flag raw Material
  components in app code: `no_raw_app_bar`, `no_raw_list_tile`,
  `no_raw_dialog`, `no_raw_bottom_sheet`, `no_raw_button`,
  `no_raw_text_field`, `no_raw_chip`, `no_raw_card`, `no_raw_snack_bar`.
- Matches Material components declared in Flutter (`package:flutter/`) or in
  the `material_ui` package (`package:material_ui/`).
- Requires Dart 3.13+ (Flutter 3.47+) when loaded from git.
