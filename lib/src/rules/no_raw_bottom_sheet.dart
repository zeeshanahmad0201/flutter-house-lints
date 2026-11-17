import '../raw_material_rule.dart';

class NoRawBottomSheet extends RawMaterialRule {
  NoRawBottomSheet()
    : super(
        name: 'no_raw_bottom_sheet',
        component: 'bottom sheet',
        classes: const {'BottomSheet'},
        functions: const {'showModalBottomSheet', 'showBottomSheet'},
      );
}
