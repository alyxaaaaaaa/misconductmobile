import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../provider/incident_provider.dart'; 
import 'package:intl/intl.dart';
import 'package:misconductmobile/screens/IncidentsDetails.dart'; 

class IncidentsList extends StatefulWidget {
  const IncidentsList({super.key});

  @override
  State<IncidentsList> createState() => IncidentsListState();
}

class IncidentsListState extends State<IncidentsList> {
  static const primaryColor = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<IncidentProvider>(context, listen: false).loadIncidents()
    );
  }

  void refreshIncidents() {
    Provider.of<IncidentProvider>(context, listen: false).loadIncidents();
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
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final incidents = incidentProvider.incidents;
    final isLoading = incidentProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Filed Incidents"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: incidentProvider.loadIncidents, 
        color: primaryColor,
        child: Container(
          padding: const EdgeInsets.only(top: 8.0),

          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : (incidents.isEmpty 
                  ? const Center(
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
                    )
                  : ListView.builder(
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
                              incident.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
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
                    )
                  ),
                ),
              ),
            );
          }
        }