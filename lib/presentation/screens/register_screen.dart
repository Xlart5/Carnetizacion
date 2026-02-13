import 'dart:io';
import 'package:carnetizacion/config/provider/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/models/selection_models.dart';
import '../../config/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de texto
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController(); // Aquí escribe "Perez Lopez"
  final _ciCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar las opciones (Unidades) al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterProvider>().fetchFormOptions();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _ciCtrl.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón para volver atrás (Opcional, por usabilidad)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            
            _buildHeader(),
            const SizedBox(height: 30),
            
            // Layout Principal: Fila para escritorio/tablet
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COLUMNA IZQUIERDA: FOTO
                SizedBox(
                  width: 300,
                  child: _buildPhotoSection(provider),
                ),
                const SizedBox(width: 30),
                
                // COLUMNA DERECHA: FORMULARIO
                Expanded(
                  child: Column(
                    children: [
                      _buildPersonalDataCard(),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildJobDataCard(provider)),
                          const SizedBox(width: 20),
                          Expanded(flex: 1, child: _buildContactCard()),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildFooterAction(provider),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("SISTEMA INSTITUCIONAL", style: TextStyle(letterSpacing: 2, fontSize: 12, color: AppColors.textGrey)),
        Text("Registro de Empleado", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      ],
    );
  }

  // --- WIDGETS DE SECCIONES ---

  Widget _buildPhotoSection(RegisterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text("Fotografía Oficial", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Fondo blanco, formato JPG o PNG.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          
          // Área de la Foto
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[50],
            ),
            child: provider.imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: kIsWeb 
                      ? Image.network(provider.imageFile!.path, fit: BoxFit.cover) 
                      : Image.file(File(provider.imageFile!.path), fit: BoxFit.cover),
                  )
                : const Center(child: Icon(Icons.account_circle, size: 80, color: Colors.grey)),
          ),
          
          const SizedBox(height: 20),
          
          // Botones
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text("Subir Foto"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textDark,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => provider.pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Cámara"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => provider.pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.person_outline, "Datos Personales"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _customTextField("NOMBRE(S)", "Ej. Juan Carlos", _nameCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _customTextField("APELLIDOS", "Ej. Pérez García", _surnameCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _customTextField("CÉDULA DE IDENTIDAD", "1234567-1", _ciCtrl)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildJobDataCard(RegisterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.work_outline, "Cargo y Función"),
          const SizedBox(height: 20),
          
          // DROPDOWN 1: UNIDAD
          const Text("UNIDAD DESTINADA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UnidadItem>(
                isExpanded: true,
                hint: const Text("Seleccione su unidad"),
                value: provider.selectedUnidad,
                items: provider.unidades.map((UnidadItem unit) {
                  return DropdownMenuItem<UnidadItem>(
                    value: unit,
                    child: Text(unit.nombre, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => provider.setUnidad(val),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // DROPDOWN 2: CARGO (Depende de la Unidad)
          const Text("CARGO ESPECÍFICO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          const SizedBox(height: 8), // Pequeño espacio extra
          
          if (provider.selectedUnidad == null)
            const Text("Primero seleccione una unidad arriba", style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 15),
               decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
               child: DropdownButtonHideUnderline(
                 child: DropdownButton<CargoItem>(
                   isExpanded: true,
                   hint: const Text("Seleccione el cargo"),
                   value: provider.selectedCargo,
                   items: provider.availableCargos.map((CargoItem cargo) {
                     return DropdownMenuItem<CargoItem>(
                       value: cargo,
                       child: Text(cargo.nombre, overflow: TextOverflow.ellipsis),
                     );
                   }).toList(),
                   onChanged: (val) => provider.setCargo(val),
                 ),
               ),
            ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: false, 
                onChanged: (v){},
                activeColor: AppColors.primaryYellow,
              ),
              const Text("Juez Electoral", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              const Text("Posee nombramiento vigente", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      height: 280, // Altura forzada para alinear con el card de al lado
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.phone_outlined, "Contacto"),
          const SizedBox(height: 20),
          _customTextField("NÚMERO CELULAR", "700-00000", _phoneCtrl),
          const SizedBox(height: 20),
          const Text("* Usado únicamente para fines de contacto institucional.", style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic))
        ],
      ),
    );
  }

  Widget _buildFooterAction(RegisterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          // Icono Escudo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.security, size: 30, color: AppColors.textDark),
          ),
          const SizedBox(width: 20),
          
          const Expanded(child: Text("Ingrese el código de 6 dígitos enviado a su correo.", style: TextStyle(color: Colors.grey))),
          
          // INPUT DEL CÓDIGO (Token)
          SizedBox(
            width: 180,
            child: TextField(
              controller: _codeCtrl,
              textAlign: TextAlign.center,
              style: const TextStyle(letterSpacing: 8, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                hintText: "0 0 0 0 0 0",
                hintStyle: const TextStyle(letterSpacing: 4),
                filled: true,
                fillColor: Colors.grey[500], // Gris oscuro como en tu diseño
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // BOTÓN DE REGISTRO
          ElevatedButton(
            onPressed: provider.isSubmitting ? null : () async {
              // 1. Ejecutar registro
              final success = await provider.registerEmployee(
                nombre: _nameCtrl.text,
                apellidos: _surnameCtrl.text,
                ci: _ciCtrl.text,
                celular: _phoneCtrl.text,
                codigo: _codeCtrl.text
              );
              
              // 2. Manejar resultado
              if (mounted) {
                if (success) {
                  // NAVEGAR A PANTALLA DE ÉXITO
                  context.go('/success'); 
                } else {
                  // MOSTRAR ERROR
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.message), 
                      backgroundColor: AppColors.errorRed
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: provider.isSubmitting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
              : const Text("REGISTRAR AHORA", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- HELPERS PARA UI ---
  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryYellow, size: 20),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      ],
    );
  }

  Widget _customTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}