import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';

class MentionPage extends StatefulWidget {
  const MentionPage({super.key});

  @override
  State<MentionPage> createState() => _MentionPageState();
}

class _MentionPageState extends State<MentionPage> {
  String? _mentionContent;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMentions();
  }

  Future<void> _fetchMentions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(ApiUrls.getMentionUrl));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _mentionContent = data['contenu'];
          _isLoading = false;
        });
      } else {
        _handleError("Erreur lors de la récupération des mentions légales.");
      }
    } catch (e) {
      _handleError("Problème de connexion. Veuillez réessayer.");
    }
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
        centerTitle: false,
        title: Text(
          "Mentions légales",
          style: TextStyle(
              color: appBlack,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp
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
          child: _isLoading
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
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: appWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Html(
          data: _mentionContent ?? '',
          style: {
            "body": Style(
              fontSize: FontSize(11.sp),
              lineHeight: LineHeight.em(1.6),
              color: appBlack.withValues(alpha: 0.8),
              margin: Margins.zero,
            ),
            "h1": Style(color: appColor, fontWeight: FontWeight.bold, fontSize: FontSize(14.sp)),
            "h2": Style(color: appColor2, fontWeight: FontWeight.bold, fontSize: FontSize(13.sp)),
            "a": Style(color: appColor, textDecoration: TextDecoration.underline),
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
          Icon(Icons.info_outline_rounded, size: 50.sp, color: Colors.grey[300]),
          const Gap(15),
          Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
          const Gap(20),
          TextButton.icon(
            onPressed: _fetchMentions,
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }
}