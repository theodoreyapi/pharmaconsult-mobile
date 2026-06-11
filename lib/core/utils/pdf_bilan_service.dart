import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pharmaconsult/models/suivisante/bilan_model.dart';
import 'package:pharmaconsult/models/suivisante/mesure_model.dart' as mesure;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:pharmaconsult/models/suivisante/traitement_model.dart' as tr;

class PdfBilanService {
  static Future<void> generateAndShareBilan({
    required BilanModel bilan,
    mesure.Patient? patient,
    List<mesure.Pathologies>? pathologies,
    tr.TraitementModel? traitements,
  }) async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    
    // Set page settings
    document.pageSettings.margins.all = 30;

    // Add a page
    PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // --- HEADER ---
    _drawHeader(page, pageSize);

    double yPos = 100;

    // --- PATIENT INFO ---
    yPos = _drawPatientInfo(page, yPos, bilan, patient, pathologies);

    // --- RESUME GLOBAL ---
    yPos = _drawResumeGlobal(page, yPos, bilan);

    // --- METRICS ---
    if (bilan.pressionArterielle != null) {
      yPos = _drawPressionArterielle(page, yPos, bilan.pressionArterielle!);
    }

    if (bilan.frequenceCardiaque != null) {
      if (yPos > pageSize.height - 150) {
        page = document.pages.add();
        yPos = 30;
      }
      yPos = _drawFrequenceCardiaque(page, yPos, bilan.frequenceCardiaque!);
    }

    if (bilan.glycemie != null) {
      if (yPos > pageSize.height - 150) {
        page = document.pages.add();
        yPos = 30;
      }
      yPos = _drawGlycemie(page, yPos, bilan.glycemie!);
    }

    if (bilan.poids != null) {
      if (yPos > pageSize.height - 150) {
        page = document.pages.add();
        yPos = 30;
      }
      yPos = _drawPoids(page, yPos, bilan.poids!);
    }

    if (bilan.imc != null) {
      if (yPos > pageSize.height - 150) {
        page = document.pages.add();
        yPos = 30;
      }
      yPos = _drawImc(page, yPos, bilan.imc!);
    }

    // --- TRAITEMENTS ---
    if (traitements != null && traitements.traitements != null && traitements.traitements!.isNotEmpty) {
      if (yPos > pageSize.height - 200) {
        page = document.pages.add();
        yPos = 30;
      }
      yPos = _drawTraitements(page, yPos, traitements);
    }

    // --- FOOTER ---
    _drawFooter(document);

    // Save the document
    final List<int> bytes = await document.save();
    document.dispose();

    // Get external storage directory
    final Directory directory = await getTemporaryDirectory();
    final String path = '${directory.path}/bilan_sante_${bilan.periode?.startDate ?? 'export'}.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes);

