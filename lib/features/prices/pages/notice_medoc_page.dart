import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:gap/gap.dart';

class NoticeMedocPage extends StatefulWidget {
  final String? notice;
  final String? libelle;

  const NoticeMedocPage({super.key, this.notice, this.libelle});

  @override
  State<NoticeMedocPage> createState() => _NoticeMedocPageState();
}

class _NoticeMedocPageState extends State<NoticeMedocPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4), // Fond gris/vert très doux
      body: Column(
        children: [
          // Header avec le Libellé
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "MÉDICAMENT",
                    style: TextStyle(
                      color: Color(0xFF2D5A27),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Gap(1.h),
                Text(
                  widget.libelle ?? "Nom inconnu",
                  style: TextStyle(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                Gap(1.h),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Gap(2.w),
                    Text(
                      "Notice officielle patient",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenu HTML
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child:
                  (widget.notice != null && widget.notice!.trim().isNotEmpty)
                      ? SfPdfViewer.network(
                        widget.notice!,
                        key: _pdfViewerKey,
                        scrollDirection: PdfScrollDirection.vertical,
                        canShowScrollHead: true,
                        canShowPaginationDialog: true,
                        onDocumentLoadFailed: (details) {
                          debugPrint("Erreur PDF: ${details.error}");
                        },
                      )
                      : Center(child: Text("Notice non disponible")),
            ),
          ),
        ],
      ),
    );
  }
}
