import 'package:carnetizacion/presentation/widgets/unidad_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/models/unidad_model.dart';

class UnidadesScreen extends StatefulWidget {
  const UnidadesScreen({super.key});

  @override
  State<UnidadesScreen> createState() => _UnidadesScreenState();
}

class _UnidadesScreenState extends State<UnidadesScreen> {
  // Datos de prueba (Aquí luego conectarás tu Provider)
  final List<Unidad> _unidades = [
    Unidad(id: 1, nombre: "Asesoria Legal", cantidadEmpleados: 24, estado: 1),
    Unidad(
      id: 2,
      nombre: "Servicio Intercultural de Fortalecimiento Democratico",
      cantidadEmpleados: 18,
      estado: 1,
    ),
    Unidad(id: 3, nombre: "Tecnologias", cantidadEmpleados: 12, estado: 1),
    Unidad(
      id: 4,
      nombre: "Unidad de Geografia y Logistica Electoral",
      cantidadEmpleados: 36,
      estado: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris muy claro
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Gestión de Unidades/Secciones",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Administre las áreas y departamentos institucionales",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para registrar nueva sección (Abrir modal o pantalla)
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Registrar Nueva Sección"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- 2. BARRA DE BÚSQUEDA Y FILTROS ---47
            Divider(height: 2),
            const SizedBox(height: 50),
            // --- 3. GRID DE TARJETAS ---
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350, // Ancho máximo de la tarjeta
                  mainAxisExtent: 200, // Alto fijo de la tarjeta
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                // Sumamos 1 al total porque el index 0 será nuestra tarjeta estática de "Agregar"
                itemCount: _unidades.length + 1,
                itemBuilder: (context, index) {
                  // MAGIA AQUÍ: El primer elemento siempre es el botón de agregar
                  if (index == 0) {
                    return const AddUnidadCard();
                  }

                  // A partir del index 1, mostramos los datos (restando 1 para cuadrar la lista)
                  final unidad = _unidades[index - 1];
                  return UnidadCard(unidad: unidad);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: TARJETA DE UNIDAD NORMAL
// ==========================================
class UnidadCard extends StatelessWidget {
  final Unidad unidad;

  const UnidadCard({super.key, required this.unidad});

  // Función para abrir el modal
  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Fondo oscurecido
      builder: (context) => UnidadDetailsDialog(unidad: unidad),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos InkWell para que toda la tarjeta responda al clic
    return Material(
      elevation: 6.0, // <--- AQUÍ CONTROLAS LA ELEVACIÓN (Prueba con 4, 6 u 8)
      shadowColor: Colors.black45, // Intensidad de la sombra
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: () => _showDetails(context), // Clic en toda la tarjeta
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Icono y Badge de Estado - IGUAL QUE ANTES) ...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder_shared,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: unidad.colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unidad.estadoTexto,
                      style: TextStyle(
                        color: unidad.colorEstado,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // ... (Nombre y Empleados - IGUAL QUE ANTES) ...
              Text(
                unidad.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 5),
                  Text(
                    "${unidad.cantidadEmpleados} Empleados asignados",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Spacer(),

              // Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {}, // Abrir Modal Editar (Pendiente)
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        unidad.estado == 0 ? "Activar" : "Editar",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      // *** AQUÍ CONECTAMOS EL BOTÓN TAMBIÉN ***
                      onPressed: () => _showDetails(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Ver Detalles",
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: TARJETA "AGREGAR NUEVA" (INDEX 0)
// ==========================================
class AddUnidadCard extends StatelessWidget {
  const AddUnidadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Lógica para registrar nueva sección (Abrir bottom sheet o dialog)
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // Fondo azulado muy tenue
          borderRadius: BorderRadius.circular(12),
          // Nota: Flutter no tiene borde punteado nativo en BoxDecoration.
          // Simulamos un diseño limpio y diferente usando un borde sólido de color azul claro,
          // que da un efecto visual muy similar y elegante.
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(height: 15),
            const Text(
              "Registrar Nueva Sección",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
