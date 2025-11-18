import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/views/gallery/photo_detail_page.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/photo_service.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class GalleryPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const GalleryPage({Key? key, this.onMenuPressed}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedFilter = 'all';
  final Set<String> _favorites = {};
  final Set<String> _hiddenPhotos = {};
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotos = {};
  List<Map<String, dynamic>> photos = [];

  List<Map<String, dynamic>> get filteredPhotos {
    if (_selectedFilter == 'all') {
      return photos.where((photo) => !_hiddenPhotos.contains(photo['id'])).toList();
    } else if (_selectedFilter == 'favorites') {
      return photos.where((photo) => _favorites.contains(photo['id']) && !_hiddenPhotos.contains(photo['id'])).toList();
    } else if (_selectedFilter == 'hidden') {
      return photos.where((photo) => _hiddenPhotos.contains(photo['id'])).toList();
    }
    return photos.where((photo) => photo['event'] == _selectedFilter && !_hiddenPhotos.contains(photo['id'])).toList();
  }

  List<String> get filterOptions {
    final events = photos.map((p) => p['event'] as String).toSet().toList();
    return ['all', 'favorites', 'hidden', ...events];
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPhotos.clear();
      }
    });
  }

  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotos.contains(photoId)) {
        _selectedPhotos.remove(photoId);
        if (_selectedPhotos.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPhotos.add(photoId);
      }
    });
  }

  Future<void> _downloadInBackground(List<String> photoUrls) async {
    try {
      print('🔄 Arka planda indiriliyor: ${photoUrls.length} fotoğraf');
      
      final successCount = await PhotoService.downloadPhotos(photoUrls);
      
      print('✅ İndirme tamamlandı: $successCount/${photoUrls.length}');

      // Sonuç bildirimi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  successCount == photoUrls.length ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    successCount == photoUrls.length
                        ? context.tr('gallery.download_success', args: {'count': successCount.toString()})
                        : successCount > 0
                            ? context.tr('gallery.download_partial', args: {'success': successCount.toString(), 'total': photoUrls.length.toString()})
                            : context.tr('gallery.download_failed'),
                  ),
                ),
              ],
            ),
            backgroundColor: successCount > 0 ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Arka plan indirme hatası: $e');
      
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _downloadSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) return;

    // Seçili fotoğrafların URL'lerini al
    final selectedUrls = photos
        .where((photo) => _selectedPhotos.contains(photo['id']))
        .map((photo) => photo['url'] as String)
        .toList();

    final photoCount = selectedUrls.length;

    // Başlangıç bildirimi - kullanıcı uygulamayı kapatabilir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(context.tr('gallery.downloading', args: {'count': photoCount.toString()})),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Seçimi temizle - kullanıcı devam edebilsin
    setState(() {
      _selectedPhotos.clear();
      _isSelectionMode = false;
    });

    // Arka planda indir - kullanıcı app'i kapatsa da devam eder
    _downloadInBackground(selectedUrls);
  }

  void _deleteSelectedPhotos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('gallery.delete_title')),
        content: Text(
          context.tr('gallery.delete_confirm', args: {'count': _selectedPhotos.length.toString()}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                photos.removeWhere(
                  (photo) => _selectedPhotos.contains(photo['id']),
                );
                _selectedPhotos.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('gallery.delete_success')),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(context.tr('common.delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) return;

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      // Seçili fotoğrafların URL'lerini al
      final selectedUrls = photos
          .where((photo) => _selectedPhotos.contains(photo['id']))
          .map((photo) => photo['url'] as String)
          .toList();

      // iOS için share position
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      // Fotoğrafları paylaş
      await PhotoService.sharePhotos(
        selectedUrls,
        sharePositionOrigin: sharePositionOrigin,
      );

      // Loading'i kapat
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Loading'i kapat
      if (mounted) Navigator.pop(context);

      // Hata göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('gallery.share_error', args: {'error': e.toString()})),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          // Sayfayı yenile
          setState(() {});
        },
        color: AppTheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              // Header - Seçim moduna göre değişir
              _isSelectionMode
                  ? _SelectionHeader(
                      selectedCount: _selectedPhotos.length,
                      onCancel: _toggleSelectionMode,
                      onSelectAll: () {
                        setState(() {
                          if (_selectedPhotos.length == filteredPhotos.length) {
                            _selectedPhotos.clear();
                          } else {
                            _selectedPhotos.addAll(
                              filteredPhotos.map((p) => p['id'] as String),
                            );
                          }
                        });
                      },
                      isAllSelected:
                          _selectedPhotos.length == filteredPhotos.length &&
                          filteredPhotos.isNotEmpty,
                    )
                  : HomeHeader(
                      subtitle: context.tr('gallery.title'),
                      locationText: context.tr('gallery.photo_count', args: {'count': photos.length.toString()}),
                      onMenuPressed: widget.onMenuPressed,
                      onNotificationPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),

              // Etkinliklere göre Filter - Horizontal Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                ),
                child: Row(
                  children: filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    int count = 0;

                    if (filter == 'all') {
                      count = photos.where((p) => !_hiddenPhotos.contains(p['id'])).length;
                    } else if (filter == 'favorites') {
                      count = _favorites.length;
                    } else if (filter == 'hidden') {
                      count = _hiddenPhotos.length;
                    } else {
                      count = photos.where((p) => p['event'] == filter && !_hiddenPhotos.contains(p['id'])).length;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingM),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingL,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? null
                                : Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              if (filter == 'favorites')
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Color(0xFFFFB800),
                                ),
                              if (filter == 'favorites')
                                const SizedBox(width: 6),
                              if (filter == 'hidden')
                                Icon(
                                  Icons.visibility_off,
                                  size: 16,
                                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                                ),
                              if (filter == 'hidden')
                                const SizedBox(width: 6),
                              Text(
                                '${context.tr('gallery.$filter')} ($count)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Photos Grid - iPhone Photos App style
              Expanded(
                child: filteredPhotos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                            Text(
                              context.tr('gallery.no_photos'),
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingL,
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                                childAspectRatio: 1,
                              ),
                          itemCount: filteredPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = filteredPhotos[index];
                            final isFavorite = _favorites.contains(photo['id']);
                            final isSelected = _selectedPhotos.contains(
                              photo['id'],
                            );
                            return _PhotoTile(
                              imageUrl: photo['url'],
                              isFavorite: isFavorite,
                              isSelected: isSelected,
                              isSelectionMode: _isSelectionMode,
                              onTap: () {
                                if (_isSelectionMode) {
                                  _togglePhotoSelection(photo['id']);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoDetailPage(
                                        photo: photo,
                                        allPhotos: filteredPhotos,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedPhotos.add(photo['id']);
                                  });
                                }
                              },
                              onFavoriteTap: () {
                                setState(() {
                                  if (isFavorite) {
                                    _favorites.remove(photo['id']);
                                  } else {
                                    _favorites.add(photo['id']);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      // Alt menü - Seçim modunda gösterilir (iPhone style - compact)
      bottomNavigationBar: _isSelectionMode && _selectedPhotos.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 0.5),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.ios_share,
                        label: context.tr('gallery.share'),
                        onTap: _shareSelectedPhotos,
                      ),
                      _ActionButton(
                        icon: Icons.cloud_download_outlined,
                        label: context.tr('gallery.download'),
                        onTap: _downloadSelectedPhotos,
                      ),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        label: context.tr('common.delete'),
                        onTap: _deleteSelectedPhotos,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final bool isSelected;
  final bool isSelectionMode;

  const _PhotoTile({
    required this.imageUrl,
    required this.onTap,
    this.onLongPress,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 3)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
            // Overlay when selected
            if (isSelected) Container(color: AppTheme.primary.withOpacity(0.2)),
            // Favori butonu - sadece seçim modu değilse göster
            if (!isSelectionMode)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_outline,
                      color: isFavorite
                          ? const Color(0xFFFFB800)
                          : Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            // Seçim işareti
            if (isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Seçim header widget
class _SelectionHeader extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onSelectAll;
  final bool isAllSelected;

  const _SelectionHeader({
    required this.selectedCount,
    required this.onCancel,
    required this.onSelectAll,
    required this.isAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            child: Text(
              context.tr('common.cancel'),
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            context.tr('gallery.selected_count', args: {'count': selectedCount.toString()}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSelectAll,
            child: Text(
              isAllSelected ? context.tr('gallery.clear_selection') : context.tr('gallery.select_all'),
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Action button widget - iPhone style minimal
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: buttonColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: buttonColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
