import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

/// Where Material's own components are declared: Flutter itself, and the
/// `material_ui` package Flutter is moving Material into.
const _materialLibraries = ['package:flutter/', 'package:material_ui/'];

/// Suffixes of generated files, which nobody edits by hand.
const _generatedSuffixes = [
  '.g.dart',
  '.freezed.dart',
  '.mocks.dart',
  '.gr.dart',
  '.config.dart',
];

/// The shared matcher behind every `no_raw_*` rule: flags a Material
/// component built directly in app code, so pages go through the app's shared
/// widget instead.
///
/// A use is flagged when it constructs one of [classes] (any constructor) or
/// calls one of [functions], and the class or function is declared in a
/// `package:flutter/` or `package:material_ui/` library. Matching is by resolved element, so a user's
/// own class of the same name, a subclass and a tear-off are not flagged.
/// Only files under the package's `lib/` are checked, and generated files are
/// skipped.
class RawMaterialRule extends AnalysisRule {
  RawMaterialRule({
    required super.name,
    required String component,
    required this.classes,
    this.functions = const {},
  }) : diagnosticCode = LintCode(
         name,
         // The problem message carries the pointer, because some tools
         // (`dart analyze --format=machine`) show only this part.
         "Raw {0} in app code: use this repo's shared $component widget "
         '(see its REFERENCES.md).',
         correctionMessage:
             "Only that widget's own file may use {0}, with "
             '// ignore_for_file: flutter_house_lints/$name.',
         severity: DiagnosticSeverity.WARNING,
       ),
       super(
         description:
             'Flags raw Material $component widgets in app code.',
       );

  /// Material class names whose constructors are flagged.
  final Set<String> classes;

  /// Flutter top-level function names whose calls are flagged.
  final Set<String> functions;

  // LintCode compares by name, so this per-instance code still matches
  // ignore comments and the plugin's diagnostics configuration.
  @override
  final LintCode diagnosticCode;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
    if (functions.isNotEmpty) registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final RawMaterialRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    var type = node.constructorName.element?.enclosingElement;
    if (type == null || !rule.classes.contains(type.name)) return;
    if (!_fromMaterial(type) || !_inAppCode()) return;
    rule.reportAtNode(node.constructorName, arguments: [type.name!]);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    var function = node.methodName.element;
    if (function is! TopLevelFunctionElement) return;
    if (!rule.functions.contains(function.name)) return;
    if (!_fromMaterial(function) || !_inAppCode()) return;
    rule.reportAtNode(node.methodName, arguments: [function.name!]);
  }

  bool _fromMaterial(Element element) {
    var uri = element.library?.uri.toString();
    return uri != null && _materialLibraries.any(uri.startsWith);
  }

  bool _inAppCode() {
    if (!context.isInLibDir) return false;
    var path = context.currentUnit?.file.path;
    return path != null && !_generatedSuffixes.any(path.endsWith);
  }
}
