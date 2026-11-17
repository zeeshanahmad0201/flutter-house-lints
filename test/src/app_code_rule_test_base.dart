// test_reflective_loader runs methods named test_*.
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_house_lints/src/app_code.dart';

/// The app-code scope every rule shares (`inAppCode`): nothing under `test/`
/// and no generated file. A rule's test class supplies a source it flags.
abstract class AppCodeRuleTest extends AnalysisRuleTest {
  /// Source the rule flags when it sits in an ordinary `lib/` file.
  String get flaggedSource;

  Future<void> test_testDirectoryIsNotFlagged() async {
    var file = newFile(
      '$testPackageRootPath/test/page_test.dart',
      flaggedSource,
    );
    await assertNoDiagnosticsInFile(file.path);
  }

  Future<void> test_generatedFilesAreNotFlagged() async {
    for (var suffix in generatedSuffixes) {
      var file = newFile('$testPackageRootPath/lib/page$suffix', flaggedSource);
      await assertNoDiagnosticsInFile(file.path);
    }
  }
}
