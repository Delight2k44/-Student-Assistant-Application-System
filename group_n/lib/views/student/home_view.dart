/*
 * Student Numbers: 223022577, 224132354, 222070281, 223043998, 221026798
 * Student Names: TD Tshitangano, L Koloi, MA Mohapi, IR Salam, GA Leeuw
 * Question: Home View (Student Portal)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Load data as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final appVM = context.watch<ApplicationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authVM.logout();
              Navigator.pushReplacementNamed(context, RouteManager.login);
            },
          ),
        ],
      ),
      body: appVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appVM.myApplications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appVM.myApplications.length,
                  itemBuilder: (context, index) {
                    final app = appVM.myApplications[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('Module: ${app.module1}'),
                        subtitle: Text('Submitted on: ${app.createdAt.toString().split(' ')[0]}'),
                        trailing: _buildStatusChip(app.status),
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            RouteManager.applicationDetail, 
                            arguments: app
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteManager.applicationForm),
        label: const Text('Apply Now'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No applications found.", style: TextStyle(fontSize: 18)),
          const Text("Click 'Apply Now' to start."),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange; // Pending
    }
    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
    );
  }
}