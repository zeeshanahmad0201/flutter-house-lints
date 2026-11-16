/// A stand-in for `package:flutter/material.dart`: just the classes and
/// functions the rules match, with the named constructors the tests use.
/// Shared by the rule tests and the plugin test so both match the same API.
const fakeMaterialLibrary = r'''
class AppBar { AppBar(); }
class SliverAppBar { SliverAppBar(); SliverAppBar.medium(); SliverAppBar.large(); }

class ListTile { ListTile(); }
class CheckboxListTile { CheckboxListTile(); CheckboxListTile.adaptive(); }
class RadioListTile<T> { RadioListTile(); RadioListTile.adaptive(); }
class SwitchListTile { SwitchListTile(); SwitchListTile.adaptive(); }
class ExpansionTile { ExpansionTile(); }

class AlertDialog { AlertDialog(); AlertDialog.adaptive(); }
class SimpleDialog { SimpleDialog(); }
class Dialog { Dialog(); Dialog.fullscreen(); }

class BottomSheet { BottomSheet(); }
Future<T?> showModalBottomSheet<T>() async => null;
Object showBottomSheet() => Object();

class ElevatedButton { ElevatedButton(); ElevatedButton.icon(); }
class FilledButton { FilledButton(); FilledButton.tonal(); FilledButton.icon(); }
class TextButton { TextButton(); TextButton.icon(); }
class OutlinedButton { OutlinedButton(); OutlinedButton.icon(); }
class IconButton { IconButton(); IconButton.filled(); IconButton.outlined(); }
class FloatingActionButton {
  FloatingActionButton();
  FloatingActionButton.extended();
  FloatingActionButton.small();
}

class TextField { TextField(); }
class TextFormField { TextFormField(); }

class Chip { Chip(); }
class ActionChip { ActionChip(); ActionChip.elevated(); }
class ChoiceChip { ChoiceChip(); ChoiceChip.elevated(); }
class FilterChip { FilterChip(); FilterChip.elevated(); }
class InputChip { InputChip(); }

class Card { Card(); Card.filled(); Card.outlined(); }

class SnackBar { SnackBar(); }
''';
