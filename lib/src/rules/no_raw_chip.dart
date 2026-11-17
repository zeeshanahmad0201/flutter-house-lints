import '../raw_material_rule.dart';

class NoRawChip extends RawMaterialRule {
  NoRawChip()
    : super(
        name: 'no_raw_chip',
        component: 'chip',
        classes: const {
          'Chip',
          'ActionChip',
          'ChoiceChip',
          'FilterChip',
          'InputChip',
        },
      );
}
