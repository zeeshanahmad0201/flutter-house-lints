import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../app_code.dart';

/// The two base classes that mean a `State` class: Flutter's
/// `StatefulWidget` and flutter_hooks' `StatefulHookWidget`, each with the
/// library prefix it must be declared in.
const _banned = {
  'StatefulWidget': 'package:flutter/',
  'StatefulHookWidget': 'package:flutter_hooks/',
};

/// Flags a class whose direct superclass is `StatefulWidget` or
/// `StatefulHookWidget`, so app code uses a hook widget instead. This rule
/// enforces a house convention rather than bounding Material, so it has its
/// own matcher instead of extending `RawMaterialRule`.
///
/// Matching is by resolved element: an indirect subclass (the app's own base
/// is where it is flagged), a `State<T>` subclass and an app's own class
/// named `StatefulWidget` are not flagged. Only `lib/` is checked and
/// generated files are skipped.
class NoStatefulWidget extends AnalysisRule {
  NoStatefulWidget()
    : super(
        name: 'no_stateful_widget',
        description: 'Flags StatefulWidget subclasses in app code.',
      );

  static const code = LintCode(
    'no_stateful_widget',
    '{0} in app code: use a hook widget (`HookWidget` from flutter_hooks) '
        'instead.',
    correctionMessage:
        'Only a file that truly needs one may use it, with '
        '// ignore_for_file: flutter_house_lints/no_stateful_widget.',
    severity: DiagnosticSeverity.WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addClassDeclaration(this, visitor);
    registry.addClassTypeAlias(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final NoStatefulWidget rule;
  final RuleContext context;

  @override
  void visitClassDeclaration(ClassDeclaration node) =>
      _check(node.extendsClause?.superclass);

  /// `class X = StatefulWidget with M;`
  @override
  void visitClassTypeAlias(ClassTypeAlias node) => _check(node.superclass);

  void _check(NamedType? superclass) {
    var element = superclass?.element;
    var library = _banned[element?.name];
    if (superclass == null || element == null || library == null) return;
    if (!isDeclaredIn(element, [library]) || !inAppCode(context)) return;
    rule.reportAtNode(superclass, arguments: [element.name!]);
  }
}
