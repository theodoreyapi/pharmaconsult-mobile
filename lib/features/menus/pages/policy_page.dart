import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  String? _policyContent;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
  }

  Future<void> _fetchPolicy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(ApiUrls.getPolicyUrl));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _policyContent = cleanHtml(data['contenu'] ?? '');
          _isLoading = false;
        });
      } else {
        _handleError("Erreur serveur (${response.statusCode})");
      }
    } catch (e) {
      _handleError("Problème de connexion internet.");
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
          "Confidentialité",
          style: TextStyle(color: appBlack, fontWeight: FontWeight.bold, fontSize: 16.sp),
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
          data: _policyContent ?? '',
          style: {
            "body": Style(
              fontSize: FontSize(14.sp),
              lineHeight: LineHeight.em(1.6),
              color: appBlack.withValues(alpha: 0.8),
              textAlign: TextAlign.left,
              margin: Margins.zero,
            ),
            "h1": Style(color: appColor, fontWeight: FontWeight.bold, fontSize: FontSize(16.sp)),
            "h2": Style(color: appColor2, fontWeight: FontWeight.bold, fontSize: FontSize(14.sp)),
            "strong": Style(color: appBlack, fontWeight: FontWeight.bold),
            "li": Style(margin: Margins.only(bottom: 5)),
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
          const Icon(Icons.security_update_warning_rounded, size: 60, color: Colors.grey),
          const Gap(15),
          Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
          const Gap(20),
          ElevatedButton(
            onPressed: _fetchPolicy,
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }
}