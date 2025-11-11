import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/policies_service.dart';

class MembershipAgreementPage extends StatefulWidget {
  const MembershipAgreementPage({Key? key}) : super(key: key);

  @override
  State<MembershipAgreementPage> createState() => _MembershipAgreementPageState();
}

class _MembershipAgreementPageState extends State<MembershipAgreementPage> {
  late Future<Map<String, dynamic>?> _agreementFuture;

  @override
  void initState() {
    super.initState();
    _agreementFuture = PoliciesService.getMembershipAgreement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Üyelik Sözleşmesi'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _agreementFuture,
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
                  const Text('Sözleşme yüklenemedi'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _agreementFuture = PoliciesService.getMembershipAgreement();
                      });
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final agreement = snapshot.data!;
          final content = _stripHtmlTags(agreement['postContent'] ?? '');

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    agreement['postTitle'] ?? 'Üyelik Sözleşmesi',
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

        // Check if it's a heading (contains numbers like "1.", "2.", "3.")
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

        // Check if it's a sub-heading (like "3.1.", "3.2.")
        if (paragraph.startsWith(RegExp(r'^\d+\.\d+\.'))) {
          return Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingM, bottom: AppTheme.spacingS),
            child: Text(
              paragraph,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
