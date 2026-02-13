import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';
// import '../constants/environment.dart'; // Si lo usas

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _allEmployees = []; 
  List<Employee> _filteredEmployees = []; 
  bool _isLoading = false;

  List<Employee> get employees => _filteredEmployees;
  bool get isLoading => _isLoading;

  // KPIs
  int get totalEmployees => _allEmployees.length;
  int get printedCredentials => _allEmployees.where((e) => e.estado == 1).length;
  int get pendingRequests => _allEmployees.where((e) => e.estado != 1).length;

  List<Employee> get pendingPrintingEmployees => _allEmployees.where((e) => e.estado != 1).toList();

  // CARGAR (Respetando tu lógica original)
  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = Uri.parse('https://walisanga.space/credenciales-TED/api/list/personal');
      // Sin headers para evitar error 405 en web, o agrega los que te funcionaban
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> dataList = decoded['personal'] ?? [];
        
        _allEmployees = dataList.map((e) => Employee.fromJson(e)).toList();
        _filteredEmployees = List.from(_allEmployees);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARCAR COMO IMPRESO (La función nueva)
  Future<void> markAsPrinted(Employee employee) async {
    final index = _allEmployees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      // 1. Actualizar Localmente
      Employee updatedEmployee = _allEmployees[index].copyWith(estado: 1);
      _allEmployees[index] = updatedEmployee;
      
      final filterIndex = _filteredEmployees.indexWhere((e) => e.id == employee.id);
      if (filterIndex != -1) _filteredEmployees[filterIndex] = updatedEmployee;
      
      notifyListeners(); 

      // 2. Enviar a la API
      try {
        final url = Uri.parse('https://walisanga.space/credenciales-TED/api/registrarPersonal');
        await http.post(
          url,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(updatedEmployee.toJson()),
        );
      } catch (e) {
        print("Error al guardar: $e");
      }
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredEmployees = List.from(_allEmployees);
    } else {
      final lower = query.toLowerCase();
      // Usamos nombreCompleto que es tu getter
      _filteredEmployees = _allEmployees.where((e) => e.nombreCompleto.toLowerCase().contains(lower) || e.ci.contains(query)).toList();
    }
    notifyListeners();
  }
}