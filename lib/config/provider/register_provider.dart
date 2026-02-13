import 'dart:convert';

import 'package:carnetizacion/config/constans/constants/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/selection_models.dart';


class RegisterProvider extends ChangeNotifier {
  // --- ESTADO DE LISTAS ---
  List<UnidadItem> _unidades = [];
  bool _isLoadingList = false;
  
  // --- ESTADO DEL FORMULARIO ---
  UnidadItem? _selectedUnidad;
  CargoItem? _selectedCargo;
  XFile? _imageFile;
  bool _isSubmitting = false;
  String _message = '';

  // Getters
  List<UnidadItem> get unidades => _unidades;
  List<CargoItem> get availableCargos => _selectedUnidad?.cargos ?? []; // Solo cargos de la unidad seleccionada
  UnidadItem? get selectedUnidad => _selectedUnidad;
  CargoItem? get selectedCargo => _selectedCargo;
  XFile? get imageFile => _imageFile;
  bool get isLoadingList => _isLoadingList;
  bool get isSubmitting => _isSubmitting;
  String get message => _message;

  // 1. CARGAR LAS LISTAS (Unidades y Cargos anidados)
  Future<void> fetchFormOptions() async {
    _isLoadingList = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://walisanga.space/credenciales-TED/api/list/secciones-cargos');
      // Recuerda usar el token si la API lo pide, aunque esta parece pública por tu ejemplo
      final response = await http.get(url, );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'];
        _unidades = data.map((e) => UnidadItem.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error cargando listas: $e");
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // 2. LÓGICA DE SELECCIÓN
  void setUnidad(UnidadItem? unidad) {
    _selectedUnidad = unidad;
    _selectedCargo = null; // ⚠️ Importante: Resetear cargo al cambiar unidad
    notifyListeners();
  }

  void setCargo(CargoItem? cargo) {
    _selectedCargo = cargo;
    notifyListeners();
  }

  // 3. SELECCIÓN DE IMAGEN
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 50);
    if (image != null) {
      _imageFile = image;
      notifyListeners();
    }
  }

  // 4. ENVIAR FORMULARIO (POST MULTIPART)
  Future<bool> registerEmployee({
    required String nombre,
    required String apellidos, // Recibimos "Perez Lopez"
    required String ci,
    required String celular,
    required String codigo,
  }) async {
    if (_selectedCargo == null) {
      _message = "Debes seleccionar un Cargo";
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final uri = Uri.parse('https://walisanga.space/credenciales-TED/api/registrarPersonal');
      
      var request = http.MultipartRequest('POST', uri);
      
      // Headers
      request.headers.addAll({
        'Authorization': 'Bearer ${Environment.apiToken}',
        'Accept': 'application/json',
      });

      // --- 1. SEPARAR APELLIDOS (Lógica simple) ---
      // Si escribe "Perez Lopez", paterno="Perez", materno="Lopez"
      // Si solo escribe "Perez", paterno="Perez", materno=""
      List<String> partesApellido = apellidos.trim().split(' ');
      String paterno = partesApellido.isNotEmpty ? partesApellido[0] : '';
      String materno = partesApellido.length > 1 ? partesApellido.sublist(1).join(' ') : '';

      // --- 2. CAMPOS DEL FORMULARIO (Según tu Postman) ---
      request.fields['nombre'] = nombre;
      request.fields['paterno'] = paterno;
      request.fields['materno'] = materno;
      request.fields['id_cargo'] = _selectedCargo!.id.toString();
      request.fields['ci'] = ci;
      request.fields['celular'] = celular;
      request.fields['token'] = codigo; // El código de verificación
      
      // --- 3. CAMPOS POR DEFECTO (Necesarios para que no falle) ---
      request.fields['estado'] = '1';         // 1 = Activo/Registrado
      request.fields['accesoComputo'] = '0';  // 0 = No tiene acceso especial (valor seguro)
      request.fields['complemento'] = '';     // Vacío por defecto
      request.fields['extencion'] = 'CB';     // Poner LP por defecto o agregar un dropdown en la UI
      request.fields['email'] = '';           // Opcional según tu Postman
      request.fields['ciexterno'] = '';       // Opcional

      // --- 4. FOTO (Campo 'photo') ---
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final file = http.MultipartFile.fromBytes(
          'photo', // ⚠️ OJO: En tu Postman dice 'photo', no 'foto'
          bytes,
          filename: 'photo.jpg'
        );
        request.files.add(file);
      }

      // Enviar
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _message = "Personal registrado con éxito";
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        // Intentar leer el mensaje de error del JSON
        try {
           final errorJson = json.decode(response.body);
           _message = errorJson['message'] ?? "Error en el registro";
        } catch(_) {
           _message = "Error ${response.statusCode}. Revise los datos.";
        }
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _message = "Error de conexión: $e";
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}