class MenuItem {
  final String id;
  final String name;
  
  final List<String> categories; // Tambahkan properti ini

  MenuItem({
    required this.id,
    required this.name,
    
    required this.categories, // Tambahkan parameter ini di constructor
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [], // Pastikan ini menangkap daftar kategori dari JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      
      'categories': categories, // Pastikan ini disertakan saat di-encode ke JSON
    };
  }
}
