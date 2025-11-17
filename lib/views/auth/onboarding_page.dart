import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late List<OnboardingData> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      OnboardingData(
        title: context.tr('onboarding.page1_title'),
        description: context.tr('onboarding.page1_description'),
        images: [
          'assets/onboarding/foto.jpeg',
          'assets/onboarding/foto2.jpeg',
          'assets/onboarding/foto3.jpeg',
          'assets/onboarding/foto4.jpeg',
          'assets/onboarding/foto5.jpeg',
        ],
      ),
      OnboardingData(
        title: context.tr('onboarding.page2_title'),
        description: context.tr('onboarding.page2_description'),
        images: [
          'assets/onboarding/foto6.jpeg',
          'assets/onboarding/foto7.jpeg',
          'assets/onboarding/foto8.jpeg',
          'assets/onboarding/foto9.jpeg',
          'assets/onboarding/foto10.jpeg',
        ],
      ),
      OnboardingData(
        title: context.tr('onboarding.page3_title'),
        description: context.tr('onboarding.page3_description'),
        images: [
          'assets/onboarding/foto11.jpeg',
          'assets/onboarding/foto12.jpeg',
          'assets/onboarding/foto13.jpeg',
          'assets/onboarding/foto8.jpeg',
          'assets/onboarding/foto9.jpeg',
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Son sayfada "Başla" butonuna basıldığında
      // Onboarding'i gösterilmiş olarak işaretle ve auth sayfasına yönlendir
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await StorageHelper.setOnboardingShown();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [          
            // PageView ile içerik
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Alt kısım - Indicator ve Button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing2XL),
              child: Column(
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing3XL),

                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1 
                            ? context.tr('onboarding.button_start') 
                            : context.tr('onboarding.button_next'),
                        style: AppTheme.buttonLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        children: [
          // Görsel Grid
          Expanded(
            child: _buildImageGrid(data.images),
          ),
          const SizedBox(height: AppTheme.spacing3XL),

          // Başlık
          Text(
            data.title,
            style: AppTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Açıklama
          Text(
            data.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textTertiary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Alt çizgi (dekoratif)
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    // Referans görsele göre layout
    // Sol tarafta 2 küçük görsel üst üste
    // Ortada 1 büyük görsel (2 satır yüksekliğinde)
    // Sağ tarafta 2 küçük görsel üst üste
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sol kolon - 2 görsel
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildImageCard(images[0], borderRadius: 16),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Expanded(
                child: _buildImageCard(images[1], borderRadius: 16),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),

        // Orta kolon - 1 büyük görsel (tam yükseklik)
        Expanded(
          flex: 3,
          child: _buildImageCard(images[2], borderRadius: 16),
        ),
        const SizedBox(width: AppTheme.spacingS),

        // Sağ kolon - 2 görsel
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildImageCard(images[3], borderRadius: 16),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Expanded(
                child: _buildImageCard(images[4], borderRadius: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(String imagePath, {double borderRadius = 12}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.surfaceColor,
              child: const Icon(
                Icons.image,
                color: AppTheme.textHint,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.textPrimary : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final List<String> images;

  OnboardingData({
    required this.title,
    required this.description,
    required this.images,
  });
}
