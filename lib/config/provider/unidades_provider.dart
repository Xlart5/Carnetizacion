import 'dart:convert';
import 'package:carnetizacion/config/constans/constants/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/unidad_model.dart';

class UnidadesProvider extends ChangeNotifier {
  final String _baseUrl = Environment.apiUrl;

  List<UnidadModel> _unidades = [];
  List<CargoUnidadModel> _todosLosCargos = [];
  bool _isLoading = false;

  List<UnidadModel> get unidades => _unidades;
  bool get isLoading => _isLoading;

  // Filtra mágicamente los cargos para mostrar solo los de la unidad seleccionada
  List<CargoUnidadModel> getCargosPorUnidad(int unidadId) {
    return _todosLosCargos.where((c) => c.unidadId == unidadId).toList();
  }

  // Carga TODO al entrar a la pantalla
  Future<void> fetchDatosUnidades() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Traer Unidades
      final resUnidades = await http.get(Uri.parse('$_baseUrl/api/unidades'));
      if (resUnidades.statusCode == 200) {
        final List<dynamic> unData = json.decode(
          utf8.decode(resUnidades.bodyBytes),
        );
        _unidades = unData.map((e) => UnidadModel.fromJson(e)).toList();
      }

      // 2. Traer Cargos
      final resCargos = await http.get(
        Uri.parse('$_baseUrl/api/cargos-proceso'),
      );
      if (resCargos.statusCode == 200) {
        final List<dynamic> carData = json.decode(
          utf8.decode(resCargos.bodyBytes),
        );
        _todosLosCargos = carData
            .map((e) => CargoUnidadModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error cargando gestión de unidades: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
