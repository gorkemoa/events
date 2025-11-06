import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/views/gallery/photo_detail_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedFilter = 'Tümü';
  
  // Sample photos data - çekilen fotoğraflar
  final List<Map<String, dynamic>> photos = [
    {
      'id': '1',
      'url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=500&fit=crop',
      'title': 'Gün Batımı',
      'date': '5 Kasım 2025',
      'time': '18:45',
      'category': 'Doğa',
      'event': 'Fotoğraf Turu',
    },
    {
      'id': '2',
      'url': 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=400&h=300&fit=crop',
      'title': 'Deniz Manzarası',
      'date': '4 Kasım 2025',
      'time': '17:20',
      'category': 'Doğa',
      'event': 'Sahil Gezisi',
    },
    {
      'id': '3',
      'url': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
      'title': 'Müzik Festivali',
      'date': '3 Kasım 2025',
      'time': '22:15',
      'category': 'Etkinlikler',
      'event': 'Müzik Festivali',
    },
    {
      'id': '4',
      'url': 'https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=400&h=500&fit=crop',
      'title': 'Kent Hayatı',
      'date': '2 Kasım 2025',
      'time': '20:30',
      'category': 'Şehir',
      'event': 'Gece Fotoğrafçılığı',
    },
    {
      'id': '5',
      'url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
      'title': 'Resepsiyon',
      'date': '1 Kasım 2025',
      'time': '19:00',
      'category': 'Etkinlikler',
      'event': 'Resepsiyon',
    },
    {
      'id': '6',
      'url': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=350&fit=crop',
      'title': 'Doğa Yürüyüşü',
      'date': '31 Ekim 2025',
      'time': '09:45',
      'category': 'Doğa',
      'event': 'Doğa Yürüyüşü',
    },
    {
      'id': '7',
      'url': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=500&fit=crop',
      'title': 'Gece Hayatı',
      'date': '30 Ekim 2025',
      'time': '23:30',
      'category': 'Şehir',
      'event': 'Gece Kulübü',
    },
    {
      'id': '8',
      'url': 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=400&h=400&fit=crop',
      'title': 'Konser',
      'date': '29 Ekim 2025',
      'time': '21:00',
      'category': 'Etkinlikler',
      'event': 'Live Konser',
    },
    {
      'id': '9',
      'url': 'https://images.unsplash.com/photo-1504681869696-d977e713fada?w=400&h=500&fit=crop',
      'title': 'Gün Doğumu',
      'date': '28 Ekim 2025',
      'time': '06:30',
      'category': 'Doğa',
      'event': 'Sabah Fotoğrafçılığı',
    },
  ];

  List<Map<String, dynamic>> get filteredPhotos {
    if (_selectedFilter == 'Tümü') {
      return photos;
    }
    return photos.where((photo) => photo['event'] == _selectedFilter).toList();
  }

  List<String> get uniqueEvents {
    final events = photos.map((p) => p['event'] as String).toSet().toList();
    return ['Tümü', ...events];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fotoğraflar',
                        style: AppTheme.headingLarge,
                      ),
                      Text(
                        '${photos.length} fotoğraf',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download_rounded, size: 20),
                            SizedBox(width: 12),
                            Text('Tümünü İndir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.share_rounded, size: 20),
                            SizedBox(width: 12),
                            Text('Paylaş'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value == 'download' 
                            ? 'Fotoğraflar indiriliyor...' 
                            : 'Paylaşım seçenekleri açılıyor...'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Etkinliklere göre Filter - Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Row(
                children: uniqueEvents.map((event) {
                  final isSelected = _selectedFilter == event;
                  final count = event == 'Tümü' 
                    ? photos.length 
                    : photos.where((p) => p['event'] == event).length;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingM),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = event;
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
                        child: Text(
                          '$event ($count)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                              ? Colors.white 
                              : AppTheme.textPrimary,
                          ),
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
                          return _PhotoTile(
                            imageUrl: photo['url'],
                            onTap: () {
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
  }
}

class _PhotoTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            );
          },
        ),
      ),
    );
  }
}
