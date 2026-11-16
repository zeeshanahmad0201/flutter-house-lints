import '../raw_material_rule.dart';

class NoRawCard extends RawMaterialRule {
  NoRawCard()
    : super(name: 'no_raw_card', component: 'card', classes: const {'Card'});
}
