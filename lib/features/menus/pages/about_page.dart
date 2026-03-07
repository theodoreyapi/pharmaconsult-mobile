import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? _aboutText;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAboutText();
  }

  Future<void> _fetchAboutText() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(ApiUrls.getAboutUrl));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _aboutText = data['contenu'];
          _isLoading = false;
          _error = '';
        });
      } else {
        _handleError('Une erreur serveur est survenue.');
      }
    } catch (e) {
      _handleError(
        'Impossible de charger le contenu. Vérifiez votre connexion.',
      );
    }
  }

  void _handleError(String msg) {
    setState(() {
      _error = msg;
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
        centerTitle: false,
        title: Text(
          "À propos de nous",
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
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: appWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Html(
          data: _aboutText ?? '',
          style: {
            "body": Style(
              fontSize: FontSize(12.sp),
              color: appBlack,
              textAlign: TextAlign.justify,
              lineHeight: LineHeight.em(1.5),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "strong": Style(fontWeight: FontWeight.bold, color: appColor),
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.grey, size: 40.sp),
            const Gap(15),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const Gap(20),
            TextButton.icon(
              onPressed: _fetchAboutText,
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}
