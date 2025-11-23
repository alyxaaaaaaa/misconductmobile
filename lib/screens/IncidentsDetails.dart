import 'package:flutter/material.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:intl/intl.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;

  // The constructor accepts the Incident object
  const IncidentDetailScreen({super.key, required this.incident});

  static const primaryColor = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    // Format date and time
    final date = DateTime.tryParse(incident.dateOfIncident);
    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
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

                // Display key student information
                _buildDetailRow(context, "Student Name", incident.fullName),
                _buildDetailRow(context, "Student ID", incident.studentId),
                _buildDetailRow(context, "Program", incident.program),
                _buildDetailRow(context, "Year Level", incident.yearLevel),
                _buildDetailRow(context, "Section", incident.section),
                const Divider(height: 30, thickness: 1),

                // Display incident specifics
                _buildDetailRow(context, "Offense Category", incident.offenseCategory),
                _buildDetailRow(context, "Date of Incident", formattedDate),
                _buildDetailRow(context, "Time of Incident", incident.timeOfIncident),
                _buildDetailRow(context, "Location", incident.location),
                
                const Divider(height: 30, thickness: 1),

                // Description
                Text("Description:", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  incident.description,
                  style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 20),
                
                // Status
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Status: ${incident.status.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: incident.status.toLowerCase() == 'approved' ? primaryColor : (incident.status.toLowerCase() == 'pending' ? Colors.orange : Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}