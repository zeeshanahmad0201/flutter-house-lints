import '../raw_material_rule.dart';

class NoRawAppBar extends RawMaterialRule {
  NoRawAppBar()
    : super(
        name: 'no_raw_app_bar',
        component: 'app bar',
        classes: const {'AppBar', 'SliverAppBar'},
      );
}
