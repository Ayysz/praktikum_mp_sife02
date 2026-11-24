class ProductModel {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final int stok;

  const ProductModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
  });

  ProductModel copyWith({
    String? id,
    String? nama,
    String? kategori,
    int? harga,
    int? stok,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
    );
  }

  static List<ProductModel> get initialData => const [
    ProductModel(
      id: '1',
      nama: 'Laptop ASUS ZenBook',
      kategori: 'Elektronik',
      harga: 15500000,
      stok: 5,
    ),
    ProductModel(
      id: '2',
      nama: 'Mechanical Keyboard RGB',
      kategori: 'Aksesoris',
      harga: 850000,
      stok: 12,
    ),
    ProductModel(
      id: '3',
      nama: 'Mouse Wireless Ergonomic',
      kategori: 'Aksesoris',
      harga: 320000,
      stok: 20,
    ),
    ProductModel(
      id: '4',
      nama: 'Monitor Gaming 24" 165Hz',
      kategori: 'Elektronik',
      harga: 2150000,
      stok: 8,
    ),
    ProductModel(
      id: '5',
      nama: 'Headset Gaming 7.1 Surround',
      kategori: 'Audio',
      harga: 650000,
      stok: 15,
    ),
    ProductModel(
      id: '6',
      nama: 'Webcam Full HD 1080p',
      kategori: 'Aksesoris',
      harga: 450000,
      stok: 10,
    ),
    ProductModel(
      id: '7',
      nama: 'Speaker Bluetooth Portable',
      kategori: 'Audio',
      harga: 490000,
      stok: 7,
    ),
    ProductModel(
      id: '8',
      nama: 'USB-C Multiport Hub 7-in-1',
      kategori: 'Aksesoris',
      harga: 280000,
      stok: 25,
    ),
  ];
}
