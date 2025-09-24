import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/book_controller.dart';

class AnalyticsManagementPage extends StatelessWidget {
  const AnalyticsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BookController bookController = Get.find<BookController>();

    // Fetch analytics when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bookController.fetchAnalytics();
    });

    return Obx(() {
      if (bookController.isLoadingAnalytics.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 79, 156, 89)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading analytics...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 94, 184, 100),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      final analytics = bookController.analyticsData;
      if (analytics.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 79, 156, 89).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Color.fromARGB(255, 94, 184, 100),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No analytics data available',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 94, 184, 100),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: bookController.fetchAnalytics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 79, 156, 89),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Prepare data for the chart
      final totalBooks = (analytics['totalBooks'] ?? 0).toDouble();
      final trendingBooks = (analytics['trendingBooks'] ?? 0).toDouble();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 60, 120, 68),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 79, 156, 89).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalBooks,
                          color: Color.fromARGB(255, 79, 156, 89),
                          width: 30,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: trendingBooks,
                          color: Color.fromARGB(255, 94, 184, 100),
                          width: 30,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Total Books', 'Trending Books'];
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Roboto',
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Display raw numbers
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
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color.fromARGB(255, 60, 120, 68),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Books: ${analytics['totalBooks'] ?? 0}',
                      style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                    ),
                    Text(
                      'Trending Books: ${analytics['trendingBooks'] ?? 0}',
                      style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}