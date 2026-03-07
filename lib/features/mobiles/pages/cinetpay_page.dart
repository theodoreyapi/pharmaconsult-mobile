import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CinetpayPage extends StatefulWidget {
  String? montant;
  String? transaction;

  CinetpayPage({super.key, this.montant, this.transaction});

  @override
  State<CinetpayPage> createState() => _CinetpayPageState();
}

class _CinetpayPageState extends State<CinetpayPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur de chargement : ${error.description}')),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('payment/success')) {
              Navigator.pop(context, 'success');
              return NavigationDecision.prevent;
            }
            if (request.url.contains('payment/failed')) {
              Navigator.pop(context, 'failed');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.transaction!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechargement de compte')),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
