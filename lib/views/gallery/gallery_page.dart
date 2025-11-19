import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/photo_service.dart';
import 'package:pixlomi/localizations/app_localizations.dart';
import 'package:pixlomi/viewmodels/gallery_viewmodel.dart';

class GalleryPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const GalleryPage({Key? key, this.onMenuPressed}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final GalleryViewModel _viewModel;
  bool _isDragSelecting = false;
  int _gridColumnCount = 3;

  @override
  void initState() {
    super.initState();
    _viewModel = GalleryViewModel();
    _loadPhotos();
  }

  void _setGridColumnCount(int count) {
    setState(() {
      _gridColumnCount = count;
    });
  }

  Future<void> _loadPhotos() async {
    await _viewModel.fetchUserPhotos();
    
    if (mounted && _viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _downloadInBackground(List<String> photoUrls) async {
    try {
      print('🔄 Arka planda indiriliyor: ${photoUrls.length} fotoğraf');
      
      final successCount = await PhotoService.downloadPhotos(photoUrls);
      
      print('✅ İndirme tamamlandı: $successCount/${photoUrls.length}');

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
    if (_viewModel.selectedPhotos.isEmpty) return;

    final selectedUrls = _viewModel.getSelectedMainPhotoUrls();
    final photoCount = selectedUrls.length;

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

    _viewModel.disableSelectionMode();
    _downloadInBackground(selectedUrls);
  }

  void _hideSelectedPhotos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('gallery.hide_title')),
        content: Text(
          context.tr('gallery.hide_confirm', args: {'count': _viewModel.selectedPhotos.length.toString()}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              await _viewModel.hideSelectedPhotos();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('gallery.hide_success')),
                  backgroundColor: Colors.white,
                ),
              );
            },
            child: Text(context.tr('gallery.hide'), style: const TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _shareSelectedPhotos() async {
    if (_viewModel.selectedPhotos.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      final selectedUrls = _viewModel.getSelectedMainPhotoUrls();

      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await PhotoService.sharePhotos(
        selectedUrls,
        sharePositionOrigin: sharePositionOrigin,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);

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
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final filteredPhotos = _viewModel.filteredPhotos;

          return RefreshIndicator(
            onRefresh: _loadPhotos,
            color: AppTheme.primary,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _viewModel.isSelectionMode
                      ? _SelectionHeader(
                          selectedCount: _viewModel.selectedPhotos.length,
                          onCancel: _viewModel.toggleSelectionMode,
                          onSelectAll: _viewModel.selectAllPhotos,
                          isAllSelected:
                              _viewModel.selectedPhotos.length == filteredPhotos.length &&
                              filteredPhotos.isNotEmpty,
                        )
                      : Column(
                          children: [
                            HomeHeader(
                              subtitle: context.tr('gallery.title'),
                              locationText: context.tr('gallery.photo_count', args: {'count': _viewModel.allPhotos.length.toString()}),
                              onMenuPressed: widget.onMenuPressed,
                              onNotificationPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                            // Grid seçenekleri
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PopupMenuButton<int>(
                                    icon: const Icon(Icons.grid_view_rounded, color: Colors.black, size: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: _setGridColumnCount,
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
                                                Icons.grid_on,
                                                size: 20,
                                                color: _gridColumnCount == 3 ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(context.tr('gallery.grid_3')),
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
                                                Icons.grid_on,
                                                size: 20,
                                                color: _gridColumnCount == 4 ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(context.tr('gallery.grid_4')),
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
                                                Icons.grid_on,
                                                size: 20,
                                                color: _gridColumnCount == 5 ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(context.tr('gallery.grid_5')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                    ),
                    child: Row(
                      children: _viewModel.filterOptions.map((filter) {
                        final isSelected = _viewModel.selectedFilter == filter;
                        final count = _viewModel.getFilterPhotoCount(filter);

                        return Padding(
                          padding: const EdgeInsets.only(right: AppTheme.spacingM),
                          child: GestureDetector(
                            onTap: () => _viewModel.setFilter(filter),
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
                                      color: AppTheme.primary,
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

                  // Photos Grid
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
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridColumnCount,
                                    mainAxisSpacing: AppTheme.spacingS,
                                    crossAxisSpacing: AppTheme.spacingS,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: filteredPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = filteredPhotos[index];
                                final isFavorite = _viewModel.isFavorite(photo);
                                final isSelected = _viewModel.isSelected(photo);
                                
                                return Builder(
                                  builder: (itemContext) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (_viewModel.isSelectionMode) {
                                          _viewModel.togglePhotoSelection(photo);
                                        } else {
                                          _showPhotoDetail(index);
                                        }
                                      },
                                      onLongPress: () {
                                        setState(() {
                                          _isDragSelecting = true;
                                        });
                                        _viewModel.enableSelectionMode();
                                        _viewModel.togglePhotoSelection(photo);
                                      },
                                      onLongPressMoveUpdate: (details) {
                                        if (_viewModel.isSelectionMode && _isDragSelecting) {
                                          final RenderBox? scaffoldBox = Scaffold.of(context).context.findRenderObject() as RenderBox?;
                                          if (scaffoldBox == null) return;
                                          
                                          final localPosition = scaffoldBox.globalToLocal(details.globalPosition);
                                          
                                          final screenWidth = MediaQuery.of(context).size.width;
                                          final itemWidth = (screenWidth - (AppTheme.spacingL * 2) - (AppTheme.spacingS * (_gridColumnCount - 1))) / _gridColumnCount;
                                          final itemHeight = itemWidth;
                                          
                                          final gridStartY = kToolbarHeight + 
                                                            MediaQuery.of(context).padding.top + 
                                                            120;
                                          
                                          final adjustedY = localPosition.dy - gridStartY;
                                          
                                          final col = ((localPosition.dx - AppTheme.spacingL) / (itemWidth + AppTheme.spacingS)).floor().clamp(0, _gridColumnCount - 1);
                                          final row = ((adjustedY - AppTheme.spacingL) / (itemHeight + AppTheme.spacingS)).floor();
                                          final hoveredIndex = (row * _gridColumnCount + col).clamp(0, filteredPhotos.length - 1);
                                          
                                          if (hoveredIndex >= 0 && hoveredIndex < filteredPhotos.length) {
                                            if (!_viewModel.isSelected(filteredPhotos[hoveredIndex])) {
                                              _viewModel.togglePhotoSelection(filteredPhotos[hoveredIndex]);
                                            }
                                          }
                                        }
                                      },
                                      onLongPressEnd: (_) {
                                        setState(() {
                                          _isDragSelecting = false;
                                        });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              photo.thumbImage,
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
                                            if (_viewModel.isSelectionMode)
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.black.withOpacity(0.3)
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                            if (_viewModel.isSelectionMode)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppTheme.primary
                                                        : Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppTheme.primary
                                                          : Colors.grey[400]!,
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.2),
                                                        blurRadius: 3,
                                                        offset: const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: isSelected
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 12,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            if (!_viewModel.isSelectionMode)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _viewModel.toggleFavorite(photo);
                                                  },
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
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return _viewModel.isSelectionMode && _viewModel.selectedPhotos.isNotEmpty
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
                            icon: Icons.visibility_off_outlined,
                            label: context.tr('gallery.hide'),
                            onTap: _hideSelectedPhotos,
                            color: AppTheme.primary
                            ,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _showPhotoDetail(int index) {
    final filteredPhotos = _viewModel.filteredPhotos;
    final middlePhotos = filteredPhotos.map((p) => p.middleImage).toList();
    final mainPhotos = filteredPhotos.map((p) => p.mainImage).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoDetailScreen(
          photos: middlePhotos,
          mainPhotos: mainPhotos,
          initialIndex: index,
          onFavoriteToggle: (photoIndex) {
            final photo = filteredPhotos[photoIndex];
            _viewModel.toggleFavorite(photo);
          },
          onHideToggle: (photoIndex) {
            final photo = filteredPhotos[photoIndex];
            _viewModel.toggleHidden(photo);
          },
          isFavorite: (photoIndex) {
            final photo = filteredPhotos[photoIndex];
            return _viewModel.isFavorite(photo);
          },
        ),
      ),
    );
  }
}

class _PhotoDetailScreen extends StatefulWidget {
  final List<String> photos;
  final List<String> mainPhotos;
  final int initialIndex;
  final Function(int) onFavoriteToggle;
  final Function(int) onHideToggle;
  final bool Function(int) isFavorite;

  const _PhotoDetailScreen({
    required this.photos,
    required this.mainPhotos,
    required this.initialIndex,
    required this.onFavoriteToggle,
    required this.onHideToggle,
    required this.isFavorite,
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

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
                        label: context.tr('gallery.hide'),
                        onTap: () {
                          widget.onHideToggle(_currentIndex);
                          Navigator.pop(context);
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.info_outline_rounded,
                        label: context.tr('gallery.info'),
                        onTap: _showPhotoInfo,
                      ),
                      _PhotoActionIconButton(
                        icon: widget.isFavorite(_currentIndex) 
                            ? Icons.star 
                            : Icons.star_outline,
                        label: context.tr('gallery.favorite'),
                        onTap: () {
                          widget.onFavoriteToggle(_currentIndex);
                          setState(() {});
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.share_rounded,
                        label: context.tr('gallery.share'),
                        onTap: _sharePhoto,
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.download_rounded,
                        label: context.tr('gallery.download'),
                        onTap: _downloadPhoto,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

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
      final currentPhotoUrl = widget.mainPhotos[_currentIndex];
      final success = await PhotoService.downloadPhoto(currentPhotoUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? context.tr('gallery.photo_saved') : context.tr('gallery.photo_save_error')),
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
      final currentPhotoUrl = widget.mainPhotos[_currentIndex];
      
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
            content: Text(context.tr('gallery.share_error', args: {'error': e.toString()})),
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
              Text(
                context.tr('gallery.photo_info_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.image_outlined,
                label: context.tr('gallery.photo_info_photo'),
                value: context.tr('gallery.photo_count_format', args: {'current': (_currentIndex + 1).toString(), 'total': widget.photos.length.toString()}),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

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

class _PhotoActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
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
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
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
