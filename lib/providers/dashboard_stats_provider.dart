// lib/providers/dashboard_stats_provider.dart

import 'package:flutter/material.dart';
import 'package:misconductmobile/services/api_service.dart';
import 'dart:math'; 

class DashboardStatsProvider extends ChangeNotifier {
  // --- Summary Card State ---
  int incidentsThisMonth = 0;
  int incidentsTotal = 0;
  bool isLoadingStats = true;
  String? errorMessageStats;

  // --- Program Chart State ---
  Map<String, int> misconductPerProgram = {};
  bool isProgramDataLoading = true;
  String? programErrorMessage;

  // --- Initialization ---
  DashboardStatsProvider() {
    // Automatically fetch data when the provider is created
    fetchAllStats();
  }

  // --- Core Logic: Combines the two fetch methods ---
  Future<void> fetchAllStats() async {
    // Reset errors
    errorMessageStats = null;
    programErrorMessage = null;
    
    // Set loading flags and notify listeners immediately
    isLoadingStats = true;
    isProgramDataLoading = true;
    notifyListeners();

    // 1. Fetch Summary Stats (Incidents This Month/Total)
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
        if (key == currentKey) {
          monthTotal += count;
        }
      }

      incidentsThisMonth = monthTotal;
      incidentsTotal = overallTotal;
      isLoadingStats = false;
      
    } catch (e) {
      errorMessageStats = "Error loading general stats: ${e.toString()}";
      isLoadingStats = false;
    }

    // 2. Fetch Misconduct Per Program
    try {
      final data = await ApiService.fetchMisconductPerProgram();
      misconductPerProgram = data;
      isProgramDataLoading = false;
    } catch (e) {
      programErrorMessage = "Error loading program data: ${e.toString()}";
      isProgramDataLoading = false;
    }

    // Notify listeners once all data is processed
    notifyListeners();
  }
}