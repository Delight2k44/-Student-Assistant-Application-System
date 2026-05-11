/*
 * Student Numbers: 223022577, 224132354, 222070281, 223043998, 221026798
 * Student Names: TD Tshitangano, L Koloi, MA Mohapi, IR Salam, GA Leeuw
 * Question: Application Detail View (Read / Delete Operation)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';

class ApplicationDetailView extends StatelessWidget {
  const ApplicationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the application object passed via navigation arguments
    final ApplicationModel application = 
        ModalRoute.of(context)!.settings.arguments as ApplicationModel;

    final isPending = application.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusHeader(application.status),
            const SizedBox(height: 20),
            _buildDetailCard(application),
            const SizedBox(height: 30),
            
            // Only show action buttons if the application is still pending
            if (isPending) ...[
              _buildActionButton(
                label: 'Edit Application',
                icon: Icons.edit_outlined,
                color: const Color(0xFF1565C0),
                onTap: () {
                  // TODO: Navigate to Edit Form (Update Operation)
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Delete Application',
                icon: Icons.delete_outline_rounded,
                color: Colors.red.shade700,
                onTap: () => _confirmDelete(context, application.id!),
              ),
            ] else 
              _buildLockedNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Current Status:', style: TextStyle(fontWeight: FontWeight.bold)),
          Chip(
            label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: status.toLowerCase() == 'approved' ? Colors.green : 
                           status.toLowerCase() == 'rejected' ? Colors.red : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(ApplicationModel app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _infoRow(Icons.school, 'Year of Study', app.yearOfStudy),
          const Divider(height: 30),
          _infoRow(Icons.book, 'Primary Module', app.module1),
          _infoRow(Icons.layers, 'Level', app.academicLevel1),
          if (app.module2 != null) ...[
            const Divider(height: 30),
            _infoRow(Icons.book, 'Secondary Module', app.module2!),
            _infoRow(Icons.layers, 'Level', app.academicLevel2!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.withAlpha(20), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(child: Text('This application is processed and can no longer be modified.', style: TextStyle(fontSize: 12, color: Colors.grey))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String appId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to withdraw this application? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await context.read<ApplicationViewModel>().deleteApplication(appId);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, RouteManager.studentHome);
              }
            }, 
            child: const Text('DELETE', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}