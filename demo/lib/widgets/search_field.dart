import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    required this.onChanged,
    required this.onClear,
    required this.query,
    super.key,
  });

  final Function(String) onChanged;
  final Function() onClear;
  final String query;
  static const inputQueryKey = Key('searchFieldInputQuery');
  static const clearBtnKey = Key('searchFieldClearBtn');

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final queryController = TextEditingController();

  @override
  void initState() {
    queryController.text = widget.query;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kMinInteractiveDimension,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: queryController,
        key: SearchField.inputQueryKey,
        autofocus: true,
        onChanged: (value) {
          setState(() {});
          widget.onChanged(value);
        },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: queryController.text.isNotEmpty
              ? IconButton(
                  key: SearchField.clearBtnKey,
                  icon: const Icon(Icons.clear),
                  onPressed: widget.onClear,
                )
              : null,
          hintText: 'Search...',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
