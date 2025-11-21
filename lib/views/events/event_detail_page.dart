import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/photo_service.dart';
import 'package:pixlomi/viewmodels/event_detail_viewmodel.dart';
import 'package:pixlomi/localizations/app_localizations.dart';
import 'package:pixlomi/models/event_models.dart';

class EventDetailPage extends StatefulWidget {
  final int? eventID;
  final String? eventCode;

  const EventDetailPage({
    Key? key,
    this.eventID,
    this.eventCode,
  }) : assert(eventID != null || eventCode != null, 'Either eventID or eventCode must be provided'),
       super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final EventDetailViewModel _viewModel;
  bool _isInfoExpanded = false;
  bool _isDragSelecting = false;

  @override
  void initState() {
    super.initState();
    _viewModel = EventDetailViewModel();
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    if (widget.eventID != null) {
      await _viewModel.fetchEventDetailById(widget.eventID!);
    } else if (widget.eventCode != null) {
      await _viewModel.fetchEventDetailByCode(widget.eventCode!);
    }
    
    if (mounted && _viewModel.errorMessage != null) {
      _showSnackBar(_viewModel.errorMessage!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

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
          context.tr('event_detail.title'),
          style: AppTheme.labelLarge,
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              _viewModel.setGridColumnCount(value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _viewModel.gridColumnCount == 3 ? AppTheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.grid_3x3_rounded,
                        size: 20,
                        color: _viewModel.gridColumnCount == 3 ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(context.tr('event_detail.grid_3')),
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
                        color: _viewModel.gridColumnCount == 4 ? AppTheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.grid_4x4_rounded,
                        size: 20,
                        color: _viewModel.gridColumnCount == 4 ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(context.tr('event_detail.grid_4')),
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
                        color: _viewModel.gridColumnCount == 5 ? AppTheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.grid_on_rounded,
                        size: 20,
                        color: _viewModel.gridColumnCount == 5 ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(context.tr('event_detail.grid_5')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          // Loading state
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (_viewModel.eventDetail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    _viewModel.errorMessage ?? context.tr('events.no_events'),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),  
                  ElevatedButton(
                    onPressed: _loadEventDetail,
                    child: Text(context.tr('common.retry')),
                  ),
                ],
              ),
            );
          }

          final event = _viewModel.eventDetail!;
          final thumbPhotos = _viewModel.thumbPhotoUrls;

          return Column(
            children: [
              // Etkinlik Bilgileri - Accordion
              Container(
                margin: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                ),
                child: Column(
                  children: [
                    // Accordion Header
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isInfoExpanded = !_isInfoExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.eventTitle,
                                style: AppTheme.labelLarge.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              _isInfoExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Accordion Content
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isInfoExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: AppTheme.spacingL,
                                right: AppTheme.spacingL,
                                bottom: AppTheme.spacingL,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 1),
                                  const SizedBox(height: AppTheme.spacingM),
                                  Text(
                                    context.tr('event_detail.event_code'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.eventCode,
                                    style: AppTheme.bodySmall,
                                  ),
                                  const SizedBox(height: AppTheme.spacingM),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.tr('event_detail.start_date'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              event.eventStartDate,
                                              style: AppTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.tr('event_detail.end_date'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              event.eventEndDate,
                                              style: AppTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.spacingM),
                                  Text(
                                    context.tr('event_detail.location'),
                                    style: const TextStyle(
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
                                      Expanded(
                                        child: Text(
                                          event.eventLocation,
                                          style: AppTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
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
                      _viewModel.isSelectionMode
                          ? context.tr('event_detail.selected_count', args: {'count': _viewModel.selectedPhotos.length.toString()})
                          : context.tr('event_detail.photos_title', args: {'count': thumbPhotos.length.toString()}),
                      style: AppTheme.labelLarge,
                    ),
                    Row(
                      children: [
                        if (!_viewModel.isSelectionMode)
                          GestureDetector(
                            onTap: () {
                              _viewModel.enableSelectionMode();
                            },
                            child: Text(
                              context.tr('event_detail.button_select'),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (_viewModel.isSelectionMode)
                          GestureDetector(
                            onTap: () {
                              _viewModel.disableSelectionMode();
                            },
                            child: Text(
                              context.tr('event_detail.button_cancel'),
                              style: const TextStyle(
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
                child: thumbPhotos.isEmpty
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
                              context.tr('event_detail.no_photos'),
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
                          crossAxisCount: _viewModel.gridColumnCount,
                          crossAxisSpacing: AppTheme.spacingS,
                          mainAxisSpacing: AppTheme.spacingS,
                          childAspectRatio: 1,
                        ),
                        itemCount: thumbPhotos.length,
                        itemBuilder: (context, index) {
                          final isSelected = _viewModel.selectedPhotos.contains(index);
                          return Builder(
                            builder: (itemContext) {
                              return GestureDetector(
                                onTap: () {
                                  if (_viewModel.isSelectionMode) {
                                    _viewModel.togglePhotoSelection(index);
                                  } else {
                                    _showPhotoDetail(index);
                                  }
                                },
                                onLongPress: () {
                                  setState(() {
                                    _isDragSelecting = true;
                                  });
                                  _viewModel.enableSelectionMode();
                                  _viewModel.togglePhotoSelection(index);
                                },
                                onLongPressMoveUpdate: (details) {
                                  if (_viewModel.isSelectionMode && _isDragSelecting) {
                                    // Scaffold'un RenderBox'ını al
                                    final RenderBox? scaffoldBox = Scaffold.of(context).context.findRenderObject() as RenderBox?;
                                    if (scaffoldBox == null) return;
                                    
                                    // Global pozisyonu scaffold koordinatlarına çevir
                                    final localPosition = scaffoldBox.globalToLocal(details.globalPosition);
                                    
                                    // Grid içindeki pozisyonu hesapla
                                    final screenWidth = MediaQuery.of(context).size.width;
                                    final itemWidth = (screenWidth - (AppTheme.spacingL * 2) - (AppTheme.spacingS * (_viewModel.gridColumnCount - 1))) / _viewModel.gridColumnCount;
                                    final itemHeight = itemWidth;
                                    
                                    // Grid'in başlangıç pozisyonunu hesaba kat (AppBar + Info Card + Header)
                                    final gridStartY = AppBar().preferredSize.height + 
                                                      MediaQuery.of(context).padding.top + 
                                                      100; // Yaklaşık info card + header yüksekliği
                                    
                                    final adjustedY = localPosition.dy - gridStartY;
                                    
                                    final col = ((localPosition.dx - AppTheme.spacingL) / (itemWidth + AppTheme.spacingS)).floor().clamp(0, _viewModel.gridColumnCount - 1);
                                    final row = ((adjustedY - AppTheme.spacingL) / (itemHeight + AppTheme.spacingS)).floor();
                                    final hoveredIndex = (row * _viewModel.gridColumnCount + col).clamp(0, thumbPhotos.length - 1);
                                    
                                    if (hoveredIndex >= 0 && hoveredIndex < thumbPhotos.length) {
                                      if (!_viewModel.selectedPhotos.contains(hoveredIndex)) {
                                        _viewModel.togglePhotoSelection(hoveredIndex);
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
                                    thumbPhotos[index],
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
                                  if (_viewModel.isSelectionMode)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.black.withOpacity(0.3)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  // Seçim checkbox'ı
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
                                ],
                              ),
                            ),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Alt Buton / Seçim Aksiyon Barı
              if (!_viewModel.isSelectionMode)
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
                        child: Text(
                          context.tr('event_detail.button_download_all'),
                          style: const TextStyle(
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
                                  _viewModel.selectAllPhotos();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: Text(
                                      _viewModel.selectedPhotos.length == _viewModel.eventDetail!.images.length
                                          ? context.tr('event_detail.button_deselect_all')
                                          : context.tr('event_detail.button_select_all'),
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
                          child: ElevatedButton.icon(
                            onPressed: _downloadSelectedPhotos,
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: Text(context.tr('event_detail.button_download'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        // Paylaş butonu
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareSelectedPhotos,
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: Text(context.tr('event_detail.button_share'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        // Sil butonu
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _deleteSelectedPhotos,
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            label: Text(context.tr('event_detail.action_hide'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showPhotoDetail(int index) {
    final images = _viewModel.images;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoDetailScreen(
          photos: images,
          initialIndex: index,
          onDelete: (photoIndex) {
            _confirmDelete(photoIndex);
          },
          onFavoriteToggle: (photoIndex) {
            _viewModel.toggleFavorite(photoIndex);
          },
          isFavorite: (photoIndex) {
            return _viewModel.isFavorite(photoIndex);
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
          title: Text(context.tr('event_detail.delete_photo_title')),
          content: Text(context.tr('event_detail.delete_photo_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('common.cancel')),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement delete API
                Navigator.pop(context);
                _showSnackBar(context.tr('event_detail.photo_deleted'));
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: Text(context.tr('common.delete')),
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
                        ? context.tr('event_detail.download_success', args: {'count': successCount.toString()})
                        : successCount > 0
                            ? context.tr('event_detail.download_partial_success', args: {'success': successCount.toString(), 'total': photoUrls.length.toString()})
                            : context.tr('event_detail.download_error'),
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
    final photos = _viewModel.mainPhotoUrls;
    if (photos.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(context.tr('event_detail.download_confirm_title')),
          content: Text(
            context.tr('event_detail.download_confirm_message', args: {'count': photos.length.toString()}),
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
                        Text(context.tr('event_detail.downloading', args: {'count': photos.length.toString()})),
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
                _downloadInBackground(photos);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.tr('event_detail.button_download'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _downloadSelectedPhotos() {
    final selectedPhotos = _viewModel.selectedPhotos;
    final mainPhotos = _viewModel.mainPhotoUrls;
    
    if (selectedPhotos.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(context.tr('event_detail.download_selected_title')),
          content: Text(
            context.tr('event_detail.download_selected_message', args: {'count': selectedPhotos.length.toString()}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                
                // Seçili fotoğrafların URL'lerini al (MAIN kalite)
                final selectedUrls = selectedPhotos.map((index) => mainPhotos[index]).toList();
                
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
                        Text(context.tr('event_detail.downloading', args: {'count': selectedPhotos.length.toString()})),
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
                _viewModel.disableSelectionMode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.tr('event_detail.button_download'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _shareSelectedPhotos() {
    if (_viewModel.selectedPhotos.isEmpty) return;
    
    _showSnackBar(context.tr('event_detail.downloading', args: {'count': _viewModel.selectedPhotos.length.toString()}));
  }

  void _deleteSelectedPhotos() {
    if (_viewModel.selectedPhotos.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(context.tr('event_detail.delete_confirm_title')),
          content: Text(
            context.tr('event_detail.delete_confirm_message', args: {'count': _viewModel.selectedPhotos.length.toString()}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('common.cancel')),
            ),
            TextButton(
              onPressed: () async {
                await _viewModel.deleteSelectedPhotos();
                Navigator.pop(context);
                _showSnackBar(context.tr('event_detail.delete_success'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.tr('common.delete'), style: const TextStyle(color: Colors.white)),
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
  final List<EventImage> photos;
  final int initialIndex;
  final Function(int) onDelete;
  final Function(int) onFavoriteToggle;
  final bool Function(int) isFavorite;

  const _PhotoDetailScreen({
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
    required this.onFavoriteToggle,
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

  void _hidePhoto() async {
    try {
      final photoIndex = _currentIndex;
      final currentPhoto = widget.photos[photoIndex];
      final photoID = currentPhoto.photoID;
      
      // UI'yı güncelle (optimistic update) - fotoğraf ekranında kal
      widget.onDelete(photoIndex);
      setState(() {}); // Label'ı güncellemek için
      
      // Arka planda API çağrısı yap
      await PhotoService.hidePhoto(photoID);
    } catch (e) {
      print('❌ Hide photo error: $e');
    }
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
                    widget.photos[index].middleImage,
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
                        label: context.tr('event_detail.action_hide'),
                        onTap: _hidePhoto,
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.info_outline_rounded,
                        label: context.tr('event_detail.action_info'),
                        onTap: () {
                          _showPhotoInfo();
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: widget.isFavorite(_currentIndex) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        label: context.tr('event_detail.action_favorite'),
                        onTap: () {
                          widget.onFavoriteToggle(_currentIndex);
                          setState(() {});
                        },
                        color: widget.isFavorite(_currentIndex) ? const Color(0xFFFFB800) : null,
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.share_rounded,
                        label: context.tr('event_detail.action_share'),
                        onTap: () {
                          _sharePhoto();
                        },
                      ),
                      _PhotoActionIconButton(
                        icon: Icons.download_rounded,
                        label: context.tr('event_detail.action_download'),
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
                            widget.photos[index].thumbImage,
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
      // İndirme için MAIN kalite kullan
      final currentPhoto = widget.photos[_currentIndex];
      final success = await PhotoService.downloadPhoto(currentPhoto.mainImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? context.tr('event_detail.photo_saved') : context.tr('event_detail.photo_save_error')),
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
      // Paylaşım için MAIN kalite kullan
      final currentPhoto = widget.photos[_currentIndex];
      
      // iOS için share position
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      
      await PhotoService.sharePhoto(
        currentPhoto.mainImage,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('event_detail.share_error', args: {'error': e.toString()})),
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
                context.tr('event_detail.photo_info_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.image_outlined,
                label: context.tr('event_detail.photo_info_photo'),
                value: context.tr('event_detail.photo_count_format', args: {'current': (_currentIndex + 1).toString(), 'total': widget.photos.length.toString()}),
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
    // ignore: unused_element_parameter
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
