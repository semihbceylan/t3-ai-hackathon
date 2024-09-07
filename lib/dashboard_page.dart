import 'package:fineitune/customDrawer.dart';
import 'package:fineitune/homepage.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the charting library

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize( preferredSize: Size.fromHeight(80.0),
      child : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    ),
      drawer: customDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Total Sales', '1.000.000 \$', Icons.show_chart),
                _buildStatCard('Total Profit', '128.000 \$', Icons.money),
                _buildStatCard('Orders', '12346', Icons.shopping_cart),
                _buildStatCard('Customers', '3231', Icons.people),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Expanded(child: _buildPieChart()), Expanded(child: _buildDoughnutChart()), Expanded(child: _buildBarChart())],),
                    SizedBox(height: 16),
                    _buildPyramidChart(),
                    SizedBox(height: 16),
                    _buildStackedLineChart(),                  
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 40),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pie Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 40,
                      title: '40%',
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 30,
                      title: '30%',
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 20,
                      title: '20%',
                    ),
                    PieChartSectionData(
                      color: Colors.yellow,
                      value: 10,
                      title: '10%',
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

  Widget _buildPyramidChart() {
    // Placeholder widget for Pyramid Chart
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pyramid Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              width : 200,
              child: Center(child: Text('Pyramid Chart Placeholder')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoughnutChart() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doughnut Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 25,
                      title: '25%',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 25,
                      title: '25%',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 25,
                      title: '25%',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: Colors.yellow,
                      value: 25,
                      title: '25%',
                      radius: 60,
                    ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedLineChart() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stacked Line Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 14,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(2, 1.5),
                        FlSpot(4, 1.4),
                        FlSpot(6, 3.4),
                        FlSpot(8, 2),
                        FlSpot(10, 2.2),
                        FlSpot(12, 1.8),
                        FlSpot(14, 3),
                      ],
                      isCurved: true,
                      color:Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: 
                        Colors.blue.withOpacity(0.3)
                      ),
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

  Widget _buildBarChart() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bar Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 8, color: Colors.red, width: 15),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 10, color: Colors.green, width: 15),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 14, color: Colors.blue, width: 15),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 15, color: Colors.yellow, width: 15),
                    ]),
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
