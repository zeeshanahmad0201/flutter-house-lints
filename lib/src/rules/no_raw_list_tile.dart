import '../raw_material_rule.dart';

class NoRawListTile extends RawMaterialRule {
  NoRawListTile()
    : super(
        name: 'no_raw_list_tile',
        component: 'list row',
        classes: const {
          'ListTile',
          'CheckboxListTile',
          'RadioListTile',
          'SwitchListTile',
          'ExpansionTile',
        },
      );
}
