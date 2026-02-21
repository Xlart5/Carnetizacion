import 'dart:convert';
import 'package:carnetizacion/config/constans/constants/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  // URL BASE (Actualiza tu ngrok si reinicias el servidor)
  final String _baseUrl = Environment.apiUrl;

  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = false;

  // --- VARIABLES PARA FILTROS RÁPIDOS ---
  String _searchQuery = '';
  String? _selectedUnidadFilter;
  String? _selectedEstadoFilter;

  // Sets para guardar los valores únicos disponibles que llegan de la BD
  final Set<String> _unidadesDisponibles = {};
  final Set<String> _estadosDisponibles = {};

  // =====================================
  // GETTERS GENERALES
  // =====================================
  List<Employee> get employees => _filteredEmployees;
  bool get isLoading => _isLoading;
  Set<String> get unidadesDisponibles => _unidadesDisponibles;
  Set<String> get estadosDisponibles => _estadosDisponibles;
  String? get selectedUnidadFilter => _selectedUnidadFilter;
  String? get selectedEstadoFilter => _selectedEstadoFilter;

  // =====================================
  // GETTERS DE KPIs (Para las tarjetas)
  // =====================================
  int get totalEmployees => _allEmployees.length;
  // Consideramos "Activos" a los que pintamos de verde
  int get totalActivos =>
      _allEmployees.where((e) => e.colorEstado == Colors.green).length;
  // Consideramos "Pendientes" a los nuevos registros
  int get totalPendientes => _allEmployees
      .where((e) => e.estadoActual.toUpperCase() == "PERSONAL REGISTRADO")
      .length;
  // Total general de empleados (por si tu tarjeta lo usa)

  // Total de credenciales ya impresas
  int get printedCredentials => _allEmployees
      .where((e) => e.estadoActual.toUpperCase() == "CREDENCIAL IMPRESO")
      .length;

  // Total de solicitudes pendientes (Personal recién registrado)
  int get pendingRequests => _allEmployees
      .where((e) => e.estadoActual.toUpperCase() == "PERSONAL REGISTRADO")
      .length;
  // =====================================
  // GETTERS PARA IMPRESIÓN (print_screen)
  // =====================================
  List<Employee> get pendingPrintingEmployees => _allEmployees
      .where((e) => e.estadoActual.toUpperCase() == "PERSONAL REGISTRADO")
      .toList();

  // =====================================
  // CARGAR EMPLEADOS (POST /api/personal)
  // =====================================
  // =====================================
  // CARGAR EMPLEADOS (CORREGIDO: GET a /detalles)
  // =====================================
  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Usamos el endpoint correcto de tu imagen
      final url = Uri.parse('$_baseUrl/api/personal/detalles');

      // CAMBIO CLAVE: Usamos GET y le decimos a ngrok que no nos bloquee (Evita el 403)
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(
          utf8.decode(response.bodyBytes),
        );
        _allEmployees = decoded.map((e) => Employee.fromJson(e)).toList();

        _unidadesDisponibles.clear();
        _estadosDisponibles.clear();
        for (var emp in _allEmployees) {
          _unidadesDisponibles.add(emp.unidad); // <-- Volvemos a la normalidad
          _estadosDisponibles.add(emp.estadoActual);
        }

        _applyFilters();
      } else {
        print('Error Fetch: ${response.statusCode}');
      }
    } catch (e) {
      print('Error Conexión Fetch: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================================
  // LÓGICA DE FILTRADO CENTRALIZADA
  // =====================================
  void _applyFilters() {
    _filteredEmployees = _allEmployees.where((emp) {
      // 1. Filtro de Búsqueda (Nombre o CI)
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        matchesSearch =
            emp.nombreCompleto.toLowerCase().contains(lowerQuery) ||
            emp.carnetIdentidad.contains(_searchQuery);
      }

      // 2. Filtro de Unidad
      bool matchesUnidad = true;
      if (_selectedUnidadFilter != null) {
        matchesUnidad = emp.unidad == _selectedUnidadFilter;
      }

      // 3. Filtro de Estado
      bool matchesEstado = true;
      if (_selectedEstadoFilter != null) {
        matchesEstado = emp.estadoActual == _selectedEstadoFilter;
      }

      // El empleado debe cumplir TODAS las condiciones activas para mostrarse
      return matchesSearch && matchesUnidad && matchesEstado;
    }).toList();

    notifyListeners();
  }

  // =====================================
  // ACCIONES DE LA INTERFAZ
  // =====================================

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void toggleUnidadFilter(String unidad) {
    if (_selectedUnidadFilter == unidad) {
      _selectedUnidadFilter = null; // Apaga el filtro si lo vuelven a presionar
    } else {
      _selectedUnidadFilter = unidad;
    }
    _applyFilters();
  }

  void toggleEstadoFilter(String estado) {
    if (_selectedEstadoFilter == estado) {
      _selectedEstadoFilter = null;
    } else {
      _selectedEstadoFilter = estado;
    }
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedUnidadFilter = null;
    _selectedEstadoFilter = null;
    _applyFilters();
  }

  // =====================================
  // ACCIÓN DE IMPRIMIR CREDENCIALES
  // =====================================
  // =====================================
  // ACCIÓN DE IMPRIMIR CREDENCIALES (REAL A BD)
  // =====================================
  Future<bool> markAsPrinted(Employee emp) async {
    try {
      // 1. Armamos la URL con el ID del empleado
      final url = Uri.parse(
        '$_baseUrl/api/estados-personal/${emp.id}/imprimir-credencial',
      );

      // 2. Hacemos la petición PUT al servidor
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning':
              'true', // Descomenta esto si vuelve a molestar el CORS
        },
      );

      // 3. Si el servidor responde OK (200), actualizamos la pantalla
      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _allEmployees.indexWhere((e) => e.id == emp.id);
        if (index != -1) {
          // Usamos copyWith para mantener todos sus datos y solo cambiar su estado visualmente
          _allEmployees[index] = emp.copyWith(
            estadoActual: "CREDENCIAL IMPRESO",
          );
          _applyFilters();
        }
        return true; // Éxito
      } else {
        print('Error en BD al imprimir: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false; // Falló
      }
    } catch (e) {
      print('Error de conexión al imprimir: $e');
      return false; // Falló
    }
  }

  // =====================================
  // ACTUALIZAR EMPLEADO EDITADO
  // =====================================
  void updateEmployeeLocal(Employee updatedEmployee) {
    // Buscamos al empleado en la lista y lo reemplazamos por el nuevo
    final index = _allEmployees.indexWhere((e) => e.id == updatedEmployee.id);
    if (index != -1) {
      _allEmployees[index] = updatedEmployee;
      _applyFilters(); // Refresca la tabla al instante
    }
  }

  // =====================================
  // ELIMINAR EMPLEADO (DELETE)
  // =====================================
  Future<bool> deleteEmployee(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/api/personal/$id');

      final response = await http.delete(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Lo borramos de la lista principal
        _allEmployees.removeWhere((emp) => emp.id == id);

        // Refrescamos los filtros y la tabla
        _applyFilters();
        return true;
      } else {
        print('Error al eliminar: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error de conexión al eliminar: $e');
      return false;
    }
  }
}
