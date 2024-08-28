import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projetogeolocalizacao/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _allSpots = [
    {
      "name": "Parque Ecológico Boa Vista",
      "latitude": -21.587209121642083,
      "longitude": -48.81032398275566,
      "description": "Principal parque da cidade de Itápolis."
    },
    {
      "name": "Japa's Lanches Itápolis",
      "latitude": -21.58355562843144,
      "longitude": -48.80685909276324,
      "description": "O melhor lanche da cidade."
    },
  ];
  List<Map<String, dynamic>> _nearbySpots = [];
  LatLng? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _filterNearbySpots();
      });
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }

  void _filterNearbySpots() {
    const double radiusInKm = 2.0;
    _nearbySpots = _allSpots.where((spot) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        spot["latitude"],
        spot["longitude"],
      );
      return distance <= radiusInKm * 1000; // Convert km to meters
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pontos Turísticos Próximos'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: _currentPosition,
                zoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Marker para a localização atual do usuário
                    if (_currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 80,
                        height: 80,
                        builder: (ctx) => Icon(
                          Icons.my_location,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    // Marcadores para os pontos turísticos próximos
                    ..._nearbySpots.map((spot) {
                      return Marker(
                        point: LatLng(spot["latitude"], spot["longitude"]),
                        width: 80,
                        height: 80,
                        builder: (ctx) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSpot =
                                  LatLng(spot["latitude"], spot["longitude"]);
                            });
                            _showSpotDetails(spot);
                          },
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                if (_selectedSpot != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_currentPosition!, _selectedSpot!],
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
      bottomNavigationBar: _selectedSpot == null
          ? SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para exibir mais detalhes ou calcular rota
                },
                child: Text('Ver rota para o local selecionado'),
              ),
            ),
    );
  }

  void _showSpotDetails(Map<String, dynamic> spot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(spot["name"]),
          content: Text(spot["description"]),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
