import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../providers/incident_provider.dart'; 
import '../providers/dashboard_stats_provider.dart';
import 'package:intl/intl.dart';
import 'package:misconductmobile/screens/IncidentsDetails.dart'; 

class IncidentsList extends StatefulWidget {
  const IncidentsList({super.key});

  @override
  State<IncidentsList> createState() => IncidentsListState();
}

class IncidentsListState extends State<IncidentsList> {
  static const primaryColor = Color(0xFF2E7D32); 
  static const Color lightGreenBackground = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<IncidentProvider>(context, listen: false).loadIncidents()
    );
  }

  // Remove seconds (HH:MM:SS → HH:MM)
  String _formatTime(String timeString) {
    if (timeString.contains(":")) {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return "${parts[0]}:${parts[1]}";
      }
    }
    return timeString;
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'pending': chipColor = Colors.orange; break;
      case 'approved': chipColor = primaryColor; break;
      case 'rejected': chipColor = Colors.red; break;
      default: chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IncidentProvider>(context);
    final incidents = provider.incidents;

    return Scaffold(
      backgroundColor: lightGreenBackground,
      appBar: AppBar(
        title: const Text("Incidents List"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: provider.loadIncidents, 
        color: primaryColor,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : (incidents.isEmpty
                ? const Center(
                    child: Text("No incidents found.", style: TextStyle(fontSize: 18, color: Colors.grey))
                  )
                : ListView.builder(
                    itemCount: incidents.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      final date = DateTime.tryParse(incident.dateOfIncident);
                      final formattedDate = date != null
                          ? DateFormat('MMM dd, yyyy').format(date)
                          : 'N/A';

                      final formattedTime = _formatTime(incident.timeOfIncident);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.warning_amber_rounded, color: primaryColor),
                          ),
                          title: Text(
                            incident.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${incident.specificOffense}\nDate: $formattedDate at $formattedTime"),
                          trailing: _buildStatusChip(incident.status),

                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IncidentDetailScreen(incident: incident),
                              ),
                            );

                            if (result == true) {
                              // Refresh incident list
                              await Provider.of<IncidentProvider>(context, listen: false).loadIncidents();

                              // Refresh dashboard stats
                              await Provider.of<DashboardStatsProvider>(context, listen: false).fetchAllStats();
                            }
                          },
                        ),
                      );
                    },
                  )),
      ),
    );
  }
}
