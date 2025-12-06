import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // REQUIRED FOR PROVIDER
import 'package:misconductmobile/providers/dashboard_stats_provider.dart'; // REQUIRED PROVIDER CLASS
import 'dart:math'; 

// NOTE: Converted to StatelessWidget
class DashboardPageContent extends StatelessWidget {
  const DashboardPageContent({super.key});

  static const primaryColor = Color(0xFF2E7D32);

  // Helper method to calculate the max width required by program labels
  double _calculateMaxTextWidth(List<String> labels, TextStyle style, BuildContext context) {
    double maxWidth = 0;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    for (var label in labels) {
      textPainter.text = TextSpan(text: label, style: style);
      textPainter.layout(minWidth: 0, maxWidth: MediaQuery.of(context).size.width); 
      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }
    // Add a small buffer for safety
    return maxWidth + 4.0; 
  }

  @override
  Widget build(BuildContext context) {
    
    // We only call Provider.of once, but wrap the core content in Builder
    // to ensure the context used to retrieve the provider is correct.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        // Use a Consumer or manually retrieve the provider for the onRefresh callback
        onRefresh: () => Provider.of<DashboardStatsProvider>(context, listen: false).fetchAllStats(), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Welcome to the Application Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Use Builder and Consumer/Provider.of inside to guarantee correct context
            Builder(
              builder: (context) {
                // 1. Consume the provider to get the latest state using the Builder's context
                final provider = Provider.of<DashboardStatsProvider>(context);

                final isLoading = provider.isLoadingStats;
                final errorMessage = provider.errorMessageStats;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Summary Cards ---
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (errorMessage != null)
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded( // Left card (Incidents This Month)
                            child: _buildSummaryCard(
                              context,
                              'Incidents This Month',
                              provider.incidentsThisMonth.toString(), // Data from Provider
                              Icons.report,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 1.0), // Spacing between cards
                          Expanded( // Right card (Overall Incidents)
                            child: _buildSummaryCard(
                              context,
                              'Overall Incidents',
                              provider.incidentsTotal.toString(), // Data from Provider
                              Icons.assessment,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // --- Misconduct Per Program/Course Section (Horizontal Chart) ---
                    const Text(
                      'Misconduct Per Program',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8), 
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey, 
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      // Pass provider to the chart widget
                      child: _buildProgramChartHorizontal(context, provider), 
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Chart widget now accepts the provider
  Widget _buildProgramChartHorizontal(BuildContext context, DashboardStatsProvider provider) {
    final isProgramDataLoading = provider.isProgramDataLoading;
    final programErrorMessage = provider.programErrorMessage;
    final misconductPerProgram = provider.misconductPerProgram;

    if (isProgramDataLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (programErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          programErrorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (misconductPerProgram.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No misconduct incidents recorded per program.'),
        ),
      );
    } else {
      // 1. Sort the map entries by count in descending order
      final sortedPrograms = misconductPerProgram.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // 2. Determine max count for normalization
      final maxCount = sortedPrograms.first.value;
      
      // Constants for styling
      const TextStyle labelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      const double countLabelWidth = 35.0; 
      const double spacing = 8.0; 
      const double barHeight = 25.0;
      
      // Limit to top 6 for clean visual display
      final displayPrograms = sortedPrograms.take(6).toList();
      final displayLabels = displayPrograms.map((e) => e.key).toList();

      // 3. Calculate the fixed width needed for the longest label
      final maxProgramLabelWidth = _calculateMaxTextWidth(displayLabels, labelStyle, context);

      return Column( // Use a Column to stack the horizontal bars vertically
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayPrograms.map((entry) {
          
          final barScaleFactor = maxCount > 0 ? entry.value / maxCount : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row( // Each bar is a Row
              crossAxisAlignment: CrossAxisAlignment.center, // Vertically center all items
              children: [
                // 1. Program Label (Fixed width based on longest label)
                SizedBox(
                  width: maxProgramLabelWidth,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      entry.key,
                      style: labelStyle,
                      maxLines: 1,
                    ),
                  ),
                ),
                
                const SizedBox(width: spacing), // Spacing between label and bar

                // 2. Horizontal Bar (Expanded to take remaining space, then sized proportionally)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxBarAreaWidth = constraints.maxWidth;
                      final barWidth = max(maxBarAreaWidth * barScaleFactor, 2.0).toDouble(); 

                      return Container(
                        alignment: Alignment.centerLeft, 
                        child: Container(
                          width: barWidth, 
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: spacing), // Spacing between bar and count

                // 3. Value Count (Fixed width right side)
                SizedBox(
                  width: countLabelWidth,
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}