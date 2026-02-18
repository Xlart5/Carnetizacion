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
  void markAsPrinted(Employee emp) {
    final index = _allEmployees.indexWhere((e) => e.id == emp.id);
    if (index != -1) {
      // Recreamos al empleado con su nuevo estado
      _allEmployees[index] = Employee(
        id: emp.id,
        nombre: emp.nombre,
        apellidoPaterno: emp.apellidoPaterno,
        apellidoMaterno: emp.apellidoMaterno,
        carnetIdentidad: emp.carnetIdentidad,
        correo: emp.correo,
        celular: emp.celular,
        accesoComputo: emp.accesoComputo,
        estadoActual: "CREDENCIAL IMPRESO", // <--- Lo pasamos a impreso
        cargo: emp.cargo,
        unidad: emp.unidad,
        photoUrl: emp.photoUrl, qrUrl: emp.qrUrl,
      );

      // ⚠️ NOTA: Aquí a futuro deberías hacer un http.post o put a tu API
      // para avisarle a la base de datos que este ID ya se imprimió.

      _applyFilters();
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
}
