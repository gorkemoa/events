import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/photo_service.dart';

class EventDetailPage extends StatefulWidget {
  final String eventTitle;
  final String clientName;
  final String eventDate;
  final String eventTime;
  final String location;

  const EventDetailPage({
    Key? key,
    required this.eventTitle,
    required this.clientName,
    required this.eventDate,
    required this.eventTime,
    required this.location,
  }) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  // Örnek fotoğraflar - Gerçek uygulamada API'den gelecek
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
  ];

  // Seçim modu için state
  bool _isSelectionMode = false;
  final Set<int> _selectedPhotos = {};

  // Grid sütun sayısı state
  int _gridColumnCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.eventTitle,
          style: AppTheme.labelLarge,
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              setState(() {
                _gridColumnCount = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _gridColumnCount == 3 ? AppTheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.grid_3x3_rounded,
                        size: 20,
                        color: _gridColumnCount == 3 ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('3\'lü'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 4,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _gridColumnCount == 4 ? AppTheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.grid_4x4_rounded,
                        size: 20,
                        color: _gridColumnCount == 4 ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('4\'lü'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 5,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _gridColumnCount == 5 ? AppTheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.grid_on_rounded,
                        size: 20,
                        color: _gridColumnCount == 5 ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('5\'li'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Etkinlik Bilgileri
          Container(
            margin: const EdgeInsets.all(AppTheme.spacingL),
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Katılımcı',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.clientName,
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tarih',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.eventDate,
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saat',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.eventTime,
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                const Text(
                  'Konum',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.location,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fotoğraflar Başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isSelectionMode
                      ? '${_selectedPhotos.length} seçildi'
                      : 'Etkinlik Fotoğrafları (${_photos.length})',
                  style: AppTheme.labelLarge,
                ),
                Row(
                  children: [
                    if (!_isSelectionMode)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSelectionMode = true;
                          });
                        },
                        child: const Text(
                          'Seç',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_isSelectionMode)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSelectionMode = false;
                            _selectedPhotos.clear();
                          });
                        },
                        child: const Text(
                          'İptal',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Fotoğraf Grid'i
          Expanded(
            child: _photos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Henüz fotoğraf yüklenmedi',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                      vertical: AppTheme.spacingS,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridColumnCount,
                      crossAxisSpacing: AppTheme.spacingS,
                      mainAxisSpacing: AppTheme.spacingS,
                      childAspectRatio: 1,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedPhotos.contains(index);
                      return GestureDetector(
                        onTap: () {
                          if (_isSelectionMode) {
                            setState(() {
                              if (isSelected) {
                                _selectedPhotos.remove(index);
                              } else {
                                _selectedPhotos.add(index);
                              }
                              // Eğer hiç seçim yapılmamışsa seçim modundan çık
                              if (_selectedPhotos.isEmpty) {
                                _isSelectionMode = false;
                              }
                            });
                          } else {
                            _showPhotoDetail(index);
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _isSelectionMode = true;
                            _selectedPhotos.add(index);
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                _photos[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Hover efekti için gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              // Seçim modu overlay
                              if (_isSelectionMode)
                                Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              // Seçim checkbox'ı
                              if (_isSelectionMode)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Alt Buton / Seçim Aksiyon Barı
          if (!_isSelectionMode)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _downloadAllPhotos();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      side: const BorderSide(color: AppTheme.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Telefon Galerisine İndir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Hepsini seç
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_selectedPhotos.length == _photos.length) {
                                  _selectedPhotos.clear();
                                  _isSelectionMode = false;
                                } else {
                                  _selectedPhotos.addAll(
                                    List.generate(_photos.length, (i) => i),
                                  );
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  _selectedPhotos.length == _photos.length
                                      ? 'Seçimi Kaldır'
                                      : 'Hepsini Seç',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    // İndir butonu
                    Expanded(
                      child: _SelectionActionButton(
                        icon: Icons.download_rounded,
                        label: 'İndir',
                        onTap: () {
                          _downloadSelectedPhotos();
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    // Paylaş butonu
                    Expanded(
                      child: _SelectionActionButton(
                        icon: Icons.share_rounded,
                        label: 'Paylaş',
                        onTap: () {
                          _shareSelectedPhotos();
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    // Sil butonu
                    Expanded(
                      child: _SelectionActionButton(
                        icon: Icons.delete_rounded,
                        label: 'Sil',
                        color: AppTheme.error,
                        onTap: () {
                          _deleteSelectedPhotos();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }


  void _showPhotoDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoDetailScreen(
          photos: _photos,
          initialIndex: index,
          onDelete: (photoIndex) {
            _confirmDelete(photoIndex);
          },
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Fotoğrafı Sil'),
          content: const Text('Bu fotoğrafı silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _photos.removeAt(index);
                });
                Navigator.pop(context);
                _showSnackBar('Fotoğraf silindi');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
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

  void _downloadAllPhotos() {
    if (_photos.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tüm Fotoğrafları İndir'),
          content: Text(
            '${_photos.length} fotoğrafı galeriye kaydetmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Onay dialog'unu kapat

                if (!mounted) return;

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
                        Text('${_photos.length} fotoğraf indiriliyor...'),
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

                // Arka planda indir - kullanıcı app'i kapatsa da devam eder
                _downloadInBackground(_photos);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('İndir' , style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  void _downloadSelectedPhotos() {
    if (_selectedPhotos.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Fotoğrafları İndir'),
          content: Text(
            '${_selectedPhotos.length} fotoğraf telefon galerisine indirilecektir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                
                // Seçili fotoğrafların URL'lerini al
                final selectedUrls = _selectedPhotos.map((index) => _photos[index]).toList();
                
                // Başlangıç bildirimi
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
                        Text('${_selectedPhotos.length} fotoğraf indiriliyor...'),
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
                
                // Arka planda indir
                _downloadInBackground(selectedUrls);
                
                // Seçimi temizle
                setState(() {
                  _selectedPhotos.clear();
                  _isSelectionMode = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('İndir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _shareSelectedPhotos() {
    if (_selectedPhotos.isEmpty) return;
    
    _showSnackBar('${_selectedPhotos.length} fotoğraf paylaşılıyor...');
  }

  void _deleteSelectedPhotos() {
    if (_selectedPhotos.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Fotoğrafları Sil'),
          content: Text(
            '${_selectedPhotos.length} fotoğrafı silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final sortedIndices = _selectedPhotos.toList()..sort((a, b) => b.compareTo(a));
                setState(() {
                  for (final index in sortedIndices) {
                    _photos.removeAt(index);
                  }
                  _selectedPhotos.clear();
                  _isSelectionMode = false;
                });
                Navigator.pop(context);
                _showSnackBar('${sortedIndices.length} fotoğraf silindi');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _PhotoDetailScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final Function(int) onDelete;

  const _PhotoDetailScreen({
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  State<_PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<_PhotoDetailScreen> {
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
      body: Stack(
        children: [
          // Fotoğraf PageView with Dismissible
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return _DismissiblePhotoView(
                onDismissed: () => Navigator.pop(context),
                onTap: _toggleUI,
                child: Center(
                  child: Image.network(
                    widget.photos[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Üst Bar (Geri butonu ve sayaç)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _isUIVisible ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance için
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Alt Aksiyon Barı
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isUIVisible ? -20 : -200,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PhotoActionIconButton(
                        icon: Icons.visibility_off_rounded,
                        label: 'Gizle',
                        onTap: () {
                          // Gizle fonksiyonu
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.info_outline_rounded,
                        label: 'Bilgi',
                        onTap: () {
                          _showPhotoInfo();
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.favorite_border_rounded,
                        label: 'Favori',
                        onTap: () {
                          // Favori fonksiyonu
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.share_rounded,
                        label: 'Paylaş',
                        onTap: () {
                          _sharePhoto();
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.download_rounded,
                        label: 'İndir',
                        onTap: () {
                          _downloadPhoto();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Fotoğraf küçük resimleri (thumbnail)
          if (widget.photos.length > 1)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _isUIVisible ? 120 : -100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            widget.photos[index],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _downloadPhoto() async {
    try {
      final currentPhotoUrl = widget.photos[_currentIndex];
      final success = await PhotoService.downloadPhoto(currentPhotoUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Fotoğraf galeriye kaydedildi' : 'İndirme başarısız'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: success ? AppTheme.primary : Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _sharePhoto() async {
    try {
      final currentPhotoUrl = widget.photos[_currentIndex];
      
      // iOS için share position
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      
      await PhotoService.sharePhoto(
        currentPhotoUrl,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPhotoInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fotoğraf Bilgileri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.image_outlined,
                label: 'Fotoğraf',
                value: '${_currentIndex + 1} / ${widget.photos.length}',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Tarih',
                value: '6 Kasım 2025',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.access_time_outlined,
                label: 'Saat',
                value: '14:30',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.photo_size_select_actual_outlined,
                label: 'Boyut',
                value: '1920 x 1080',
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _PhotoActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

class _SelectionActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SelectionActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<_SelectionActionButton> createState() => _SelectionActionButtonState();
}

class _SelectionActionButtonState extends State<_SelectionActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.color ?? AppTheme.primary).withOpacity(0.9)
              : (widget.color ?? AppTheme.primary),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
