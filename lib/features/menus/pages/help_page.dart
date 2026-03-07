import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String? _helpContent;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHelpContent();
  }

  Future<void> _fetchHelpContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(ApiUrls.getHelpUrl));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _helpContent = cleanHtml(data['contenu']);
          _isLoading = false;
        });
      } else {
        _handleError("Impossible de charger l'aide pour le moment.");
      }
    } catch (e) {
      _handleError("Erreur de connexion. Vérifiez votre réseau.");
    }
  }

  String cleanHtml(String html) {
    html = html.replaceAll(RegExp(r'font-family:[^;"]*;?'), '');
    html = html.replaceAll(RegExp(r'font:[^;"]*;?'), '');
    html = html.replaceAll(RegExp(r'style="[^"]*"'), '');
    return html;
  }

  void _handleError(String msg) {
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        backgroundColor: appFondLogin,
        elevation: 0,
        title: Text(
          "Centre d'aide",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_outlined, color: appBlack),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: const [0.1, 0.4, 0.4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _errorMessage.isNotEmpty
                  ? _buildErrorView()
                  : _buildContentView(),
        ),
      ),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: appWhite,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Html(
          data: _helpContent ?? '',
          style: {
            "body": Style(
              fontSize: FontSize(14.sp),
              lineHeight: LineHeight.em(1.5),
              color: appBlack.withValues(alpha: 0.8),
              margin: Margins.zero,
            ),
            "h1": Style(
              color: appColor,
              fontWeight: FontWeight.bold,
              fontSize: FontSize(15.sp),
            ),
            "h2": Style(
              color: appColor2,
              fontWeight: FontWeight.bold,
              fontSize: FontSize(13.sp),
            ),
            "li": Style(margin: Margins.only(bottom: 8)),
            "a": Style(color: appColor, fontWeight: FontWeight.w600),
          },
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline_rounded,
            size: 50.sp,
            color: Colors.grey[300],
          ),
          const Gap(15),
          Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
          const Gap(20),
          TextButton.icon(
            onPressed: _fetchHelpContent,
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }
}
