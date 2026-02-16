import 'package:flutter/material.dart';

class Unidad {
  final int id;
  final String nombre;
  final int cantidadEmpleados;
  final int estado; // 1: Activo, 2: En Revisión, 0: Inactivo

  Unidad({
    required this.id,
    required this.nombre,
    required this.cantidadEmpleados,
    required this.estado,
  });

  // Helper para obtener el texto del estado
  String get estadoTexto {
    switch (estado) {
      case 1: return "ACTIVO";
      case 2: return "EN REVISIÓN";
      default: return "INACTIVO";
    }
  }

  // Helper para obtener el color del badge según el estado
  Color get colorEstado {
    switch (estado) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      default: return Colors.grey;
    }
  }
}