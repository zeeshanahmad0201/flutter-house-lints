import '../raw_material_rule.dart';

class NoRawTextField extends RawMaterialRule {
  NoRawTextField()
    : super(
        name: 'no_raw_text_field',
        component: 'text field',
        classes: const {'TextField', 'TextFormField'},
      );
}
