import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardStatsProvider extends ChangeNotifier {
  int incidentsThisMonth = 0;
  int incidentsTotal = 0;
  bool isLoadingStats = true;
  String? errorMessageStats;

  Map<String, int> misconductPerProgram = {};
  bool isProgramDataLoading = true;
  String? programErrorMessage;

  DashboardStatsProvider() {
    fetchAllStats();
  }

  Future<void> fetchAllStats() async {
    errorMessageStats = null;
    programErrorMessage = null;
    isLoadingStats = true;
    isProgramDataLoading = true;
    notifyListeners();

    try {
      final stats = await ApiService.fetchIncidentStats();
      final now = DateTime.now();
      final currentKey =
          "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}";

      int monthTotal = 0;
      int overallTotal = 0;

      for (final item in stats) {
        final map = item as Map<String, dynamic>;
        final count = (map['count'] ?? 0) as int;
        final key = map['month_year_sort']?.toString() ?? '';

        overallTotal += count;
        if (key == currentKey) monthTotal += count;
      }

      incidentsThisMonth = monthTotal;
      incidentsTotal = overallTotal;
      isLoadingStats = false;
    } catch (e) {
      errorMessageStats = "Error loading general stats: ${e.toString()}";
      isLoadingStats = false;
    }

    try {
      final data = await ApiService.fetchMisconductPerProgram();
      misconductPerProgram = data;
      isProgramDataLoading = false;
    } catch (e) {
      programErrorMessage = "Error loading program data: ${e.toString()}";
      isProgramDataLoading = false;
    }

    notifyListeners();
  }
}
