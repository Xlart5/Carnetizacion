import 'package:carnetizacion/presentation/widgets/edit_employee_sheet.dart';
import 'package:carnetizacion/presentation/widgets/view_employee_sheet.dart';
import 'package:flutter/material.dart';
// Importante para la navegación si usas editar
import '../../config/models/employee_model.dart';

import '../../config/theme/app_colors.dart';

class EmployeeDataSource extends DataTableSource {
  final List<Employee> employees;
  final BuildContext context;

  EmployeeDataSource(this.employees, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= employees.length) return null;
    final emp = employees[index];

    // Lógica de colores (1 = Impreso/Verde, Otros = Pendiente/Naranja)
    final bool esImpreso = emp.estado == 1;
    final Color colorEstado = esImpreso
        ? AppColors.successGreen
        : Colors.orange;
    final Color bgEstado = esImpreso
        ? AppColors.successGreen.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);

    return DataRow.byIndex(
      index: index,
      color: MaterialStateProperty.resolveWith<Color?>((
        Set<MaterialState> states,
      ) {
        return index.isEven ? Colors.white : Colors.grey[50];
      }),
      onSelectChanged: (bool? selected) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Center(
              child: ViewEmployeeSheet(employee: emp),
              // Llama al nuevo Bottom Sheet
            );
          },
        );
      },

      cells: [
        // 1. FOTO
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              backgroundImage: emp.photoUrl.isNotEmpty
                  ? NetworkImage(emp.photoUrl)
                  : null,
              child: emp.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
          ),
        ),

        // 2. NOMBRE
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emp.nombreCompleto,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // 3. CARGO
        DataCell(Text(emp.cargo, style: const TextStyle(fontSize: 12))),

        // 4. CÉDULA
        DataCell(
          Text(
            emp.ci,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),

        // 5. UNIDAD
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              emp.unidad,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // 6. ESTADO (Con colores restaurados)
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgEstado,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: colorEstado),
                const SizedBox(width: 6),
                Text(
                  emp.estadoTexto,
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 7. ACCIONES (4 Botones: Ver, Imprimir, Editar, Borrar)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize
                .min, // Importante para que no ocupen espacio infinito
            children: [
              // Ver
              _ActionButton(
                icon: Icons.visibility_outlined,
                color: Colors.grey,
                onTap: () {
                  /* Lógica ver */
                },
              ),

              const SizedBox(width: 5),

              // Imprimir (RESTAURADO)
              _ActionButton(
                icon: Icons.print_outlined,
                color: AppColors.primaryDark,
                onTap: () {
                  /* Lógica imprimir */
                },
              ),

              const SizedBox(width: 5),

              // Editar
              _ActionButton(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Permite que el panel tome su tamaño natural
                    backgroundColor: Colors
                        .transparent, // Necesario para que se vean los bordes redondeados
                    builder: (context) {
                      return Center(
                        // Centramos horizontalmente para monitores grandes
                        child: EditEmployeeSheet(
                          employee: emp,
                        ), // 'emp' es la variable de tu empleado en esa fila
                      );
                    },
                  );
                  // Ejemplo: context.push('/registro', extra: emp);
                },
              ),

              const SizedBox(width: 5),

              // Borrar
              _ActionButton(
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: () => _confirmDelete(emp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para que los botones se vean uniformes
  Widget _ActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _confirmDelete(Employee emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Eliminación"),
        content: Text("¿Estás seguro de eliminar a ${emp.nombreCompleto}?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Eliminar"),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => employees.length;
  @override
  int get selectedRowCount => 0;
}
