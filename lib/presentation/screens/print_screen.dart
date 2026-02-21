import 'package:carnetizacion/config/provider/employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart'; 
import 'package:pdf/pdf.dart';

import '../../config/theme/app_colors.dart';
import '../../config/helpers/pdf_generator_service.dart';
import '../../config/models/employee_model.dart'; 
import '../widgets/credential_card.dart';

// 1. CAMBIAMOS A STATEFUL WIDGET
class PrintScreen extends StatefulWidget {
  const PrintScreen({super.key});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  
  // 2. VARIABLE CERRADURA: Bloqueará el botón mientras trabaje
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
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
                    const Text(
                      "Impresión de Credenciales",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      "Revisión final de ${pendingList.length} credenciales pendientes.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),

                // 3. BOTÓN IMPRIMIR PROTEGIDO
                ElevatedButton.icon(
                  // Desactivamos el botón si no hay datos o si ya está imprimiendo
                  onPressed: (pendingList.isEmpty || _isPrinting)
                      ? null
                      : () async {
                          // A. Encendemos el bloqueo
                          setState(() {
                            _isPrinting = true; 
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Preparando imágenes en segundo plano... Por favor espere."),
                              backgroundColor: Colors.blue,
                              duration: Duration(seconds: 3),
                            ),
                          );

                          try {
                            // B. El PDF se genera en el Sótano sin congelar la pantalla
                            final pdfBytes = await PdfGeneratorService.generateCredentialsPdf(pendingList);

                            // C. Abre la vista de Chrome
                            await Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async => pdfBytes,
                              name: 'Credenciales_Lote_${DateTime.now().millisecond}',
                            );

                            // D. Actualiza la Base de Datos
                            final listToUpdate = List<Employee>.from(pendingList);
                            final readProvider = context.read<EmployeeProvider>();

                            for (final emp in listToUpdate) {
                              await readProvider.markAsPrinted(emp);
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("¡Listo! Registros marcados como IMPRESOS."),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al generar: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            // E. Pase lo que pase (Error o Éxito), quitamos el bloqueo
                            if (context.mounted) {
                              setState(() {
                                _isPrinting = false;
                              });
                            }
                          }
                        },
                  // 4. CAMBIAMOS EL ÍCONO POR UNA RUEDITA SI ESTÁ TRABAJANDO
                  icon: _isPrinting 
                      ? const SizedBox(
                          width: 18, 
                          height: 18, 
                          child: CircularProgressIndicator(color: AppColors.textDark, strokeWidth: 2)
                        )
                      : const Icon(Icons.print, size: 18),
                  label: Text(_isPrinting ? "Procesando..." : "Imprimir Lote"),
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
                ? const Center(
                    child: Text("No hay credenciales pendientes de impresión."),
                  )
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
                            Expanded(child: CredentialCard(employee: emp)),
                            const SizedBox(height: 10),
                            Text(
                              emp.nombreCompleto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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