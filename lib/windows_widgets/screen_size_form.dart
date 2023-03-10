import 'package:flutter/material.dart';
import 'package:windows_mouse_server/utils/display_strings.dart';

import '../utils/pair.dart';

class ScreenSizeForm extends StatefulWidget {
  final Pair<int, int> size;
  final void Function(Pair<int, int>) onChanged;
  final double width;
  final double spaceBetween;

  const ScreenSizeForm({
    super.key,
    required this.size,
    required this.onChanged,
    this.width = 200,
    this.spaceBetween = 10,
  });

  @override
  State<StatefulWidget> createState() => _ScreenSizeFormState();
}

class _ScreenSizeFormState extends State<ScreenSizeForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _widthController = TextEditingController(
      text: widget.size.first.toString(),
    );
    _heightController = TextEditingController(
      text: widget.size.second.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.width,
            child: TextFormField(
              controller: _widthController,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return DisplayStrings.formError;
                }
                return null;
              },
            ),
          ),
          SizedBox(height: widget.spaceBetween),
          SizedBox(
            width: widget.width,
            child: TextFormField(
              controller: _heightController,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return DisplayStrings.formError;
                }
                return null;
              },
            ),
          ),
          SizedBox(height: widget.spaceBetween),
          SizedBox(
            width: widget.width,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Pair<int, int> size = Pair(
                    int.parse(_widthController.text),
                    int.parse(_heightController.text),
                  );
                  widget.onChanged(size);
                }
              },
              child: const Icon(
                Icons.check,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
