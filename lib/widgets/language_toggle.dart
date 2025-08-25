import 'package:flutter/material.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: [
        DropdownMenuItem(value: "en", child: Text("English")),
        DropdownMenuItem(value: "ur", child: Text("Urdu")),
      ],
      onChanged: (v) {},
    );
  }
}
