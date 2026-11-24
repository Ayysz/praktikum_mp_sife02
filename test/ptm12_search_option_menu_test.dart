import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm12/models/product_model.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm12/views/search_option_menu_page.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: SearchOptionMenuPage(),
    );
  }

  Future<void> openOptionMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  group('SearchOptionMenuPage Widget & Feature Tests', () {
    testWidgets('Initial render displays AppBar, SearchBar, PopupMenuButton, and 8 products',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Katalog & Search View'), findsOneWidget);
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      expect(find.text('Menampilkan 8 produk'), findsOneWidget);
      expect(ProductModel.initialData.length, 8);
      expect(find.text('Laptop ASUS ZenBook'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Semua'), findsOneWidget);
    });

    group('SearchBar (Search View)', () {
      testWidgets('filters products case-insensitively by keyword',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final searchField = find.descendant(
          of: find.byType(SearchBar),
          matching: find.byType(TextField),
        );

        await tester.enterText(searchField, 'laptop');
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 1 produk'), findsOneWidget);
        expect(find.text('Laptop ASUS ZenBook'), findsOneWidget);
        expect(find.text('Mechanical Keyboard RGB'), findsNothing);

        await tester.enterText(searchField, 'audio');
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 2 produk'), findsOneWidget);
        expect(find.text('Headset Gaming 7.1 Surround'), findsOneWidget);
        expect(find.text('Speaker Bluetooth Portable'), findsOneWidget);
      });

      testWidgets('shows empty state when no match and Reset Pencarian restores list',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final searchField = find.descendant(
          of: find.byType(SearchBar),
          matching: find.byType(TextField),
        );

        await tester.enterText(searchField, 'produk-tidak-ada-xyz');
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 0 produk'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(
          find.text('Tidak ada produk yang cocok dengan "produk-tidak-ada-xyz"'),
          findsOneWidget,
        );
        expect(find.text('Reset Pencarian'), findsOneWidget);

        await tester.tap(find.text('Reset Pencarian'));
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 8 produk'), findsOneWidget);
        expect(find.text('Laptop ASUS ZenBook'), findsOneWidget);
      });

      testWidgets('clear icon clears search query and restores all products',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.clear), findsNothing);

        final searchField = find.descendant(
          of: find.byType(SearchBar),
          matching: find.byType(TextField),
        );

        await tester.enterText(searchField, 'mouse');
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 1 produk'), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 8 produk'), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsNothing);
      });
    });

    group('FilterChip Kategori', () {
      testWidgets('selecting Audio shows only Audio products and Semua restores all',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.widgetWithText(FilterChip, 'Audio'));
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 2 produk'), findsOneWidget);
        expect(find.text('Headset Gaming 7.1 Surround'), findsOneWidget);
        expect(find.text('Speaker Bluetooth Portable'), findsOneWidget);
        expect(find.text('Laptop ASUS ZenBook'), findsNothing);

        await tester.tap(find.widgetWithText(FilterChip, 'Semua'));
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 8 produk'), findsOneWidget);
        expect(find.text('Laptop ASUS ZenBook'), findsOneWidget);
      });
    });

    group('Option Menu (PopupMenuButton)', () {
      testWidgets('displays all 7 option menu items when more_vert is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await openOptionMenu(tester);

        expect(find.text('Tambah Data'), findsOneWidget);
        expect(find.text('Urutkan Nama (A-Z)'), findsOneWidget);
        expect(find.text('Harga Termurah'), findsOneWidget);
        expect(find.text('Harga Tertinggi'), findsOneWidget);
        expect(find.text('Informasi Aplikasi'), findsOneWidget);
        expect(find.text('Reset Data'), findsOneWidget);
        expect(find.text('Keluar'), findsOneWidget);
      });

      testWidgets('Tambah Data validates empty form and adds valid new product',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await openOptionMenu(tester);
        await tester.tap(find.text('Tambah Data'));
        await tester.pumpAndSettle();

        expect(find.text('Tambah Produk Baru'), findsOneWidget);

        // Submit empty form to trigger validation
        await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Nama wajib diisi'), findsOneWidget);
        expect(find.text('Harga wajib diisi'), findsOneWidget);
        expect(find.text('Stok wajib diisi'), findsOneWidget);

        // Fill valid product details
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Produk'),
          'SSD NVMe 1TB',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Harga (Rp)'),
          '1250000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Jumlah Stok'),
          '9',
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Tambah Produk Baru'), findsNothing);
        expect(find.text('Menampilkan 9 produk'), findsOneWidget);
        expect(find.text('SSD NVMe 1TB'), findsOneWidget);
        expect(find.text('Rp 1.250.000'), findsOneWidget);
        expect(
          find.text('Produk "SSD NVMe 1TB" berhasil ditambahkan!'),
          findsOneWidget,
        );
      });

      testWidgets('Sorting changes product order for Harga Termurah, Harga Tertinggi, and Nama (A-Z)',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Sort by Harga Termurah
        await openOptionMenu(tester);
        await tester.tap(find.text('Harga Termurah'));
        await tester.pumpAndSettle();

        final cheapestY = tester.getTopLeft(find.text('USB-C Multiport Hub 7-in-1')).dy;
        final secondCheapestY =
            tester.getTopLeft(find.text('Mouse Wireless Ergonomic')).dy;
        final thirdCheapestY = tester.getTopLeft(find.text('Webcam Full HD 1080p')).dy;

        expect(cheapestY, lessThan(secondCheapestY));
        expect(secondCheapestY, lessThan(thirdCheapestY));
        expect(find.text('Hapus Urutan'), findsOneWidget);

        // Sort by Harga Tertinggi
        await openOptionMenu(tester);
        await tester.tap(find.text('Harga Tertinggi'));
        await tester.pumpAndSettle();

        final priciestY = tester.getTopLeft(find.text('Laptop ASUS ZenBook')).dy;
        final secondPriciestY =
            tester.getTopLeft(find.text('Monitor Gaming 24" 165Hz')).dy;
        final thirdPriciestY =
            tester.getTopLeft(find.text('Mechanical Keyboard RGB')).dy;

        expect(priciestY, lessThan(secondPriciestY));
        expect(secondPriciestY, lessThan(thirdPriciestY));

        // Sort by Urutkan Nama (A-Z)
        await openOptionMenu(tester);
        await tester.tap(find.text('Urutkan Nama (A-Z)'));
        await tester.pumpAndSettle();

        final firstAlphaY =
            tester.getTopLeft(find.text('Headset Gaming 7.1 Surround')).dy;
        final secondAlphaY = tester.getTopLeft(find.text('Laptop ASUS ZenBook')).dy;
        final thirdAlphaY =
            tester.getTopLeft(find.text('Mechanical Keyboard RGB')).dy;

        expect(firstAlphaY, lessThan(secondAlphaY));
        expect(secondAlphaY, lessThan(thirdAlphaY));
      });

      testWidgets('Informasi Aplikasi opens info dialog and closes via Tutup',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await openOptionMenu(tester);
        await tester.tap(find.text('Informasi Aplikasi'));
        await tester.pumpAndSettle();

        expect(find.text('Informasi Aplikasi'), findsOneWidget);
        expect(find.text('Pertemuan 12 - Mobile Programming'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Tutup'));
        await tester.pumpAndSettle();

        expect(find.text('Informasi Aplikasi'), findsNothing);
      });

      testWidgets('Reset Data restores initial 8 products after modification',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Delete first product so count becomes 7
        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 7 produk'), findsOneWidget);
        expect(find.text('Laptop ASUS ZenBook'), findsNothing);

        // Wait for the delete SnackBar (2s) to dismiss so the reset SnackBar can appear immediately
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Reset data via Option Menu
        await openOptionMenu(tester);
        await tester.tap(find.text('Reset Data'));
        await tester.pumpAndSettle();

        expect(find.text('Menampilkan 8 produk'), findsOneWidget);
        expect(find.text('Laptop ASUS ZenBook'), findsOneWidget);
        expect(
          find.text('Data katalog produk telah di-reset ke kondisi awal.'),
          findsOneWidget,
        );
      });

      testWidgets('Keluar closes SearchOptionMenuPage after confirmation dialog',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SearchOptionMenuPage(),
                        ),
                      );
                    },
                    child: const Text('Buka Katalog'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Buka Katalog'));
        await tester.pumpAndSettle();

        expect(find.byType(SearchOptionMenuPage), findsOneWidget);

        await openOptionMenu(tester);
        await tester.tap(find.text('Keluar'));
        await tester.pumpAndSettle();

        expect(find.text('Konfirmasi Keluar'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
        await tester.pumpAndSettle();

        expect(find.byType(SearchOptionMenuPage), findsNothing);
        expect(find.text('Buka Katalog'), findsOneWidget);
      });
    });

    testWidgets('Hapus Produk removes the product from the list',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Laptop ASUS ZenBook'), findsOneWidget);
      expect(find.text('Menampilkan 8 produk'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Laptop ASUS ZenBook'), findsNothing);
      expect(find.text('Menampilkan 7 produk'), findsOneWidget);
      expect(find.text('Produk "Laptop ASUS ZenBook" dihapus.'), findsOneWidget);
    });
  });
}