    // Share the file
    await Share.shareXFiles([XFile(path)], text: 'Mon bilan de santé PharmaConsult');
  }

  static void _drawHeader(PdfPage page, Size pageSize) {
    // Green Header Box
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(39, 174, 96)), // #27AE60
      bounds: Rect.fromLTWH(0, 0, pageSize.width, 80),
    );

    // Header Text
    page.graphics.drawString(
      'Mon Suivi Santé',
      PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(20, 15, pageSize.width - 40, 30),
    );

    page.graphics.drawString(
      'Résumé de bilan de santé',
      PdfStandardFont(PdfFontFamily.helvetica, 14),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(20, 45, pageSize.width - 40, 20),
    );

    page.graphics.drawString(
      'PharmaConsult — Votre partenaire santé',
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(20, 60, pageSize.width - 40, 15),
    );

    // Generation Date (Top Right)
    final String genDate = DateFormat('dd MMMM yyyy', 'fr_FR').format(DateTime.now());
    page.graphics.drawString(
      'Généré le $genDate',
      PdfStandardFont(PdfFontFamily.helvetica, 9),
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(pageSize.width - 150, 20, 130, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  static double _drawPatientInfo(PdfPage page, double y, BilanModel bilan, mesure.Patient? patient, List<mesure.Pathologies>? pathologies) {
    y += 20;
    page.graphics.drawString(
      'Informations du patient',
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 25;

    final String pathStr = pathologies?.map((e) => e.nom).join(', ') ?? 'Aucune renseignée';
    final String periodStr = 'du ${bilan.periode?.startDate ?? '—'} au ${bilan.periode?.endDate ?? '—'}';

    _drawInfoLine(page, 'Nom :', patient?.nom ?? 'Patient 1', y);
    y += 15;
    _drawInfoLine(page, 'Pathologies :', pathStr, y);
    y += 15;
    _drawInfoLine(page, 'Période :', periodStr, y);
    y += 15;
    _drawInfoLine(page, 'Nombre total de mesures :', '${bilan.periode?.totalMesures ?? 0}', y);
    y += 25;

    return y;
  }

  static void _drawInfoLine(PdfPage page, String label, String value, double y) {
    page.graphics.drawString(
      label,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 150, 15),
    );
    page.graphics.drawString(
      value,
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(150, y, 300, 15),
    );
  }

  static double _drawResumeGlobal(PdfPage page, double y, BilanModel bilan) {
    page.graphics.drawString(
      'Résumé global',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      brush: PdfSolidBrush(PdfColor(39, 174, 96)),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.headers.add(1);
    
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Indicateur';
    header.cells[1].value = 'Normales';
    header.cells[2].value = 'Attention';
    header.cells[3].value = 'Élevées';

    _applyGridStyle(grid);

    PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'Toutes mesures';
    row.cells[1].value = '${bilan.resumeGlobal?.normales ?? 0}';
    row.cells[2].value = '${bilan.resumeGlobal?.attention ?? 0}';
    row.cells[3].value = '${bilan.resumeGlobal?.elevees ?? 0}';

    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    
    return y + result.bounds.height + 30;
  }

  static double _drawPressionArterielle(PdfPage page, double y, PressionArterielle data) {
    page.graphics.drawString(
      'Pression Artérielle',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Statistique';
    header.cells[1].value = 'Systolique';
    header.cells[2].value = 'Diastolique';
    header.cells[3].value = 'Unité';
    _applyGridStyle(grid);

    _addStatRow(grid, 'Moyenne', '${data.averageSystolic}', '${data.averageDiastolic}', 'mmHg');
    _addStatRow(grid, 'Dernière', data.lastMeasure?.split('/')[0] ?? '—', data.lastMeasure?.split('/').length == 2 ? data.lastMeasure!.split('/')[1] : '—', 'mmHg');
    _addStatRow(grid, 'Nb mesures', '${data.count}', '', '');

    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    return y + result.bounds.height + 30;
  }

  static double _drawFrequenceCardiaque(PdfPage page, double y, FrequenceCardiaque data) {
    page.graphics.drawString(
      'Fréquence cardiaque',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = _createSimpleStatGrid(
      'Moyenne', '${data.average}', 'bpm',
      'Min', '${data.min}', 'bpm',
      'Max', '${data.max}', 'bpm',
      'Dernière', '${data.last}', 'bpm'
    );
    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    return y + result.bounds.height + 30;
  }

  static double _drawGlycemie(PdfPage page, double y, Glycemie data) {
    page.graphics.drawString(
      'Glycémie à jeun',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = _createSimpleStatGrid(
      'Moyenne', '${data.average}', 'g/L',
      'Min', '${data.min}', 'g/L',
      'Max', '${data.max}', 'g/L',
      'Dernière', '${data.last}', 'g/L'
    );
    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    return y + result.bounds.height + 30;
  }

  static double _drawPoids(PdfPage page, double y, Poids data) {
    page.graphics.drawString(
      'Poids',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = _createSimpleStatGrid(
      'Moyenne', '${data.average}', 'kg',
      'Min', '${data.min}', 'kg',
      'Max', '${data.max}', 'kg',
      'Dernière', '${data.last}', 'kg'
    );
    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    return y + result.bounds.height + 30;
  }

  static double _drawImc(PdfPage page, double y, Imc data) {
    page.graphics.drawString(
      'IMC',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = _createSimpleStatGrid(
      'Moyenne', '${data.average}', 'kg/m²',
      'Min', '${data.min}', 'kg/m²',
      'Max', '${data.max}', 'kg/m²',
      'Dernière', '${data.last}', 'kg/m²'
    );
    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    return y + result.bounds.height + 30;
  }

  static PdfGrid _createSimpleStatGrid(String l1, String v1, String u1, String l2, String v2, String u2, String l3, String v3, String u3, String l4, String v4, String u4) {
    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Statistique';
    header.cells[1].value = 'Valeur';
    header.cells[2].value = 'Unité';
    _applyGridStyle(grid);

    _addStatRowSimple(grid, l1, v1, u1);
    _addStatRowSimple(grid, l2, v2, u2);
    _addStatRowSimple(grid, l3, v3, u3);
    _addStatRowSimple(grid, l4, v4, u4);
    
    return grid;
  }

  static void _addStatRowSimple(PdfGrid grid, String label, String value, String unit) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = label;
    row.cells[1].value = value;
    row.cells[2].value = unit;
  }

  static void _addStatRow(PdfGrid grid, String label, String v1, String v2, String unit) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = label;
    row.cells[1].value = v1;
    row.cells[2].value = v2;
    row.cells[3].value = unit;
  }

  static void _applyGridStyle(PdfGrid grid) {
    grid.style.cellPadding = PdfPaddings(left: 5, top: 5, bottom: 5, right: 5);
    
    // Header Style
    for (int i = 0; i < grid.headers.count; i++) {
      PdfGridRow header = grid.headers[i];
      header.style.backgroundBrush = PdfSolidBrush(PdfColor(39, 174, 96));
      header.style.textBrush = PdfBrushes.white;
      header.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    }
    
    // Row Style
    for (int i = 0; i < grid.rows.count; i++) {
      PdfGridRow row = grid.rows[i];
      if (i % 2 != 0) {
        row.style.backgroundBrush = PdfSolidBrush(PdfColor(248, 249, 249));
      }
      row.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    }
  }

  static double _drawTraitements(PdfPage page, double y, tr.TraitementModel data) {
    page.graphics.drawString(
      'Traitements en cours',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      brush: PdfSolidBrush(PdfColor(39, 174, 96)),
      bounds: Rect.fromLTWH(0, y, 300, 20),
    );
    y += 20;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Médicament';
    header.cells[1].value = 'Posologie';
    header.cells[2].value = 'Pathologie';
    header.cells[3].value = 'Statut';
    _applyGridStyle(grid);

    for (var trait in data.traitements!) {
      for (var med in trait.medicaments!) {
        PdfGridRow row = grid.rows.add();
        row.cells[0].value = med.name ?? '—';
        row.cells[1].value = med.dosage ?? '—';
        row.cells[2].value = trait.pathologie ?? '—';
        row.cells[3].value = med.status ?? '—';
      }
    }

    PdfLayoutResult result = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0))!;
    return y + result.bounds.height + 30;
  }

  static void _drawFooter(PdfDocument document) {
    final int pageCount = document.pages.count;
    for (int i = 0; i < pageCount; i++) {
      PdfPage page = document.pages[i];
      final Size pageSize = page.getClientSize();
      
      page.graphics.drawString(
        'Ce document est généré automatiquement par Mon Suivi Santé. Il ne remplace pas une consultation médicale.',
        PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.italic),
        brush: PdfBrushes.gray,
        bounds: Rect.fromLTWH(0, pageSize.height - 30, pageSize.width, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      
      page.graphics.drawString(
        'Page ${i + 1} sur $pageCount',
        PdfStandardFont(PdfFontFamily.helvetica, 8),
        brush: PdfBrushes.gray,
        bounds: Rect.fromLTWH(0, pageSize.height - 15, pageSize.width, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    }
  }
}
