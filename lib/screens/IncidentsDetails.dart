import 'package:flutter/material.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:intl/intl.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailScreen({super.key, required this.incident});

  static const primaryColor = Color(0xFF2E7D32);

  Widget _buildDetailRow(BuildContext context, String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(incident.dateOfIncident);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';

    final actionCompleted = incident.actionTaken != null && incident.actionTaken!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        incident.specificOffense,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(height: 30, thickness: 2),

                    _buildDetailRow(context, "Student Name", incident.fullName),
                    _buildDetailRow(context, "Student ID", incident.studentId),
                    _buildDetailRow(context, "Program", incident.program),
                    _buildDetailRow(context, "Year Level", incident.yearLevel),
                    _buildDetailRow(context, "Section", incident.section),
                    const Divider(height: 30, thickness: 1),

                    _buildDetailRow(context, "Offense Category", incident.offenseCategory),

                    _buildDetailRow(context, "Specific Offense", incident.specificOffense, 
                        valueStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    
                    _buildDetailRow(context, "Date of Incident", formattedDate),
                    _buildDetailRow(context, "Time of Incident", incident.timeOfIncident),
                    _buildDetailRow(context, "Location", incident.location),
                    
                    const Divider(height: 30, thickness: 1),

                    Text("Description:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      incident.description,
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
                                'SYSTEM RECOMMENDATION:', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                incident.recommendation ?? 'N/A',
                                style: TextStyle(fontSize: 16, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "Status: ${incident.status.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: incident.status.toLowerCase() == 'approved' || incident.status.toLowerCase() == 'resolved' ? primaryColor : (incident.status.toLowerCase() == 'pending' ? Colors.orange : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            if (actionCompleted)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FINAL ACTION TAKEN:', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14)
                      ),
                      const Divider(height: 15),
                      Text(
                        incident.actionTaken!,
                        style: const TextStyle(fontSize: 16, color: primaryColor),
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