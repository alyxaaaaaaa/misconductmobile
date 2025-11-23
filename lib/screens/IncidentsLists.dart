import 'package:flutter/material.dart';
import 'package:misconductmobile/models/incident.dart';
import 'package:misconductmobile/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:misconductmobile/screens/IncidentsDetails.dart'; // Ensure this is imported

class IncidentsList extends StatefulWidget {
  const IncidentsList({super.key});

  @override
  // FIX: Use the public state class name
  State<IncidentsList> createState() => IncidentsListState();
}

// FIX: Make the State class public (remove underscore)
class IncidentsListState extends State<IncidentsList> {
  // Colors
  static const primaryColor = Color(0xFF2E7D32);
  
  late Future<List<Incident>> _incidentsFuture;

  @override
  void initState() {
    super.initState();
    _incidentsFuture = _fetchUserIncidents();
  }

  // PUBLIC METHOD: Called by Dashboard to force a data refresh
  void refreshIncidents() {
    setState(() {
      _incidentsFuture = _fetchUserIncidents();
    });
  }

  Future<List<Incident>> _fetchUserIncidents() async {
    try {
      return await ApiService.fetchUserIncidents();
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'approved':
        chipColor = primaryColor;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Filed Incidents"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserIncidents, 
        color: primaryColor,
        child: Container(
          padding: const EdgeInsets.only(top: 8.0),
          child: FutureBuilder<List<Incident>>(
            future: _incidentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              } else if (snapshot.hasError) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error loading incidents: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 40, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'No incidents have been filed yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              } else {
                final incidents = snapshot.data!;
                return ListView.builder(
                  itemCount: incidents.length,
                  padding: const EdgeInsets.only(bottom: 80), 
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    final date = DateTime.tryParse(incident.dateOfIncident);
                    final formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.warning_amber_rounded, color: primaryColor),
                        ),
                        title: Text(
                          // Student Name is the title
                          incident.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            // Specific Offense is the primary subtitle line
                            Text(
                              incident.specificOffense,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const SizedBox(height: 2),
                            Text('${incident.offenseCategory} - ID: ${incident.studentId}'),
                            Text('Date: $formattedDate at ${incident.timeOfIncident}'),
                          ],
                        ),
                        trailing: _buildStatusChip(incident.status),

                        // 🎯 NEW: Navigation to the detail screen
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => IncidentDetailScreen(incident: incident),
                                ),
                            );
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}