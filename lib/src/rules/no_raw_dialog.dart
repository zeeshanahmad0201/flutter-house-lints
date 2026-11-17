import '../raw_material_rule.dart';

class NoRawDialog extends RawMaterialRule {
  NoRawDialog()
    : super(
        name: 'no_raw_dialog',
        component: 'dialog',
        classes: const {'AlertDialog', 'SimpleDialog', 'Dialog'},
        functions: const {
          'showDialog',
          'showGeneralDialog',
          'showAdaptiveDialog',
        },
      );
}
