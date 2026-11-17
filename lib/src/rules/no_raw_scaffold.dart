import '../raw_material_rule.dart';

class NoRawScaffold extends RawMaterialRule {
  NoRawScaffold()
    : super(
        name: 'no_raw_scaffold',
        component: 'scaffold',
        classes: const {'Scaffold'},
      );
}
