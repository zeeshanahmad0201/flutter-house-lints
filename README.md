# flutter-house-lints

A Dart analyzer plugin that flags raw Material components (`AppBar`,
`ListTile`, `ElevatedButton`, ...) in Flutter app code.

Apps drift from their design system when each page builds its own Material
chrome instead of using the app's shared widgets, and nobody notices in review.
This plugin makes that a warning, so the same rule fires in the IDE, in
`dart analyze` / `flutter analyze` (and so in CI), and in any tool that runs the
analyzer on an edited file.

## Requirement: Dart 3.13+ (Flutter 3.47+)

Apps load this plugin from this git repo, pinned to a tag. Analyzer plugins
from a git source work only on Dart 3.13 and later. On Dart 3.12 and earlier the
analyzer silently skips a git-sourced plugin: no error, no warnings, and
`dart analyze` prints "No issues found!".

So the PR that adopts the plugin must also raise the app's own `pubspec.yaml`
SDK lower bound, so a machine or CI still on an older SDK fails loudly at
`pub get` instead of quietly running without the plugin:

```yaml
environment:
  sdk: ^3.13.0
```

## Rules

Every rule is on by default and reports a warning (`dart analyze` exits 2).
A use is flagged when the class or function is declared by Material itself:
in Flutter (`package:flutter/`, as imported through
`package:flutter/material.dart`) or in the `material_ui` package Flutter is
moving Material into (`package:material_ui/`). Matching is by the resolved
element, so a class of your own named `Card` is not flagged, and neither is a subclass of a Material widget or a
constructor tear-off. Only files under the package's `lib/` are checked;
`test/`, `integration_test/`, `test_driver/` and generated files (`.g.dart`,
`.freezed.dart`, `.mocks.dart`, `.gr.dart`, `.config.dart`) are skipped.

| Rule | Flags (any constructor, named ones and dot shorthands such as `const .new(...)` included) | Use instead |
|---|---|---|
| `no_raw_app_bar` | `AppBar`, `SliverAppBar` | the shared app bar |
| `no_raw_list_tile` | `ListTile`, `CheckboxListTile`, `RadioListTile`, `SwitchListTile`, `ExpansionTile` | the shared list row |
| `no_raw_dialog` | `AlertDialog`, `SimpleDialog`, `Dialog` | the shared dialog |
| `no_raw_bottom_sheet` | `BottomSheet`, and calls to `showModalBottomSheet`, `showBottomSheet` | the shared bottom sheet |
| `no_raw_button` | `ElevatedButton`, `FilledButton`, `TextButton`, `OutlinedButton`, `IconButton`, `FloatingActionButton` | the shared button |
| `no_raw_text_field` | `TextField`, `TextFormField` | the shared text field |
| `no_raw_chip` | `Chip`, `ActionChip`, `ChoiceChip`, `FilterChip`, `InputChip` | the shared chip |
| `no_raw_card` | `Card` | the shared card |
| `no_raw_snack_bar` | `SnackBar` | the shared snack bar |

Each warning names the raw class and points at the app's shared widget, which
the app lists in its `REFERENCES.md`, for example:

```
Raw AppBar in app code: use this repo's shared app bar widget (see its REFERENCES.md).
```

Its correction adds the ignore comment the shared widget's own file uses.

## Adopting it

In the app's `analysis_options.yaml`, at the top level (not under `analyzer:`):

```yaml
plugins:
  flutter_house_lints:
    git:
      url: https://github.com/zeeshanahmad0201/flutter-house-lints.git
      ref: v0.1.0
```

In the same PR, raise the app's SDK lower bound (see the requirement above).
After changing the `plugins:` section, restart the IDE's analysis server.

### Exempting the shared widget's file

The shared widget is the one place that may build the raw Material widget. Put
the namespaced ignore comment at the top of its file:

```dart
// ignore_for_file: flutter_house_lints/no_raw_app_bar
```

The plugin name prefix is required: a bare `// ignore_for_file: no_raw_app_bar`
does not silence a plugin diagnostic. Both forms are covered by
`test/plugin_test.dart`.

### Switching off one rule

To turn a whole rule off for a repo, set it to `false` under the plugin's
`diagnostics:` block:

```yaml
plugins:
  flutter_house_lints:
    git:
      url: https://github.com/zeeshanahmad0201/flutter-house-lints.git
      ref: v0.1.0
    diagnostics:
      no_raw_chip: false
```

## Adding a rule

One rule per component family, so a repo can switch off one. To add one:

1. A rule file in `lib/src/rules/` that extends `RawMaterialRule` with the rule
   id, the component word for the message and the Flutter class (and function)
   names; register it in `allRules` in `lib/main.dart`.
2. A test in `test/rules/` (copy a sibling: it lists every use the rule must
   flag), with any new classes added to `test/src/fake_flutter.dart`.
3. One raw use in `example/lib/page.dart` (`tool/check_example.sh` reads the
   rule ids from `lib/src/rules/`).
4. A row in the rules table above and an entry in `CHANGELOG.md`.
5. A new tag (see versioning).

## Versioning

Apps pin a tag (`ref: vX.Y.Z`) and bump it deliberately, in their own PR,
because a new rule can turn their CI red. A new rule or a wider match is a
minor version; a fix that flags less is a patch. The `version` in `pubspec.yaml`
matches the tag.

## Maintenance

- CI runs weekly (Mondays) as well as on each PR: the unit tests on the latest
  Dart stable, and `tool/check_example.sh` on the latest Flutter stable and on
  Flutter 3.47.9, the floor. A red weekly run means a new SDK broke the plugin
  before an app upgrades into it. The example check judges only this plugin's
  `no_raw_*` warnings (other analyzer infos, such as SDK deprecations, are
  printed but not judged); an analyzer error still fails it.
- GitHub switches off a public repo's scheduled workflows after 60 days with
  no activity. Each scheduled run re-enables `ci.yml` through the API (the
  `keepalive` job), which resets that timer, so the weekly check keeps running
  while the repo is quiet. If it ever stops, re-enable it under Actions.
- An `ignore_for_file: flutter_house_lints/...` line anywhere other than the
  shared widget's own file is a workaround, not an exemption: fix the page to
  use the shared widget. `grep -rn "flutter_house_lints/" lib/` in an app lists
  them.

## Known limits

- **Dart 3.12 and earlier skip a git source silently.** Checked on the same
  throwaway plugin and app: Dart 3.12.1 and 3.12.2 print "No issues found!" and
  exit 0 with the git entry (the plugin never loads), while Dart 3.13.0 and
  3.14.0 load it and report the warning. Dart 3.12's analysis server reads only
  the `version`, `hosted` and `path` forms of a plugin source; the `git` form
  arrived with Dart 3.13. The SDK lower bound above turns this into a `pub get`
  failure.
- **A constructor tear-off passes, by design.** `AppBar.new` passed as a
  function is a reference, not a build; only calls are flagged (plain, `const`,
  `new`, prefixed and dot-shorthand ones).
- **Rebuilding a component from primitives passes.** A page that builds its own
  button from `Material`, `InkWell` and `Text` is not flagged; review still has
  to catch that.
- **Only the nine Material families above.** Cupertino widgets and other
  Material widgets are not checked.
