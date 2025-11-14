import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/views/gallery/photo_detail_page.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/photo_service.dart';

class GalleryPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const GalleryPage({Key? key, this.onMenuPressed}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedFilter = 'Tümü';
  final Set<String> _favorites = {};
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotos = {};

  // Sample photos data - çekilen fotoğraflar
  final List<Map<String, dynamic>> photos = [
    {
      'id': '1',
      'url':
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=500&fit=crop',
      'title': 'Kahve Festivali Stand',
      'date': '5 Kasım 2025',
      'time': '10:30',
      'category': 'Business',
      'event': 'Kahve Festivali 2025',
    },
    {
      'id': '2',
      'url':
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400&h=300&fit=crop',
      'title': 'Barista Yarışması',
      'date': '5 Kasım 2025',
      'time': '14:00',
      'category': 'Business',
      'event': 'Kahve Festivali 2025',
    },
    {
      'id': '3',
      'url':
          'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=400&h=400&fit=crop',
      'title': 'Ticari Fuarı',
      'date': '3 Kasım 2025',
      'time': '09:15',
      'category': 'Business',
      'event': 'İnsan Kaynakları Konferansı',
    },
    {
      'id': '4',
      'url':
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=500&fit=crop',
      'title': 'Kurumsal Etkinlik',
      'date': '2 Kasım 2025',
      'time': '18:00',
      'category': 'Business',
      'event': 'Yıllık Gala Akşamı',
    },
    {
      'id': '5',
      'url':
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'title': 'Ağ Oluşturma Etkinliği',
      'date': '1 Kasım 2025',
      'time': '17:30',
      'category': 'Business',
      'event': 'Girişimci Forumu',
    },
    {
      'id': '6',
      'url':
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=350&fit=crop',
      'title': 'Seminer Sunumu',
      'date': '31 Ekim 2025',
      'time': '11:00',
      'category': 'Business',
      'event': 'Teknoloji Zirvesi',
    },
    {
      'id': '7',
      'url':
          'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=400&h=500&fit=crop',
      'title': 'Başarı Ödülü Töreni',
      'date': '30 Ekim 2025',
      'time': '19:00',
      'category': 'Business',
      'event': 'Işletme Ödül Törenı',
    },
    {
      'id': '8',
      'url':
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'title': 'Ticari Ortaklık İmza',
      'date': '29 Ekim 2025',
      'time': '15:45',
      'category': 'Business',
      'event': 'İş Geliştirme Toplantısı',
    },
    {
      'id': '9',
      'url':
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=500&fit=crop',
      'title': 'Müşteri Sunumu',
      'date': '28 Ekim 2025',
      'time': '13:30',
      'category': 'Business',
      'event': 'Proje Lansmanı',
    },
  ];

  List<Map<String, dynamic>> get filteredPhotos {
    if (_selectedFilter == 'Tümü') {
      return photos;
    } else if (_selectedFilter == 'Favoriler') {
      return photos.where((photo) => _favorites.contains(photo['id'])).toList();
    }
    return photos.where((photo) => photo['event'] == _selectedFilter).toList();
  }

  List<String> get filterOptions {
    final events = photos.map((p) => p['event'] as String).toSet().toList();
    return ['Tümü', 'Favoriler', ...events];
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
                        ? '$successCount fotoğraf galeriye kaydedildi'
                        : successCount > 0
                            ? '$successCount/${photoUrls.length} fotoğraf kaydedildi'
                            : 'Fotoğraflar kaydedilemedi',
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
            Text('$photoCount fotoğraf indiriliyor...'),
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
        title: const Text('Fotoğrafları Sil'),
        content: Text(
          '${_selectedPhotos.length} fotoğrafı silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
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
                const SnackBar(
                  content: Text('Fotoğraflar silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
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
            content: Text('Paylaşım hatası: ${e.toString()}'),
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
          // Refresh gallery logic can be added here
          await Future.delayed(const Duration(seconds: 1));
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
                      subtitle: 'Fotoğraflar',
                      locationText: '${photos.length} fotoğraf',
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

                    if (filter == 'Tümü') {
                      count = photos.length;
                    } else if (filter == 'Favoriler') {
                      count = _favorites.length;
                    } else {
                      count = photos.where((p) => p['event'] == filter).length;
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
                              if (filter == 'Favoriler')
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Color(0xFFFFB800),
                                ),
                              if (filter == 'Favoriler')
                                const SizedBox(width: 6),
                              Text(
                                '$filter ($count)',
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
                              'Bu etkinlikten fotoğraf yok',
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
                        label: 'Paylaş',
                        onTap: _shareSelectedPhotos,
                      ),
                      _ActionButton(
                        icon: Icons.cloud_download_outlined,
                        label: 'İndir',
                        onTap: _downloadSelectedPhotos,
                      ),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        label: 'Sil',
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
            child: const Text(
              'İptal',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$selectedCount Seçildi',
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
              isAllSelected ? 'Temizle' : 'Tümü',
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
