// ignore_for_file: flutter_house_lints/no_raw_app_bar
import 'package:flutter/material.dart';

/// The app's shared app bar: the one file allowed to build a raw AppBar.
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(title: Text(title));
}
