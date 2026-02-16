import 'package:carnetizacion/presentation/widgets/add_cargo_sheet.dart';
import 'package:flutter/material.dart';
import '../../config/models/unidad_model.dart';

// --- MODELO TEMPORAL PARA CARGOS (Solo para la UI) ---
class CargoMock {
  final String nombre;
  final int cantidad;
  final IconData icono;
  CargoMock(this.nombre, this.cantidad, this.icono);
}

class UnidadDetailsDialog extends StatefulWidget {
  final Unidad unidad;

  const UnidadDetailsDialog({super.key, required this.unidad});

  @override
  State<UnidadDetailsDialog> createState() => _UnidadDetailsDialogState();
}

class _UnidadDetailsDialogState extends State<UnidadDetailsDialog> {
  // Datos de prueba para la lista de cargos
  final List<CargoMock> _cargos = [
    CargoMock("Senior Fullstack Developer", 12, Icons.code),
    CargoMock("Administrador de Redes", 4, Icons.storage),
    CargoMock("Soporte Técnico Nivel 2", 25, Icons.support_agent),
    CargoMock("Analista de Sistemas QA", 4, Icons.bug_report),
  ];

  @override
  Widget build(BuildContext context) {
    final colorEstado = widget.unidad.colorEstado;
    final textoEstado = widget.unidad.estadoTexto;

    // Usamos Dialog para que aparezca centrado y oscurezca el fondo
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(
        20,
      ), // Margen externo en pantallas pequeñas
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 950,
        ), // Ancho máximo para PC
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HEADER DEL MODAL ---
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.business, color: Colors.amber),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "Detalles: ${widget.unidad.nombre}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 40),

                // --- 2. TARJETAS DE RESUMEN (AZUL Y VERDE) ---
                Row(
                  children: [
                    // Tarjeta Azul (Personal)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          ), // Azul intenso
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "PERSONAL REGISTRADO",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${widget.unidad.cantidadEmpleados}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.groups,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Tarjeta Verde/Naranja (Estado)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(
                            0.1,
                          ), // Fondo suave según estado
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: colorEstado.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ESTADO DEL DEPARTAMENTO",
                                  style: TextStyle(
                                    color: colorEstado,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorEstado,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.unidad.estado == 1
                                            ? Icons.check_circle
                                            : Icons.info,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        textoEstado,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.verified,
                              color: colorEstado.withOpacity(0.5),
                              size: 60,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- 3. SECCIÓN LISTADO DE CARGOS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "LISTADO DE CARGOS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton.icon(
                      // === AQUÍ CONECTAMOS EL BOTTOM SHEET ===
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return const Center(
                              // Center lo mantiene con un ancho máximo estético
                              child: AddCargoSheet(),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        "AGREGAR CARGO",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- TABLA DE CARGOS (Diseño personalizado) ---
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      // Header de la tabla
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "NOMBRE DEL CARGO",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "CANTIDAD DE EMPLEADOS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "ACCIONES",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Lista de filas
                      ListView.separated(
                        shrinkWrap: true, // Importante dentro de un Dialog
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cargos.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final cargo = _cargos[index];
                          return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                // Nombre del Cargo con icono
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          cargo.icono,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        cargo.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Cantidad (Badge gris)
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${cargo.cantidad}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Acciones (Menú de tres puntos)
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
