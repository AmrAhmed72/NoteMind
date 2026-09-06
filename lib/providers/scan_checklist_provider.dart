import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/gemini_vision_service.dart';

enum ScanChecklistStatus { initial, imageSelected, processing, success, failure }

class ScanChecklistProvider extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final GeminiVisionService _geminiService = GeminiVisionService();

  ScanChecklistStatus _status = ScanChecklistStatus.initial;
  XFile? _image;
  Uint8List? _imageBytes;
  ScannedChecklist? _result;
  String? _errorMessage;

  ScanChecklistStatus get status => _status;
  XFile? get image => _image;
  Uint8List? get imageBytes => _imageBytes;
  ScannedChecklist? get result => _result;
  String? get errorMessage => _errorMessage;

  Future<void> selectImage(ImageSource source) async {
    try {
      _errorMessage = null;
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException('empty image');
      }
      _image = image;
      _imageBytes = bytes;
      _result = null;
      _status = ScanChecklistStatus.imageSelected;
      notifyListeners();
    } on PlatformException catch (error) {
      _setFailure(_permissionMessage(error));
    } catch (_) {
      _setFailure('Unable to open that image. Please choose another one.');
    }
  }

  Future<void> analyzeImage() async {
    final image = _image;
    final bytes = _imageBytes;
    if (image == null || bytes == null) {
      _setFailure('Select an image before analyzing it.');
      return;
    }

    _status = ScanChecklistStatus.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _geminiService.analyzeImage(
        bytes,
        mimeType: _mimeType(image.name),
      );
      _result = result;
      _status = ScanChecklistStatus.success;
      notifyListeners();
    } catch (error) {
      _setFailure(error.toString());
    }
  }

  void clearError() {
    _errorMessage = null;
    _status = _image == null
        ? ScanChecklistStatus.initial
        : ScanChecklistStatus.imageSelected;
    notifyListeners();
  }

  void _setFailure(String message) {
    _errorMessage = message;
    _status = ScanChecklistStatus.failure;
    notifyListeners();
  }

  String _permissionMessage(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('camera')) {
      return 'Camera permission was denied. Allow camera access in Settings and try again.';
    }
    if (code.contains('photo') || code.contains('gallery')) {
      return 'Gallery permission was denied. Allow photo access in Settings and try again.';
    }
    return 'Could not select an image. Please try again.';
  }

  String _mimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}