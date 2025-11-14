import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/photo_service.dart';

class PhotoDetailPage extends StatefulWidget {
  final Map<String, dynamic> photo;
  final List<Map<String, dynamic>> allPhotos;
  final int initialIndex;

  const PhotoDetailPage({
    Key? key,
    required this.photo,
    required this.allPhotos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isUIVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _isUIVisible = !_isUIVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Photo Viewer with Dismissible
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.allPhotos.length,
              itemBuilder: (context, index) {
                final photo = widget.allPhotos[index];
                return _DismissiblePhotoView(
                  onDismissed: () => Navigator.pop(context),
                  onTap: _toggleUI,
                  child: Container(
                    color: Colors.black,
                    child: Image.network(
                      photo['url'] ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            // Header
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _isUIVisible ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXS),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingXS),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        GestureDetector(
                          onTap: () async {
                            final currentPhoto = widget.allPhotos[_currentIndex];
                            try {
                              // iOS için share position
                              final box = context.findRenderObject() as RenderBox?;
                              final sharePositionOrigin = box != null
                                  ? box.localToGlobal(Offset.zero) & box.size
                                  : null;
                              
                              await PhotoService.sharePhoto(
                                currentPhoto['url'],
                                text: currentPhoto['title'] ?? 'Pixlomi ile paylaşıldı',
                                sharePositionOrigin: sharePositionOrigin,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Paylaşım hatası: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingXS),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Info
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _isUIVisible ? 0 : -200,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.allPhotos[_currentIndex]['title'] ?? 'Fotoğraf',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Text(
                          widget.allPhotos[_currentIndex]['date'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                        if (widget.allPhotos[_currentIndex]['time'] != null)
                          Text(
                            ' • ${widget.allPhotos[_currentIndex]['time']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // Event info
                    if (widget.allPhotos[_currentIndex]['event'] != null)
                      Text(
                        widget.allPhotos[_currentIndex]['event'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white60,
                        ),
                      ),
                    const SizedBox(height: AppTheme.spacingS),
                    // Photo Counter
                    Text(
                      '${_currentIndex + 1}/${widget.allPhotos.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// iOS-style Dismissible Photo View
class _DismissiblePhotoView extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  const _DismissiblePhotoView({
    required this.child,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  State<_DismissiblePhotoView> createState() => _DismissiblePhotoViewState();
}

class _DismissiblePhotoViewState extends State<_DismissiblePhotoView> {
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.2;
    final dragProgress = (_dragOffset.abs() / dismissThreshold).clamp(0.0, 1.0);
    final opacity = 1.0 - (dragProgress * 0.7);
    final scale = 1.0 - (dragProgress * 0.2);

    return GestureDetector(
      onTap: widget.onTap,
      onVerticalDragStart: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          // Only allow downward drag
          if (_dragOffset < 0) {
            _dragOffset = 0;
          }
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > dismissThreshold) {
          widget.onDismissed();
        } else {
          setState(() {
            _dragOffset = 0;
            _isDragging = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _dragOffset, 0.0)
          ..scale(scale),
        child: Opacity(
          opacity: opacity,
          child: widget.child,
        ),
      ),
    );
  }
}
