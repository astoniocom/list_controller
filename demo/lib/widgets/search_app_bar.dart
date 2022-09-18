import 'package:demo/models.dart';
import 'package:demo/screens/settings_screen.dart';
import 'package:demo/settings.dart';
import 'package:demo/widgets/search_field.dart';
import 'package:demo/widgets/source_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComplexExampleAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ComplexExampleAppBar({
    required this.title,
    required this.onChanged,
    required this.sources,
    required this.query,
    super.key,
  });

  final String title;
  final List<SourceFile> sources;

  final Function(String) onChanged;
  final String query;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ComplexExampleAppBar> createState() => _ComplexExampleAppBarState();

  static const searchBtnKey = Key('searchAppBarSearchButton');
  static const backBtnKey = Key('searchAppBarBackButton');
  static const openSettingsBtnKey = Key('searchAppBarOpenSettingsButton');
}

class _ComplexExampleAppBarState extends State<ComplexExampleAppBar> {
  bool _searchMode = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: !_searchMode
          ? Text(widget.title)
          : SearchField(
              onChanged: widget.onChanged,
              onClear: () => setState(() {
                _searchMode = false;
                widget.onChanged('');
              }),
              query: widget.query,
            ),
      leading: _searchMode
          ? IconButton(
              key: ComplexExampleAppBar.backBtnKey,
              onPressed: () => setState(() {
                    _searchMode = false;
                  }),
              icon: const Icon(Icons.chevron_left))
          : null,
      actions: !_searchMode
          ? [
              IconButton(
                  key: ComplexExampleAppBar.searchBtnKey,
                  onPressed: () {
                    setState(() {
                      _searchMode = true;
                    });
                  },
                  icon: const Icon(Icons.search)),
              IconButton(
                key: ComplexExampleAppBar.openSettingsBtnKey,
                onPressed: () async => SettingsScreen.open(context: context, settings: context.read<SettingsController>()),
                icon: const Icon(Icons.settings_outlined),
              ),
              SourceButton(sources: widget.sources)
            ]
          : null,
    );
  }
}
