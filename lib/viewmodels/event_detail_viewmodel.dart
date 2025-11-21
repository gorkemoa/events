import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/event_models.dart';
import '../services/event_service.dart';
import '../services/storage_helper.dart';

/// ViewModel for Event Detail Page
class EventDetailViewModel extends ChangeNotifier {
  // State
  EventDetail? _eventDetail;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Selection mode state
  bool _isSelectionMode = false;
  final Set<int> _selectedPhotos = {};
  
  // Grid column count
  int _gridColumnCount = 5;

  // Getters
  EventDetail? get eventDetail => _eventDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedPhotos => _selectedPhotos;
  int get gridColumnCount => _gridColumnCount;
  
  List<EventImage> get images {
    return _eventDetail?.images ?? [];
  }
  
  List<String> get photoUrls {
    return _eventDetail?.images.map((img) => img.middleImage).toList() ?? [];
  }
  
  List<String> get thumbPhotoUrls {
    return _eventDetail?.images.map((img) => img.thumbImage).toList() ?? [];
  }
  
  List<String> get mainPhotoUrls {
    return _eventDetail?.images.map((img) => img.mainImage).toList() ?? [];
  }

  /// Fetch event detail by ID
  Future<void> fetchEventDetailById(int eventID) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        _setError('Kullanıcı oturumu bulunamadı');
        return;
      }
      
      developer.log('Fetching event detail by ID: $eventID', name: 'EventDetailViewModel');
      
      final response = await EventService.getEventDetailById(eventID, userToken);
      
      if (response != null && response.success) {
        _eventDetail = response.data.event;
        developer.log(
          'Event detail loaded: ${_eventDetail!.eventTitle} with ${_eventDetail!.images.length} images',
          name: 'EventDetailViewModel',
        );
      } else {
        _setError('Etkinlik detayı yüklenemedi');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching event detail',
        name: 'EventDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch event detail by code
  Future<void> fetchEventDetailByCode(String eventCode) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        _setError('Kullanıcı oturumu bulunamadı');
        return;
      }
      
      developer.log('Fetching event detail by code: $eventCode', name: 'EventDetailViewModel');
      
      final response = await EventService.getEventDetailByCode(eventCode, userToken);
      
      if (response != null && response.success) {
        _eventDetail = response.data.event;
        developer.log(
          'Event detail loaded: ${_eventDetail!.eventTitle} with ${_eventDetail!.images.length} images',
          name: 'EventDetailViewModel',
        );
      } else {
        _setError('Etkinlik detayı yüklenemedi');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching event detail',
        name: 'EventDetailViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _setError('Bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
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
  void togglePhotoSelection(int index) {
    if (_selectedPhotos.contains(index)) {
      _selectedPhotos.remove(index);
      // Auto-disable selection mode if no photos selected
      if (_selectedPhotos.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedPhotos.add(index);
    }
    notifyListeners();
  }

  /// Select all photos
  void selectAllPhotos() {
    if (_eventDetail == null) return;
    
    if (_selectedPhotos.length == _eventDetail!.images.length) {
      _selectedPhotos.clear();
      _isSelectionMode = false;
    } else {
      _selectedPhotos.addAll(
        List.generate(_eventDetail!.images.length, (i) => i),
      );
    }
    notifyListeners();
  }

  /// Change grid column count
  void setGridColumnCount(int count) {
    _gridColumnCount = count;
    notifyListeners();
  }

  /// Delete selected photos (placeholder - implement with API)
  Future<void> deleteSelectedPhotos() async {
    if (_selectedPhotos.isEmpty) return;
    
    // TODO: Implement API call to delete photos
    developer.log('Deleting ${_selectedPhotos.length} photos', name: 'EventDetailViewModel');
    
    // For now, just clear selection
    _selectedPhotos.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Private helpers
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
    super.dispose();
  }
}
