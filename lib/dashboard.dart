import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const DashboardPage({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://smart-farming-55522-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  late TabController _tabController;

  double _temperature = 25.0;
  double _humidity = 32.2;
  double _soilMoisture = 3;
  bool _isPumpActive = false;
  bool _isAutoMode = true;
  double _moistureThreshold = 30.0;

  List<FlSpot> _temperatureData = [];
  List<FlSpot> _humidityData = [];
  List<FlSpot> _soilMoistureData = [];
  int _maxDataPoints = 10;

  List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupDataStreams();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _tabController.dispose();
    super.dispose();
  }

  void _setupDataStreams() {
    _subscriptions.add(_database.child('sensors/temperature').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _temperature = double.parse(event.snapshot.value.toString());
          _updateChartData(_temperatureData, _temperature);
        });
      }
    }));

    _subscriptions.add(_database.child('sensors/humidity').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _humidity = double.parse(event.snapshot.value.toString());
          _updateChartData(_humidityData, _humidity);
        });
      }
    }));

    _subscriptions.add(_database.child('sensors/soilMoisture').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _soilMoisture = double.parse(event.snapshot.value.toString());
          _updateChartData(_soilMoistureData, _soilMoisture);

          if (_isAutoMode) {
            if (_soilMoisture < _moistureThreshold && !_isPumpActive) {
              _togglePump(true);
            } else if (_soilMoisture >= _moistureThreshold && _isPumpActive) {
              _togglePump(false);
            }
          }
        });
      }
    }));

    _subscriptions.add(_database.child('controls/pump').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _isPumpActive = event.snapshot.value.toString() == 'true';
        });
      }
    }));

    _subscriptions.add(_database.child('controls/autoMode').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _isAutoMode = event.snapshot.value.toString() == 'true';
        });
      }
    }));

    _subscriptions.add(_database.child('settings/soilMoistureThreshold').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _moistureThreshold = double.parse(event.snapshot.value.toString());
        });
      }
    }));

    _initializeDummyData();
  }

  void _initializeDummyData() {
    _database.child('sensors').once().then((DatabaseEvent event) {
      if (event.snapshot.value == null) {
        _database.child('sensors').set({
          'temperature': 25.0,
          'humidity': 60.0,
          'soilMoisture': 40.0,
        });

        _database.child('controls').set({
          'pump': false,
          'autoMode': true,
        });

        _database.child('settings').set({
          'soilMoistureThreshold': 30.0,
        });
      }
    });
  }

  void _updateChartData(List<FlSpot> dataList, double value) {
    if (dataList.length >= _maxDataPoints) {
      dataList.removeAt(0);
    }

    double nextX = dataList.isEmpty ? 0 : dataList.last.x + 1;
    dataList.add(FlSpot(nextX, value));
  }

  Future<void> _togglePump(bool value) async {
    try {
      await _database.child('controls/pump').set(value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling pump: $e')),
      );
    }
  }

  Future<void> _toggleAutoMode(bool value) async {
    try {
      await _database.child('controls/autoMode').set(value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling auto mode: $e')),
      );
    }
  }

  Future<void> _updateMoistureThreshold(double value) async {
    try {
      await _database.child('settings/soilMoistureThreshold').set(value);
      setState(() {
        _moistureThreshold = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating threshold: $e')),
      );
    }
  }

  Widget _buildSensorCard(String title, double value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$value $unit',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createChartData(List<FlSpot> spots, Color color) {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Dashboard'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => widget.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Developer Profile',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.pushNamed(context, '/help'),
            tooltip: 'Help & Support',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/signin');
            },
            tooltip: 'Sign Out',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Controls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.displayName ?? 'Farmer'}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Current farm conditions at a glance',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildSensorCard('Temperature', _temperature, '°C', Icons.thermostat, Colors.orange),
                    _buildSensorCard('Humidity', _humidity, '%', Icons.water_drop, Colors.blue),
                    _buildSensorCard('Soil Moisture', _soilMoisture, '%', Icons.grass, Colors.green),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water,
                              size: 32,
                              color: _isPumpActive ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Irrigation Pump',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Switch(
                              value: _isPumpActive,
                              onChanged: _isAutoMode ? null : (value) => _togglePump(value),
                              activeColor: Colors.blue,
                            ),
                            Text(
                              _isPumpActive ? 'ON' : 'OFF',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isPumpActive ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'System Status',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Irrigation Mode:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              _isAutoMode ? 'Automatic' : 'Manual',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Soil Moisture Threshold:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '${_moistureThreshold.toInt()}%',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Charts Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Environmental Data',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temperature (°C)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: _temperatureData.length < 2
                              ? const Center(child: Text('Collecting data...'))
                              : LineChart(_createChartData(_temperatureData, Colors.orange)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Humidity (%)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: _humidityData.length < 2
                              ? const Center(child: Text('Collecting data...'))
                              : LineChart(_createChartData(_humidityData, Colors.blue)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soil Moisture (%)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: _soilMoistureData.length < 2
                              ? const Center(child: Text('Collecting data...'))
                              : LineChart(_createChartData(_soilMoistureData, Colors.green)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Controls Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Irrigation Controls',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Irrigation Mode',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Automatic',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Switch(
                              value: _isAutoMode,
                              onChanged: (value) => _toggleAutoMode(value),
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isAutoMode
                              ? 'System will automatically control irrigation based on soil moisture.'
                              : 'Manually control when to irrigate your crops.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Irrigation Pump',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isPumpActive ? 'ON' : 'OFF',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isPumpActive ? Colors.blue : Colors.grey,
                              ),
                            ),
                            Switch(
                              value: _isPumpActive,
                              onChanged: _isAutoMode ? null : (value) => _togglePump(value),
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        if (_isAutoMode)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Manual control is disabled in automatic mode',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soil Moisture Threshold',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Irrigation will start when soil moisture falls below this level',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _moistureThreshold,
                                min: 10.0,
                                max: 60.0,
                                divisions: 50,
                                label: '${_moistureThreshold.toInt()}%',
                                onChanged: (value) => _updateMoistureThreshold(value),
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${_moistureThreshold.toInt()}%',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
