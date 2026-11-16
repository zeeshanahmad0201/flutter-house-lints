import '../raw_material_rule.dart';

class NoRawButton extends RawMaterialRule {
  NoRawButton()
    : super(
        name: 'no_raw_button',
        component: 'button',
        classes: const {
          'ElevatedButton',
          'FilledButton',
          'TextButton',
          'OutlinedButton',
          'IconButton',
          'FloatingActionButton',
        },
      );
}
