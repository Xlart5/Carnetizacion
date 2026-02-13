import 'package:flutter/material.dart';

class Employee {
  final int id;
  final String nombre;
  final String paterno;
  final String materno;
  final String cargo;
  final String ci;
  final String unidad; // "seccion_nombre"
  final int estado;    // Viene como 0 o 1
  final String photoUrl;

  Employee({
    required this.id,
    required this.nombre,
    required this.paterno,
    required this.materno,
    required this.cargo,
    required this.ci,
    required this.unidad,
    required this.estado,
    required this.photoUrl,
  });

  // Getter para mostrar el nombre completo en la UI
  String get nombreCompleto => "$nombre $paterno $materno";

  // Getter para traducir el estado numérico a texto
  String get estadoTexto => estado == 1 ? "Impreso" : "Pendiente";
  
  // Getter opcional para color (útil para la tabla)
  Color get colorEstado => estado == 1 ? Colors.green : Colors.orange;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      paterno: json['paterno'] ?? '',
      materno: json['materno'] ?? '',
      cargo: json['cargo_nombre'] ?? 'Sin Cargo',
      ci: json['ci'] ?? '',
      unidad: json['seccion_nombre'] ?? 'General',
      estado: json['estado'] ?? 0,
      photoUrl: json['photo'] ?? '',
    );
  }

  // --- LO NUEVO: COPYWITH (Para editar estado sin perder datos) ---
  Employee copyWith({
    int? id,
    String? nombre,
    String? paterno,
    String? materno,
    String? cargo,
    String? ci,
    String? unidad,
    int? estado,
    String? photoUrl,
  }) {
    return Employee(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      paterno: paterno ?? this.paterno,
      materno: materno ?? this.materno,
      cargo: cargo ?? this.cargo,
      ci: ci ?? this.ci,
      unidad: unidad ?? this.unidad,
      estado: estado ?? this.estado,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // --- LO NUEVO: TOJSON (Para enviar a la API de registrarPersonal) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'paterno': paterno,
      'materno': materno,
      'cargo_nombre': cargo,    // Mapeamos de vuelta a como lo espera la API
      'ci': ci,
      'seccion_nombre': unidad, // Mapeamos de vuelta
      'estado': estado,
      'photo': photoUrl,
    };
  }
}