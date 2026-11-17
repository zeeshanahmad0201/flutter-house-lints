/// A stand-in for `package:flutter/material.dart`: just the classes and
/// functions the rules match, with the named constructors the tests use.
/// Constructors are const, as Flutter's are, so tests can write `const X()`.
/// Shared by the rule tests and the plugin test so both match the same API.
const fakeMaterialLibrary = r'''
class AppBar { const AppBar(); }
class SliverAppBar { const SliverAppBar(); const SliverAppBar.medium(); const SliverAppBar.large(); }

class ListTile { const ListTile(); }
class CheckboxListTile { const CheckboxListTile(); const CheckboxListTile.adaptive(); }
class RadioListTile<T> { const RadioListTile(); const RadioListTile.adaptive(); }
class SwitchListTile { const SwitchListTile(); const SwitchListTile.adaptive(); }
class ExpansionTile { const ExpansionTile(); }

class AlertDialog { const AlertDialog(); const AlertDialog.adaptive(); }
class SimpleDialog { const SimpleDialog(); }
class Dialog { const Dialog(); const Dialog.fullscreen(); }

Future<T?> showDialog<T>() async => null;
Future<T?> showGeneralDialog<T>() async => null;
Future<T?> showAdaptiveDialog<T>() async => null;

class BottomSheet { const BottomSheet(); }
Future<T?> showModalBottomSheet<T>() async => null;
Object showBottomSheet() => Object();

class ElevatedButton { const ElevatedButton(); const ElevatedButton.icon(); }
class FilledButton { const FilledButton(); const FilledButton.tonal(); const FilledButton.icon(); }
class TextButton { const TextButton(); const TextButton.icon(); }
class OutlinedButton { const OutlinedButton(); const OutlinedButton.icon(); }
class IconButton { const IconButton(); const IconButton.filled(); const IconButton.outlined(); }
class FloatingActionButton {
  const FloatingActionButton();
  const FloatingActionButton.extended();
  const FloatingActionButton.small();
}

class TextField { const TextField(); }
class TextFormField { const TextFormField(); }

class Chip { const Chip(); }
class ActionChip { const ActionChip(); const ActionChip.elevated(); }
class ChoiceChip { const ChoiceChip(); const ChoiceChip.elevated(); }
class FilterChip { const FilterChip(); const FilterChip.elevated(); }
class InputChip { const InputChip(); }

class Card { const Card(); const Card.filled(); const Card.outlined(); }

class SnackBar { const SnackBar(); }

class Scaffold {
  const Scaffold();
  static Object of(Object context) => Object();
  static Object? maybeOf(Object context) => null;
}
class ScaffoldMessenger { const ScaffoldMessenger(); }
''';

/// A stand-in for `package:flutter/widgets.dart`: the widget base classes the
/// `no_stateful_widget` rule matches.
const fakeWidgetsLibrary = r'''
abstract class Widget { const Widget(); }
abstract class StatelessWidget extends Widget { const StatelessWidget(); }
abstract class StatefulWidget extends Widget { const StatefulWidget(); }
abstract class State<T extends StatefulWidget> {}
''';

/// A stand-in for `package:flutter_hooks/flutter_hooks.dart`.
const fakeHooksLibrary = r'''
import 'package:flutter/widgets.dart';
abstract class HookWidget extends StatelessWidget { const HookWidget(); }
abstract class StatefulHookWidget extends StatefulWidget { const StatefulHookWidget(); }
''';
