import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CreateUpdateEntryView extends StatefulWidget {
  const CreateUpdateEntryView({super.key});

  @override
  State<CreateUpdateEntryView> createState() => _CreateUpdateEntryViewState();
}

class _CreateUpdateEntryViewState extends State<CreateUpdateEntryView> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text("Create Entry"),);
  }
}
