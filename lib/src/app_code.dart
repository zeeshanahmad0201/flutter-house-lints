import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/element/element.dart';

/// Suffixes of generated files, which nobody edits by hand.
const generatedSuffixes = [
  '.g.dart',
  '.freezed.dart',
  '.mocks.dart',
  '.gr.dart',
  '.config.dart',
];

/// Whether the file being analyzed is app code: under the package's `lib/`
/// and not generated.
bool inAppCode(RuleContext context) {
  if (!context.isInLibDir) return false;
  var path = context.currentUnit?.file.path;
  return path != null && !generatedSuffixes.any(path.endsWith);
}

/// Whether [element] is declared in a library whose URI starts with one of
/// [uriPrefixes] (for example `package:flutter/`).
bool isDeclaredIn(Element element, List<String> uriPrefixes) {
  var uri = element.library?.uri.toString();
  return uri != null && uriPrefixes.any(uri.startsWith);
}
