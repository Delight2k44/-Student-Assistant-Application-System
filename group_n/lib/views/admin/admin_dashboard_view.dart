/*
 * Student Numbers: 223022577, 224132354, 222070281, 223043998, 221026798
 * Student Names: TD Tshitangano, L Koloi, MA Mohapi, IR Salam, GA Leeuw
 * Question: Admin Dashboard (Read / Update / Delete Operations)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/route_manager.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    // Admin needs to see EVERYTHING, not just their own
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appVM = context.watch<ApplicationViewModel>();
    final authVM = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
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
          : appVM.allApplications.isEmpty
              ? const Center(child: Text("No student applications to review."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appVM.allApplications.length,
                  itemBuilder: (context, index) {
                    final app = appVM.allApplications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(app.status).withOpacity(0.1),
                          child: Icon(Icons.person, color: _getStatusColor(app.status)),
                        ),
                        title: Text(app.module1, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Status: ${app.status.toUpperCase()}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Year of Study: ${app.yearOfStudy}'),
                                if (app.module2 != null) Text('Second Module: ${app.module2}'),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _updateStatus(context, app.id!, 'approved'),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _updateStatus(context, app.id!, 'rejected'),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Reject'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () => _confirmDelete(context, app.id!),
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    label: const Text('Remove Application', style: TextStyle(color: Colors.grey)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _updateStatus(BuildContext context, String id, String newStatus) async {
    await context.read<ApplicationViewModel>().updateApplicationStatus(id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application $newStatus')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Remove this application from the system permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await context.read<ApplicationViewModel>().deleteApplication(id);
              if (mounted) {
                Navigator.pop(context);
                context.read<ApplicationViewModel>().fetchAllApplications();
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}