import '../raw_material_rule.dart';

class NoRawSnackBar extends RawMaterialRule {
  NoRawSnackBar()
    : super(
        name: 'no_raw_snack_bar',
        component: 'snack bar',
        classes: const {'SnackBar'},
      );
}
