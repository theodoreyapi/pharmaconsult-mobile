import 'package:flutter/material.dart';

class VaccinPage extends StatefulWidget {
  const VaccinPage({super.key});

  @override
  State<VaccinPage> createState() => _VaccinPageState();
}

class _VaccinPageState extends State<VaccinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vaccination"),
      ),
    );
  }
}
