import 'package:flutter/material.dart';

class ApplicationDetailView extends StatefulWidget {
  const ApplicationDetailView({super.key});

  @override
  State<ApplicationDetailView> createState() => _ApplicationDetailViewState();
}

class _ApplicationDetailViewState extends State<ApplicationDetailView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Application Detail')),
    );
  }
}
