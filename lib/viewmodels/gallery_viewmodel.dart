import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/event_models.dart';
import '../services/event_service.dart';
import '../services/storage_helper.dart';

/// ViewModel for Gallery Page
class GalleryViewModel extends ChangeNotifier {
  // State
  List<GalleryPhoto> _allPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter state
  String _selectedFilter = 'all';
  final Set<String> _favorites = {};
  final Set<String> _hiddenPhotos = {};
  
  // Selection mode state
  bool _isSelectionMode = false;
  final Set<String> _selectedPhotos = {};

  // Getters
  List<GalleryPhoto> get allPhotos => _allPhotos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  Set<String> get favorites => _favorites;
  Set<String> get hiddenPhotos => _hiddenPhotos;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedPhotos => _selectedPhotos;
  
  /// Get filtered photos based on current filter
  List<GalleryPhoto> get filteredPhotos {
    if (_selectedFilter == 'all') {
      return _allPhotos.where((photo) => !_hiddenPhotos.contains(_getPhotoId(photo))).toList();
    } else if (_selectedFilter == 'favorites') {
      return _allPhotos.where((photo) => 
        _favorites.contains(_getPhotoId(photo)) && 
        !_hiddenPhotos.contains(_getPhotoId(photo))
      ).toList();
    } else if (_selectedFilter == 'hidden') {
      return _allPhotos.where((photo) => _hiddenPhotos.contains(_getPhotoId(photo))).toList();
    }
    // Filter by event title
    return _allPhotos.where((photo) => 
      photo.eventTitle == _selectedFilter && 
      !_hiddenPhotos.contains(_getPhotoId(photo))
    ).toList();
  }
  
  /// Get unique event titles for filters
  List<String> get eventTitles {
    final titles = _allPhotos.map((p) => p.eventTitle).toSet().toList();
    return titles;
  }
  
  /// Get filter options (all, favorites, hidden, + event titles)
  List<String> get filterOptions {
    return ['all', 'favorites', 'hidden', ...eventTitles];
  }
  
  /// Get photo count for a specific filter
  int getFilterPhotoCount(String filter) {
    if (filter == 'all') {
      return _allPhotos.where((p) => !_hiddenPhotos.contains(_getPhotoId(p))).length;
    } else if (filter == 'favorites') {
      return _favorites.length;
    } else if (filter == 'hidden') {
      return _hiddenPhotos.length;
    } else {
      return _allPhotos.where((p) => 
        p.eventTitle == filter && 
        !_hiddenPhotos.contains(_getPhotoId(p))
      ).length;
    }
  }

  /// Fetch all user photos
  Future<void> fetchUserPhotos() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        _setError('Kullanıcı oturumu bulunamadı');
        return;
      }
      
      developer.log('Fetching user photos', name: 'GalleryViewModel');
      
      final response = await EventService.getUserPhotos(userToken);
      
      if (response != null && response.success) {
        _allPhotos = response.data.photos;
        developer.log(
          'User photos loaded: ${_allPhotos.length} photos',
          name: 'GalleryViewModel',
        );
      } else {
        _setError('Fotoğraflar yüklenemedi');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching user photos',
        name: 'GalleryViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set selected filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Toggle favorite
  void toggleFavorite(GalleryPhoto photo) {
    final photoId = _getPhotoId(photo);
    if (_favorites.contains(photoId)) {
      _favorites.remove(photoId);
    } else {
      _favorites.add(photoId);
    }
    notifyListeners();
  }

  /// Toggle hidden
  void toggleHidden(GalleryPhoto photo) {
    final photoId = _getPhotoId(photo);
    if (_hiddenPhotos.contains(photoId)) {
      _hiddenPhotos.remove(photoId);
    } else {
      _hiddenPhotos.add(photoId);
    }
    notifyListeners();
  }

  /// Check if photo is favorite
  bool isFavorite(GalleryPhoto photo) {
    return _favorites.contains(_getPhotoId(photo));
  }

  /// Check if photo is hidden
  bool isHidden(GalleryPhoto photo) {
    return _hiddenPhotos.contains(_getPhotoId(photo));
  }

  /// Toggle selection mode
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedPhotos.clear();
    }
    notifyListeners();
  }

  /// Enable selection mode
  void enableSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  /// Disable selection mode
  void disableSelectionMode() {
    _isSelectionMode = false;
    _selectedPhotos.clear();
    notifyListeners();
  }

  /// Toggle photo selection
  void togglePhotoSelection(GalleryPhoto photo) {
    final photoId = _getPhotoId(photo);
    if (_selectedPhotos.contains(photoId)) {
      _selectedPhotos.remove(photoId);
      // Auto-disable selection mode if no photos selected
      if (_selectedPhotos.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedPhotos.add(photoId);
    }
    notifyListeners();
  }

  /// Check if photo is selected
  bool isSelected(GalleryPhoto photo) {
    return _selectedPhotos.contains(_getPhotoId(photo));
  }

  /// Select all photos in current filter
  void selectAllPhotos() {
    if (_selectedPhotos.length == filteredPhotos.length) {
      _selectedPhotos.clear();
      _isSelectionMode = false;
    } else {
      _selectedPhotos.addAll(
        filteredPhotos.map((photo) => _getPhotoId(photo)),
      );
    }
    notifyListeners();
  }

  /// Get selected photo URLs for download/share
  List<String> getSelectedMainPhotoUrls() {
    return _allPhotos
        .where((photo) => _selectedPhotos.contains(_getPhotoId(photo)))
        .map((photo) => photo.mainImage)
        .toList();
  }

  /// Delete selected photos (placeholder - implement with API)
  Future<void> deleteSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) return;
    
    // TODO: Implement API call to delete photos
    developer.log('Deleting ${_selectedPhotos.length} photos', name: 'GalleryViewModel');
    
    // Remove from local list
    _allPhotos.removeWhere((photo) => _selectedPhotos.contains(_getPhotoId(photo)));
    
    // Clear selection
    _selectedPhotos.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Private helpers
  String _getPhotoId(GalleryPhoto photo) {
    // Use combination of eventID and image URL as unique ID
    return '${photo.eventID}_${photo.thumbImage}';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedPhotos.clear();
    _favorites.clear();
    _hiddenPhotos.clear();
    super.dispose();
  }
}
