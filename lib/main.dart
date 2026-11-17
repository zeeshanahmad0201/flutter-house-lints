import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';

import 'src/rules/no_raw_app_bar.dart';
import 'src/rules/no_raw_list_tile.dart';
import 'src/rules/no_raw_dialog.dart';
import 'src/rules/no_raw_bottom_sheet.dart';
import 'src/rules/no_raw_button.dart';
import 'src/rules/no_raw_text_field.dart';
import 'src/rules/no_raw_chip.dart';
import 'src/rules/no_raw_card.dart';
import 'src/rules/no_raw_snack_bar.dart';
import 'src/rules/no_raw_scaffold.dart';
import 'src/rules/no_stateful_widget.dart';

/// The entry point the analysis server loads.
final plugin = FlutterHouseLints();

/// Every rule this plugin ships: one per Material component, plus the
/// StatefulWidget convention.
final List<AnalysisRule> allRules = [
  NoRawAppBar(),
  NoRawListTile(),
  NoRawDialog(),
  NoRawBottomSheet(),
  NoRawButton(),
  NoRawTextField(),
  NoRawChip(),
  NoRawCard(),
  NoRawSnackBar(),
  NoRawScaffold(),
  NoStatefulWidget(),
];

class FlutterHouseLints extends Plugin {
  @override
  String get name => 'flutter_house_lints';

  @override
  void register(PluginRegistry registry) {
    // Warning rules are on by default; a repo switches one off in its
    // plugin `diagnostics:` block.
    for (var rule in allRules) {
      registry.registerWarningRule(rule);
    }
  }
}
