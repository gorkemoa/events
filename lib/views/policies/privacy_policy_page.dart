import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/policies_service.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late Future<Map<String, dynamic>?> _policyFuture;

  @override
  void initState() {
    super.initState();
    _policyFuture = PoliciesService.getPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Gizlilik Politikası'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _policyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Politika yüklenemedi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _policyFuture = PoliciesService.getPrivacyPolicy();
                      });
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final policy = snapshot.data!;
          final content = _stripHtmlTags(policy['postContent'] ?? '');

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    policy['postTitle'] ?? 'Gizlilik Politikası',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),

                  // Content with proper formatting
                  _buildFormattedContent(content),

                  const SizedBox(height: AppTheme.spacing3XL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build formatted content with proper spacing and styling
  Widget _buildFormattedContent(String content) {
    final paragraphs = content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(paragraphs.length, (index) {
        final paragraph = paragraphs[index].trim();

        // Check if it's a heading (ALL CAPS or contains numbers like "1.", "2.", "3.")
        if (paragraph == paragraph.toUpperCase() && paragraph.length > 10) {
          return Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingXL, bottom: AppTheme.spacingM),
            child: Text(
              paragraph,
              style: AppTheme.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          );
        }

        // Check if it's a numbered heading (like "1. Something")
        if (paragraph.startsWith(RegExp(r'^\d+\.'))) {
          return Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingXL, bottom: AppTheme.spacingM),
            child: Text(
              paragraph,
              style: AppTheme.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          );
        }

        // Check if it contains bullet points
        if (paragraph.contains('•')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Text(
              paragraph,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          );
        }

        // Regular paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Text(
            paragraph,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        );
      }),
    );
  }

  /// Strip HTML tags and decode HTML entities
  String _stripHtmlTags(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    final decoded = htmlText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&ağ;', 'ağ')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Ş;', 'Ş')
        .replaceAll('&ş;', 'ş')
        .replaceAll('&İ;', 'İ')
        .replaceAll('&ı;', 'ı')
        .replaceAll('&Ğ;', 'Ğ')
        .replaceAll('&ğ;', 'ğ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('<br />', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('</li>', '\n')
        .replaceAll('<li>', '• ')
        .replaceAll('</p>', '\n\n')
        .replaceAll('<p>', '')
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('<em>', '')
        .replaceAll('</em>', '')
        .replaceAll('<u>', '')
        .replaceAll('</u>', '')
        .replaceAll('<ul>', '')
        .replaceAll('</ul>', '\n')
        .replaceAll('\r', '');

    // Remove any remaining HTML tags
    final cleaned = decoded.replaceAll(regex, '');

    // Clean up multiple spaces and newlines
    final normalized = cleaned
        .replaceAll(RegExp(r' +'), ' ')
        .replaceAll(RegExp(r'\n\n\n+'), '\n\n');

    return normalized.trim();
  }
}
