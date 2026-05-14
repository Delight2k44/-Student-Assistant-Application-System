import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/application_model.dart';
import '../viewmodels/application_viewmodel.dart';

/// Screen 1.4 — Edit Application (only available while status = pending)
class EditApplicationView extends StatefulWidget {
  const EditApplicationView({super.key});

  @override
  State<EditApplicationView> createState() => _EditApplicationViewState();
}

class _EditApplicationViewState extends State<EditApplicationView> {
  final _formKey = GlobalKey<FormState>();

  // The application passed via Navigator arguments
  StudentApplication? _application;

  String? _selectedYear;
  final List<String> _selectedModules = [];

  final List<String> _availableYears = [
    '1st Year',
    '2nd Year',
    '3rd Year',
  ];

  final List<String> _availableModules = [
    'TPG316C',
    'ITP216C',
    'ISS316C',
    'NWS216C',
  ];

  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      // Receive the application object from the previous screen
      _application =
          ModalRoute.of(context)!.settings.arguments as StudentApplication?;

      if (_application != null) {
        // Pre-fill the form with existing values
        _selectedYear = _application!.yearOfStudy;
        _selectedModules
          ..clear()
          ..addAll(_application!.modules);
      }
      _initialised = true;
    }
  }

  void _toggleModule(String module) {
    setState(() {
      if (_selectedModules.contains(module)) {
        _selectedModules.remove(module);
      } else {
        if (_selectedModules.length < 2) {
          _selectedModules.add(module);
        } else {
          _showSnackBar('Maximum 2 modules allowed', isError: true);
        }
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color:
                    isError ? cs.onErrorContainer : cs.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor:
              isError ? cs.errorContainer : cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _handleSave() async {
    if (_application == null) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedModules.isEmpty) {
      _showSnackBar('Please select at least one module', isError: true);
      return;
    }

    final vm = context.read<ApplicationViewModel>();
    vm.clearMessages();

    final success = await vm.updateApplication(
      _application!.id!,
      {
        'year_of_study': _selectedYear,
        'modules': _selectedModules,
      },
    );

    if (success && mounted) {
      _showSnackBar('Application updated successfully!');
      // Small delay so the snackbar is visible before popping
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, true); // true = was updated
    } else if (mounted && vm.errorMessage != null) {
      _showSnackBar(vm.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApplicationViewModel>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_application == null) {
      return const Scaffold(
        body: Center(child: Text('No application data found.')),
      );
    }

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        title: const Text(
          'Edit Application',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can only edit a pending application. '
                      'Once reviewed by admin it becomes locked.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Year of Study ──
            Text(
              'Year of Study',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              hint: const Text('Select year'),
              items: _availableYears
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedYear = v),
              validator: (v) =>
                  v == null ? 'Please select your year of study' : null,
            ),
            const SizedBox(height: 24),

            // ── Modules ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modules',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_selectedModules.length} / 2 selected',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._availableModules.map((module) {
              final isSelected = _selectedModules.contains(module);
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? cs.primary
                        : cs.outlineVariant.withOpacity(0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleModule(module),
                  title: Text(module,
                      style:
                          const TextStyle(fontWeight: FontWeight.w500)),
                  activeColor: cs.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              );
            }),

            if (_selectedModules.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Please select at least one module',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.error),
                ),
              ),

            const SizedBox(height: 32),

            // ── Save Button ──
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: vm.isSubmitting ? null : _handleSave,
                icon: vm.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  vm.isSubmitting ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
