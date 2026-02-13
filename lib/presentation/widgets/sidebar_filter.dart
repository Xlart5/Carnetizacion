import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class SidebarFilter extends StatelessWidget {
  const SidebarFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 20, top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          const Text("UNIDAD DESTINADA", style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildFilterItem("Recursos Humanos", "45"),
          _buildFilterItem("Administración", "128"),
          _buildFilterItem("Tecnologías (TI)", "24"),
          _buildFilterItem("Asesoría Jurídica", "12"),
          const SizedBox(height: 30),
          const Text("ESTADO", style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildBadge("Impreso", AppColors.successGreen.withOpacity(0.2), AppColors.successGreen),
              const SizedBox(width: 8),
              _buildBadge("Pendiente", AppColors.primaryYellow.withOpacity(0.3), Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        Icon(Icons.filter_list, color: AppColors.primaryYellow),
        SizedBox(width: 10),
        Text("Filtros Rápidos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildFilterItem(String label, String count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(count, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textC) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textC, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}