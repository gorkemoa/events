import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/views/gallery/photo_detail_page.dart';
import 'package:pixlomi/widgets/home_header.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedFilter = 'Tümü';
  final Set<String> _favorites = {};
  
  // Sample photos data - çekilen fotoğraflar
  final List<Map<String, dynamic>> photos = [
    {
      'id': '1',
      'url': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=500&fit=crop',
      'title': 'Kahve Festivali Stand',
      'date': '5 Kasım 2025',
      'time': '10:30',
      'category': 'Business',
      'event': 'Kahve Festivali 2025',
    },
    {
      'id': '2',
      'url': 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400&h=300&fit=crop',
      'title': 'Barista Yarışması',
      'date': '5 Kasım 2025',
      'time': '14:00',
      'category': 'Business',
      'event': 'Kahve Festivali 2025',
    },
    {
      'id': '3',
      'url': 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=400&h=400&fit=crop',
      'title': 'Ticari Fuarı',
      'date': '3 Kasım 2025',
      'time': '09:15',
      'category': 'Business',
      'event': 'İnsan Kaynakları Konferansı',
    },
    {
      'id': '4',
      'url': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=500&fit=crop',
      'title': 'Kurumsal Etkinlik',
      'date': '2 Kasım 2025',
      'time': '18:00',
      'category': 'Business',
      'event': 'Yıllık Gala Akşamı',
    },
    {
      'id': '5',
      'url': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'title': 'Ağ Oluşturma Etkinliği',
      'date': '1 Kasım 2025',
      'time': '17:30',
      'category': 'Business',
      'event': 'Girişimci Forumu',
    },
    {
      'id': '6',
      'url': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=350&fit=crop',
      'title': 'Seminer Sunumu',
      'date': '31 Ekim 2025',
      'time': '11:00',
      'category': 'Business',
      'event': 'Teknoloji Zirvesi',
    },
    {
      'id': '7',
      'url': 'https://images.unsplash.com/photo-1517457373614-b7152f800fd1?w=400&h=500&fit=crop',
      'title': 'Başarı Ödülü Töreni',
      'date': '30 Ekim 2025',
      'time': '19:00',
      'category': 'Business',
      'event': 'Işletme Ödül Törenı',
    },
    {
      'id': '8',
      'url': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'title': 'Ticari Ortaklık İmza',
      'date': '29 Ekim 2025',
      'time': '15:45',
      'category': 'Business',
      'event': 'İş Geliştirme Toplantısı',
    },
    {
      'id': '9',
      'url': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=500&fit=crop',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            HomeHeader(
              locationText: 'Fotoğraflar',
              subtitle: '${photos.length} fotoğraf',
              onMenuPressed: () {
                // Menu action
              },
              onNotificationPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bildirimler'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            // Etkinliklere göre Filter - Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
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
                          return _PhotoTile(
                            imageUrl: photo['url'],
                            isFavorite: isFavorite,
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
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _PhotoTile({
    required this.imageUrl,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
            // Favori butonu
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
                    color: isFavorite ? const Color(0xFFFFB800) : Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
