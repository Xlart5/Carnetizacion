import 'package:carnetizacion/config/provider/employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart'; // Asegúrate de tener este import
import 'package:pdf/pdf.dart';


import '../../config/theme/app_colors.dart';
import '../../config/helpers/pdf_generator_service.dart';
import '../../config/models/employee_model.dart'; // Importante para el tipo Employee
import '../widgets/credential_card.dart';

class PrintScreen extends StatelessWidget {
  const PrintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    // Obtenemos solo los pendientes
    final pendingList = provider.pendingPrintingEmployees;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // HEADER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Impresión de Credenciales", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    Text("Revisión final de ${pendingList.length} credenciales pendientes.", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                
                // BOTÓN IMPRIMIR
                ElevatedButton.icon(
                  onPressed: pendingList.isEmpty ? null : () async {
                    // 1. Notificar al usuario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Generando PDF..."))
                    );

                    try {
                      // 2. Generar el PDF
                      final pdfBytes = await PdfGeneratorService.generateCredentialsPdf(pendingList);
                      
                      // 3. Abrir la vista previa de impresión
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) async => pdfBytes,
                        name: 'Credenciales_Lote_${DateTime.now().millisecond}',
                      );

                      // 4. ACTUALIZAR ESTADO EN BD
                      // Hacemos una copia de la lista porque al actualizar se borrarán de 'pendingList'
                      final listToUpdate = List<Employee>.from(pendingList);
                      final readProvider = context.read<EmployeeProvider>();

                      for (final emp in listToUpdate) {
                        // Llamamos a la API para cada empleado impreso
                        readProvider.markAsPrinted(emp);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("¡Listo! Registros marcados como IMPRESOS."),
                            backgroundColor: Colors.green,
                          )
                        );
                      }
                      
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
                      );
                    }
                  },
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text("Imprimir Lote"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  ),
                ),
              ],
            ),
          ),

          // GRID DE CREDENCIALES
          Expanded(
            child: pendingList.isEmpty 
            ? const Center(child: Text("No hay credenciales pendientes de impresión."))
            : Padding(
              padding: const EdgeInsets.all(40.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400, 
                  mainAxisExtent: 250,    
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                ),
                itemCount: pendingList.length,
                itemBuilder: (context, index) {
                  final emp = pendingList[index];
                  return Column(
                    children: [
                      Expanded(
                        child: CredentialCard(employee: emp, )
                      ),
                      const SizedBox(height: 10),
                      Text(emp.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}