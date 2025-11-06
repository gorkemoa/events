import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';

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
                      _markAsDone();
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

  void _markAsDone() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Etkinliği Tamamla'),
          content: const Text(
            'Bu etkinliği tamamlandı olarak işaretlemek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
                Navigator.pop(context); // Detay sayfasından çık
                _showSnackBar('Etkinlik tamamlandı olarak işaretlendi');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tamamla'),
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
      builder: (context) {
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
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('${_selectedPhotos.length} fotoğraf indiriliyor...');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fotoğraf PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
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
          Positioned(
            top: 0,
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
          Positioned(
            bottom: -20,
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
                        icon: Icons.download_rounded,
                        label: 'İndir',
                        onTap: () {
                          _downloadPhoto();
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
                        icon: Icons.info_outline_rounded,
                        label: 'Bilgi',
                        onTap: () {
                          _showPhotoInfo();
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Sil',
                        color: AppTheme.error,
                        onTap: () {
                          widget.onDelete(_currentIndex);
                          Navigator.pop(context);
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
            Positioned(
              bottom: 120,
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

  void _downloadPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fotoğraf indiriliyor...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sharePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Paylaşım seçenekleri açılıyor...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
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
