import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/providers/incident_provider.dart';
import 'package:misconductmobile/providers/dashboard_stats_provider.dart'; 
import 'EditIncident.dart'; 

class IncidentDetailScreen extends StatefulWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

  static const primaryColor = Color(0xFF84BE78);
  static const Color lightGreenBackground = Color(0xFFE8F5E9);

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  Incident? _currentIncident;

  bool _isLoadingDetails = true;
  bool _isDeleting = false;

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '00:00';

    final parts = timeString.split(':');

    if (parts.length >= 2) {
      try {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      } catch (e) {
        return timeString;
      }
    }
    return timeString;
  }

  Future<void> _fetchIncidentDetails() async {
      if (widget.incident.incidentId == null) {
          setState(() {
              _isLoadingDetails = false;
              _currentIncident = widget.incident.copyWith(
                  timeOfIncident: _formatTime(widget.incident.timeOfIncident),
              );
          });
          return;
      }

      try {
          final provider = Provider.of<IncidentProvider>(context, listen: false);

          final fetchedIncident = await provider.fetchIncidentById(widget.incident.incidentId!);

          final normalizedIncident = fetchedIncident.copyWith(
              timeOfIncident: _formatTime(fetchedIncident.timeOfIncident),
          );

          setState(() {
              _currentIncident = normalizedIncident;
              _isLoadingDetails = false;
          });
      } catch (e) {
          print("Error fetching full incident details: $e");
          setState(() {
              _currentIncident = widget.incident.copyWith(
                  timeOfIncident: _formatTime(widget.incident.timeOfIncident),
              );
              _isLoadingDetails = false;
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to load full incident details."), backgroundColor: Colors.red),
              );
          });
      }
  }


  @override
  void initState() {
    super.initState();
    _fetchIncidentDetails();
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen() async {
      if (_currentIncident == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditIncidentScreen(incidentToEdit: _currentIncident!),
      ),
    );

    if (result != null && result is Incident) {
        _fetchIncidentDetails();
    }
  }

  Future<void> _confirmAndDelete() async {
      if (_currentIncident == null) return;
    final bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Confirm Deletion ⚠️'),
          content: Text(
            'Are you sure you want to soft delete the incident report for ${_currentIncident!.fullName}? Action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: IncidentDetailScreen.primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
        ) ??
        false;

    if (confirm) {
      _deleteIncident();
    }
  }

  Future<void> _deleteIncident() async {
    if (!mounted || _currentIncident == null) return;

    setState(() => _isDeleting = true);

    try {
      final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
      
      final dashboardProvider = Provider.of<DashboardStatsProvider>(context, listen: false);

      await incidentProvider.deleteIncident(_currentIncident!);

      await dashboardProvider.fetchAllStats();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Incident report for ${_currentIncident!.fullName} successfully deleted.',
          ),
          backgroundColor: IncidentDetailScreen.primaryColor,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete incident: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoadingDetails || _currentIncident == null) {
        return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(IncidentDetailScreen.primaryColor)));
    }

    final date = DateTime.tryParse(_currentIncident!.dateOfIncident);
    final formattedDate =
        date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';

    final finalActionOrRecommendation = _currentIncident!.actionTaken != null && _currentIncident!.actionTaken!.isNotEmpty
        ? _currentIncident!.actionTaken!
        : (_currentIncident!.recommendation ?? 'No action recorded.');

    final actionCompleted = _currentIncident!.actionTaken != null &&
        _currentIncident!.actionTaken!.isNotEmpty;

    final isActionDifferentFromRecommendation = actionCompleted &&
        (_currentIncident!.actionTaken != (_currentIncident!.recommendation ?? ''));


    return Scaffold(
      backgroundColor: IncidentDetailScreen.lightGreenBackground,
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: IncidentDetailScreen.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        _currentIncident!.specificOffense,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: IncidentDetailScreen.primaryColor,
                        ),
                      ),
                    ),

                    const Divider(height: 30, thickness: 2),

                    _buildDetailRow(
                        context, "Student Name", _currentIncident!.fullName),
                    _buildDetailRow(
                        context, "Student ID", _currentIncident!.studentId),

                    const Divider(height: 10, thickness: 1), 

                    _buildDetailRow(
                        context, "Program", _currentIncident!.program),
                    _buildDetailRow(
                        context, "Year Level", _currentIncident!.yearLevel),
                    _buildDetailRow(
                        context, "Section", _currentIncident!.section),

                    const Divider(height: 30, thickness: 1),

                    _buildDetailRow(context, "Offense Category",
                        _currentIncident!.offenseCategory),
                    _buildDetailRow(context, "Specific Offense",
                        _currentIncident!.specificOffense,
                        valueStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),

                    const Divider(height: 10, thickness: 1), 
                    _buildDetailRow(
                        context, "Date of Incident", formattedDate),
                    _buildDetailRow(context, "Time of Incident",
                        _currentIncident!.timeOfIncident),
                    _buildDetailRow(
                        context, "Location", _currentIncident!.location),

                    const Divider(height: 30, thickness: 1),

                    Text(
                      "Description:",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentIncident!.description,
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DISCIPLINARY ACTION / RECOMMENDATION:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                finalActionOrRecommendation,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "Status: ${_currentIncident!.status.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _currentIncident!.status.toLowerCase() ==
                                        'approved' ||
                                        _currentIncident!.status.toLowerCase() ==
                                        'resolved'
                                ? IncidentDetailScreen.primaryColor
                                : (_currentIncident!.status.toLowerCase() ==
                                            'pending'
                                        ? Colors.orange
                                        : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isDeleting ? null : _navigateToEditScreen,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IncidentDetailScreen.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _confirmAndDelete,
                    icon: _isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Icon(Icons.delete, color: Colors.white),
                    label: Text(_isDeleting ? 'Deleting...' : 'Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (isActionDifferentFromRecommendation)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: IncidentDetailScreen.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FINAL ACTION TAKEN:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: IncidentDetailScreen.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const Divider(height: 15),
                      Text(
                        _currentIncident!.actionTaken!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: IncidentDetailScreen.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}