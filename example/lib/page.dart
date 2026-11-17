import 'package:flutter/material.dart';

/// One raw use per rule: tool/check_example.sh expects each rule to fire here
/// exactly once. The snack bar is a dot shorthand (`const .new(...)`), so that
/// syntax is checked end to end too.
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: ListView(
        children: [
          const ListTile(title: Text('Row')),
          const Card(child: TextField()),
          const Chip(label: Text('Chip')),
          ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const SizedBox(height: 100),
              );
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => const SizedBox(height: 200),
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(const .new(content: Text('Done')));
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}
