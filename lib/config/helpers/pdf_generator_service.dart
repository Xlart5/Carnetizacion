import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class PdfGeneratorService {
  // MEDIDAS ORIGINALES QUE FUNCIONARON PARA TI
  static const double cardWidth = 270.0;
  static const double cardHeight = 171.0;

  static Future<Uint8List> generateCredentialsPdf(
    List<Employee> employees,
  ) async {
    final pdf = pw.Document();

    // 1. CARGAR ASSETS
    final templateFront = await _loadAsset(
      'assets/images/card_template_front.png',
    );
    final templateBack = await _loadAsset(
      'assets/images/ATRAS_EVENTUAL_2025.png',
    );
    final logoTed = await _loadAsset('assets/images/logo_ted.png');
    final logoElecciones = await _loadAsset(
      'assets/images/logo_elecciones.png',
    );
    final qrPlaceholder = await _loadAsset('assets/images/qr_placeholder.png');

    // A4 Vertical
    final pageFormat = PdfPageFormat.a4;

    // --- 10 POR PÁGINA (2 Col x 5 Filas) ---
    const int itemsPerPage = 10;

    for (var i = 0; i < employees.length; i += itemsPerPage) {
      // Obtenemos el grupo de datos real
      final chunk = employees.sublist(
        i,
        (i + itemsPerPage) < employees.length
            ? i + itemsPerPage
            : employees.length,
      );
      final List<pw.ImageProvider> qrs = await Future.wait(
        chunk.map((emp) async {
          if (emp.qrUrl.isEmpty) return logoTed;
          try {
            final response = await http.get(Uri.parse(emp.qrUrl));
            if (response.statusCode == 200) {
              return pw.MemoryImage(response.bodyBytes);
            }
          } catch (e) {}
          return logoTed;
        }),
      );
      // Descargar fotos reales
      final List<pw.ImageProvider> photos = await Future.wait(
        chunk.map((emp) async {
          if (emp.photoUrl.isEmpty) return logoTed;
          try {
            final response = await http.get(Uri.parse(emp.photoUrl));
            if (response.statusCode == 200) {
              return pw.MemoryImage(response.bodyBytes);
            }
          } catch (e) {}
          return logoTed;
        }),
      );

      // --- PÁGINA 1: FRENTE ---
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          // Reduje márgenes verticales para asegurar que entren las 5 filas (10 carnets)
          margin: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          build: (pw.Context context) {
            return pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: cardWidth / cardHeight,
              crossAxisSpacing: 10,
              mainAxisSpacing:
                  5, // Espacio vertical mínimo para que entren 5 filas
              // TRUCO: Generamos SIEMPRE 10 items. Si no hay datos, ponemos caja invisible.
              children: List.generate(itemsPerPage, (index) {
                if (index < chunk.length) {
                  // Tarjeta Real
                  return _buildFrontCard(
                    chunk[index],
                    photos[index],
                    templateFront,
                    logoTed,
                    logoElecciones,
                    qrs[index],
                  );
                } else {
                  // Tarjeta Invisible (Mantiene el tamaño de la grilla fijo)
                  return pw.SizedBox(width: cardWidth, height: cardHeight);
                }
              }),
            );
          },
        ),
      );

      // --- PÁGINA 2: ATRÁS (Espejo) ---
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          build: (pw.Context context) {
            // Lógica Espejo
            final List<int?> mirrorIndexes = List.filled(itemsPerPage, null);
            for (int j = 0; j < chunk.length; j++) {
              final int row = j ~/ 2;
              final int col = j % 2;
              final int mirrorCol = (col == 0) ? 1 : 0;

              final int newIndex = (row * 2) + mirrorCol;
              if (newIndex < itemsPerPage) mirrorIndexes[newIndex] = j;
            }

            return pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: cardWidth / cardHeight,
              crossAxisSpacing: 10,
              mainAxisSpacing: 5,
              // TRUCO: También generamos siempre 10 items
              children: List.generate(itemsPerPage, (index) {
                if (mirrorIndexes[index] != null) {
                  // Reverso Real
                  return _buildBackCard(templateBack);
                } else {
                  // Reverso Invisible (Mantiene alineación)
                  return pw.SizedBox(width: cardWidth, height: cardHeight);
                }
              }),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<pw.MemoryImage> _loadAsset(String path) async {
    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      return pw.MemoryImage(
        Uint8List.fromList([
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          0x00,
          0x00,
          0x00,
          0x0D,
          0x49,
          0x48,
          0x44,
          0x52,
          0x00,
          0x00,
          0x00,
          0x01,
          0x00,
          0x00,
          0x00,
          0x01,
          0x08,
          0x06,
          0x00,
          0x00,
          0x00,
          0x1F,
          0x15,
          0xC4,
          0x89,
          0x00,
          0x00,
          0x00,
          0x0A,
          0x49,
          0x44,
          0x41,
          0x54,
          0x78,
          0x9C,
          0x63,
          0x00,
          0x01,
          0x00,
          0x00,
          0x05,
          0x00,
          0x01,
          0x0D,
          0x0A,
          0x2D,
          0xB4,
          0x00,
          0x00,
          0x00,
          0x00,
          0x49,
          0x45,
          0x4E,
          0x44,
          0xAE,
          0x42,
          0x60,
          0x82,
        ]),
      );
    }
  }

  // --- DISEÑO FRONTAL ---
  static pw.Widget _buildFrontCard(
    Employee emp,
    pw.ImageProvider photo,
    pw.ImageProvider bg,
    pw.ImageProvider logoTed,
    pw.ImageProvider logoElec,
    pw.ImageProvider qrs,
  ) {
    // 👇 LA MAGIA CONDICIONAL EMPIEZA AQUÍ 👇
    final String cargoMinusculas = emp.cargo.toString().toLowerCase();
    final bool esNotario = cargoMinusculas.contains('notari');
    // 👆 LA MAGIA CONDICIONAL TERMINA AQUÍ 👆

    return pw.Container(
      width: cardWidth,
      height: cardHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        color: PdfColors.white,
      ),
      child: pw.Stack(
        children: [
          // 1. Fondo
          pw.Positioned.fill(child: pw.Image(bg, fit: pw.BoxFit.fill)),

          // 2. Header

          // 3. QR o CIRCUNSCRIPCIÓN (Reemplazado con la condición)
          pw.Positioned(
            top: 30,
            left: 30,
            child: esNotario
                // SI ES NOTARIO: Mostramos la cajita de Circunscripción
                ? pw.Container(
                    width: 70,
                    height: 70,

                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.SizedBox(height: 5),
                        pw.Text(
                          // Aquí llamamos a tu variable de circunscripción
                          emp.Circu.toString(),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 30,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                // SI NO ES NOTARIO: Mostramos el QR normal
                : pw.Container(
                    width: 70,
                    height: 70,
                    color: PdfColors.white,
                    child: pw.Image(qrs, fit: pw.BoxFit.cover),
                  ),
          ),

          // 4. Logo TED
          pw.Positioned(
            top: 110,
            left: 78,
            child: pw.Container(
              width: 20,
              height: 20,
              child: pw.Image(logoTed),
            ),
          ),

          // 5. FOTO
          pw.Positioned(
            top: 35,
            right: 40,
            child: pw.Container(
              width: 60,
              height: 70,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(5),
                border: pw.Border.all(color: PdfColors.white, width: 1.5),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 5,
                verticalRadius: 5,
                child: pw.Image(photo, fit: pw.BoxFit.cover),
              ),
            ),
          ),

          // 6. DATOS
          pw.Positioned(
            bottom: 30,
            right: 15,
            child: pw.Container(
              width: 110,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "Ci: ${emp.ci}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 5,
                    ),
                  ),
                  pw.SizedBox(height: 0.5),
                  pw.Text(
                    emp.nombreCompleto,
                    textAlign: pw.TextAlign.center,
                    maxLines: 2,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 5,
                    ),
                  ),
                  pw.SizedBox(height: 0.5),
                  pw.Text(
                    emp.cargo.toString(),
                    textAlign: pw.TextAlign.center,
                    maxLines: 2,
                    style: pw.TextStyle(fontSize: 4.5),
                  ),
                ],
              ),
            ),
          ),

          // 7. Logo Elecciones
          pw.Positioned(
            bottom: 28,
            left: 10,
            child: pw.Container(width: 45, child: pw.Image(logoElec)),
          ),

          // 8. Barra Negra
          pw.Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: pw.Container(
              height: 20,
              color: PdfColor.fromInt(0xFF222222),
              alignment: pw.Alignment.center,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "Personal Eventual",
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 6.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Elecciones Subnacionales 2026",
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 5.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DISEÑO TRASERO ---
  static pw.Widget _buildBackCard(pw.ImageProvider bg) {
    return pw.Container(
      width: cardWidth,
      height: cardHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      child: pw.Image(bg, fit: pw.BoxFit.fill),
    );
  }
}
