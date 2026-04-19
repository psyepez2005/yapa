import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yapa/core/network/api_client.dart';
import 'dart:async';

/// Mapa de Yapas interactivo (simulación para Hackathon).
/// Utiliza OpenStreetMap (sin API key) y permite simular una caminata hacia una Yapa.
class MapaYapasScreen extends StatefulWidget {
  const MapaYapasScreen({super.key});

  @override
  State<MapaYapasScreen> createState() => _MapaYapasScreenState();
}

class _MapaYapasScreenState extends State<MapaYapasScreen> with TickerProviderStateMixin {
  final MapController _mapCtrl = MapController();
  
  // Lista de Yapas traídas del backend
  List<Map<String, dynamic>> _broadcasts = [];
  bool _isLoading = true;

  // Ubicación del usuario (Centro Norte Quito / La Carolina)
  LatLng _userPosition = const LatLng(-0.17300, -78.48200);
  bool _isSimulating = false;
  Timer? _simulationTimer;
  Map<String, dynamic>? _nearbyYapaDetected;

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    try {
      final dio = await ApiClient.userAuthorized();
      final response = await dio.get('/loyalty/broadcasts');
      final List data = response.data['data'] as List;

      if (mounted) {
        setState(() {
          _broadcasts = data.cast<Map<String, dynamic>>();
          if (_broadcasts.isEmpty) {
            _populateMockYapas();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _populateMockYapas();
          _isLoading = false;
        });
      }
    }
  }

  void _populateMockYapas() {
    _broadcasts = [
      {
        'merchantName': 'Ceviches de la Ruleta',
        'couponValue': 0.50,
        'latitude': -0.170768,
        'longitude': -78.480446,
      },
      {
        'merchantName': 'Canguilero del Parque',
        'couponValue': 0.25,
        'latitude': -0.179993,
        'longitude': -78.483820,
      },
      {
        'merchantName': 'Sánduches El Rapidito',
        'couponValue': 1.00,
        'latitude': -0.175561,
        'longitude': -78.481239,
      },
      {
        'merchantName': 'Helados del Vecino',
        'couponValue': 0.75,
        'latitude': -0.172100,
        'longitude': -78.484500,
      },
    ];
  }

  LatLng _getLocationForYapa(Map<String, dynamic> yapa, int index) {
    // Si el backend viene con coordenadas reales (y no son cero)
    if (yapa.containsKey('latitude') && yapa.containsKey('longitude')) {
      final lat = double.tryParse(yapa['latitude'].toString()) ?? 0.0;
      final lng = double.tryParse(yapa['longitude'].toString()) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        return LatLng(lat, lng);
      }
    }
    // Fallback pseudoaleatorio en un radio corto por si aca
    const double offset = 0.005;
    return LatLng(
      _userPosition.latitude + (index % 2 == 0 ? offset : -offset) * (index * 0.5),
      _userPosition.longitude + (index % 3 == 0 ? offset : -offset) * (index * 0.5),
    );
  }

  // Activa la caminata simulada
  void _startSimulation() {
    if (_broadcasts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay Yapas activas para simular.')));
      return;
    }
    
    setState(() => _isSimulating = true);

    // Elegimos la primera yapa como destino
    final targetYapa = _broadcasts.first;
    final targetPos = _getLocationForYapa(targetYapa, 0);

    const int steps = 40;
    int currentStep = 0;

    final double latDiff = (targetPos.latitude - _userPosition.latitude) / steps;
    final double lngDiff = (targetPos.longitude - _userPosition.longitude) / steps;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _userPosition = LatLng(_userPosition.latitude + latDiff, _userPosition.longitude + lngDiff);
        _mapCtrl.move(_userPosition, 16.5);
      });

      // Calcular distancia (usamos Distance de latlong2)
      const Distance distance = Distance();
      final double distanceInMeters = distance.as(LengthUnit.Meter, _userPosition, targetPos);

      // Si llego a un radio de 50 metros, lanzamos notificación
      if (distanceInMeters <= 50 && _nearbyYapaDetected == null) {
        _nearbyYapaDetected = targetYapa;
        timer.cancel();
        setState(() => _isSimulating = false);
        _showYapaPopup(targetYapa);
      }

      currentStep++;
      if (currentStep >= steps) {
        timer.cancel();
        setState(() => _isSimulating = false);
      }
    });
  }

  void _showYapaPopup(Map<String, dynamic> yapa) {
    final name = yapa['merchantName'] ?? 'Comercio';
    final cp = yapa['couponValue']?.toString() ?? 'Especial';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Color(0xFF0A9E8F), size: 64),
              const SizedBox(height: 16),
              const Text('¡Yapa Cerca!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A1587))),
              const SizedBox(height: 12),
              Text(
                'Estás pasando frente a $name y tienes una Yapa de \$$cp disponible ahora mismo.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A1587),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('¡Ir a Canjear!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _nearbyYapaDetected = null; // reset
                },
                child: const Text('Ignorar', style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar de Yapas', style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (!_isLoading && _broadcasts.isNotEmpty)
            TextButton.icon(
              onPressed: _isSimulating ? null : _startSimulation,
              icon: Icon(Icons.directions_walk, color: _isSimulating ? Colors.grey : const Color(0xFF4A1587)),
              label: Text(_isSimulating ? 'Caminando...' : 'Simular', style: TextStyle(color: _isSimulating ? Colors.grey : const Color(0xFF4A1587), fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A1587)))
          : FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: _userPosition,
                initialZoom: 15.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.deuna.yapa',
                ),
                MarkerLayer(
                  markers: [
                    // Usuario
                    Marker(
                      point: _userPosition,
                      width: 60,
                      height: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                            ),
                          ),
                          const Text('Tú', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.white70)),
                        ],
                      ),
                    ),
                    // Yapas
                    ..._broadcasts.asMap().entries.map((e) {
                      final i = e.key;
                      final yapa = e.value;
                      final pos = _getLocationForYapa(yapa, i);
                      return Marker(
                        point: pos,
                        width: 80,
                        height: 65,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A9E8F),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1.5),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: const Text(
                                'Yapa',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.location_on, color: Color(0xFF4A1587), size: 30),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
      // Botón flotante extra por si quieren simular
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Centrar mapa
          _mapCtrl.move(_userPosition, 15.5);
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.blue),
      ),
    );
  }
}
