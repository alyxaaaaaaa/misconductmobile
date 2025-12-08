import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:misconductmobile/providers/dashboard_stats_provider.dart';
import 'package:misconductmobile/providers/user_provider.dart'; 
import 'dart:math';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color primaryColor = Color(0xFF84BE78); 
  static const Color lightGreenBackground = Color(0xFFE8F5E9);
  static const Color mediumGreen = Color(0xFF66BB6A);
  static const Color cardShadowGreen = Color(0xFF81C784);

  double _calculateMaxTextWidth(
      List<String> labels, TextStyle style, BuildContext context) {
    double maxWidth = 0;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    for (var label in labels) {
      textPainter.text = TextSpan(text: label, style: style);
      textPainter.layout(
        minWidth: 0,
        maxWidth: MediaQuery.of(context).size.width,
      );
      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }
    return maxWidth + 4.0;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.name ?? 'User'; 

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/SMRMS LOGO.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: lightGreenBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () =>
              Provider.of<DashboardStatsProvider>(context, listen: false)
                  .fetchAllStats(),
          color: primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome, $userName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review the latest incident statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Consumer<DashboardStatsProvider>(
                builder: (context, provider, child) {
                  final isLoading = provider.isLoadingStats;
                  final errorMessage = provider.errorMessageStats;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      else if (errorMessage != null)
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                'Incidents This Month',
                                provider.incidentsThisMonth.toString(),
                                Icons.report,
                                mediumGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                'Overall Incidents',
                                provider.incidentsTotal.toString(),
                                Icons.assessment,
                                mediumGreen,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Misconduct Per Program',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const Divider(
                        color: mediumGreen,
                        thickness: 2,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: cardShadowGreen.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _buildProgramChartHorizontal(provider, context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramChartHorizontal(
      DashboardStatsProvider provider, BuildContext context) {
    final isProgramDataLoading = provider.isProgramDataLoading;
    final programErrorMessage = provider.programErrorMessage;
    final misconductPerProgram = provider.misconductPerProgram;

    if (isProgramDataLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    } else if (programErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          programErrorMessage,
          style: const TextStyle(color: Colors.redAccent),
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
      final sortedPrograms = misconductPerProgram.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final maxCount = sortedPrograms.first.value;

      const TextStyle labelStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      );
      const double countLabelWidth = 35.0;
      const double spacing = 10.0;
      const double barHeight = 28.0;

      final displayPrograms = sortedPrograms.take(6).toList();
      final displayLabels = displayPrograms.map((e) => e.key).toList();
      final maxProgramLabelWidth =
          _calculateMaxTextWidth(displayLabels, labelStyle, context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayPrograms.map((entry) {
          final barScaleFactor = maxCount > 0 ? entry.value / maxCount : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const SizedBox(width: spacing),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxBarAreaWidth = constraints.maxWidth;
                      final barWidth =
                          max(maxBarAreaWidth * barScaleFactor, 4.0);

                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: barWidth,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.9),
                                mediumGreen,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: countLabelWidth,
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
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
      BuildContext context, String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: cardShadowGreen.withOpacity(0.4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}