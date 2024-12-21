class MenuItem {
  final String id;
  final String name;
  final List<String> categories;

  MenuItem({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categories': categories,
    };
  }
}
