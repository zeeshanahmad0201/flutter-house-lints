// test_reflective_loader runs methods named test_*.
// ignore_for_file: non_constant_identifier_names

// ignore: implementation_imports
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:flutter_house_lints/src/rules/no_stateful_widget.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/app_code_rule_test_base.dart';
import '../src/fake_flutter.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoStatefulWidgetTest);
  });
}

@reflectiveTest
class NoStatefulWidgetTest extends AppCodeRuleTest {
  @override
  void setUp() {
    rule = NoStatefulWidget();
    newPackage('flutter').addFile('lib/widgets.dart', fakeWidgetsLibrary);
    newPackage('flutter_hooks')
        .addFile('lib/flutter_hooks.dart', fakeHooksLibrary);
    super.setUp();
  }

  @override
  String get flaggedSource =>
      '${_widgets}class Page extends StatefulWidget {}\n';

  static const _widgets = "import 'package:flutter/widgets.dart';\n\n";
  static const _hooks =
      "import 'package:flutter_hooks/flutter_hooks.dart';\n\n";

  /// A diagnostic on the first `range` in [content], naming [name].
  ExpectedDiagnostic _flag(String content, String range, String name) => lint(
    content.indexOf(range),
    range.length,
    messageContainsAll: [
      '$name in app code: use a hook widget (`HookWidget` from flutter_hooks) '
          'instead.',
    ],
    correctionContains:
        'Only a file that truly needs one may use it, with '
        '// ignore_for_file: flutter_house_lints/no_stateful_widget.',
  );

  Future<void> test_flagsExtendsStatefulWidget() async {
    var content = '${_widgets}class Page extends StatefulWidget {}\n';
    await assertDiagnostics(content, [
      _flag(content, 'StatefulWidget', 'StatefulWidget'),
    ]);
  }

  Future<void> test_flagsStatefulHookWidget() async {
    var content = '${_hooks}class Page extends StatefulHookWidget {}\n';
    await assertDiagnostics(content, [
      _flag(content, 'StatefulHookWidget', 'StatefulHookWidget'),
    ]);
  }

  Future<void> test_flagsPrefixedImport() async {
    var content =
        "import 'package:flutter/widgets.dart' as w;\n\n"
        'class Page extends w.StatefulWidget {}\n';
    await assertDiagnostics(content, [
      _flag(content, 'w.StatefulWidget', 'StatefulWidget'),
    ]);
  }

  Future<void> test_flagsAbstractClass() async {
    var content = '${_widgets}abstract class Page extends StatefulWidget {}\n';
    await assertDiagnostics(content, [
      _flag(content, 'StatefulWidget', 'StatefulWidget'),
    ]);
  }

  Future<void> test_flagsClassTypeAlias() async {
    var content =
        '${_widgets}mixin M {}\nclass Page = StatefulWidget with M;\n';
    await assertDiagnostics(content, [
      _flag(content, 'StatefulWidget', 'StatefulWidget'),
    ]);
  }

  Future<void> test_indirectSubclassIsNotFlaggedButItsBaseIs() async {
    var content =
        '${_widgets}class Base extends StatefulWidget {}\n'
        'class Page extends Base {}\n';
    await assertDiagnostics(content, [
      _flag(content, 'StatefulWidget', 'StatefulWidget'),
    ]);
  }

  Future<void> test_stateSubclassIsNotFlagged() async {
    var content =
        '${_widgets}class Page extends StatefulWidget {}\n'
        'class PageState extends State<Page> {}\n';
    await assertDiagnostics(content, [
      _flag(content, 'StatefulWidget', 'StatefulWidget'),
    ]);
  }

  Future<void> test_userClassNamedStatefulWidgetIsNotFlagged() async {
    await assertNoDiagnostics(
      'class StatefulWidget {}\nclass Page extends StatefulWidget {}\n',
    );
  }

  Future<void> test_hookAndStatelessWidgetsAreNotFlagged() async {
    await assertNoDiagnostics(
      "import 'package:flutter/widgets.dart';\n"
      '$_hooks'
      'class A extends HookWidget {}\n'
      'class B extends StatelessWidget {}\n',
    );
  }
}
