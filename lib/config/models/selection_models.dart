class CargoItem {
  final int id;
  final String nombre;

  CargoItem({required this.id, required this.nombre});

  factory CargoItem.fromJson(Map<String, dynamic> json) {
    return CargoItem(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
  
  // Para que el Dropdown compare objetos correctamente
  @override
  bool operator ==(Object other) => other is CargoItem && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class UnidadItem {
  final int id;
  final String nombre;
  final List<CargoItem> cargos;

  UnidadItem({required this.id, required this.nombre, required this.cargos});

  factory UnidadItem.fromJson(Map<String, dynamic> json) {
    var list = json['cargos'] as List? ?? [];
    List<CargoItem> cargosList = list.map((i) => CargoItem.fromJson(i)).toList();

    return UnidadItem(
      id: json['id'],
      nombre: json['nombre'],
      cargos: cargosList,
    );
  }

  @override
  bool operator ==(Object other) => other is UnidadItem && other.id == id;
  @override
  int get hashCode => id.hashCode;
}