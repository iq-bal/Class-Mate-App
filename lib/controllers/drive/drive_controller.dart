import 'package:flutter/foundation.dart';
import 'package:classmate/services/drive/drive_services.dart';
import 'package:classmate/models/drive/drive_model.dart';
import 'package:classmate/entity/drive_file_entity.dart';
import 'dart:io';

enum DriveState {
  initial,
  loading,
  loaded,
  uploading,
  uploaded,
  error,
}

class DriveController {
  final DriveServices _driveServices = DriveServices();
  
  final ValueNotifier<DriveState> _stateNotifier = ValueNotifier(DriveState.initial);
  final ValueNotifier<List<DriveFileEntity>> _filesNotifier = ValueNotifier([]);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isUploadingNotifier = ValueNotifier(false);

  ValueNotifier<DriveState> get stateNotifier => _stateNotifier;
  ValueNotifier<List<DriveFileEntity>> get filesNotifier => _filesNotifier;
  ValueNotifier<String?> get errorNotifier => _errorNotifier;
  ValueNotifier<bool> get isUploadingNotifier => _isUploadingNotifier;

  List<DriveFileEntity> get files => _filesNotifier.value;
  DriveState get state => _stateNotifier.value;
  String? get error => _errorNotifier.value;
  bool get isUploading => _isUploadingNotifier.value;

  // Fetch drive files for a specific course
  Future<void> fetchDriveFiles(String courseId) async {
    try {
      _stateNotifier.value = DriveState.loading;
      _errorNotifier.value = null;

      final driveModel = await _driveServices.getDriveFilesByCourse(courseId);
      
      _filesNotifier.value = driveModel.files;
      _stateNotifier.value = DriveState.loaded;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = DriveState.error;
      if (kDebugMode) {
        print('Error fetching drive files: $e');
      }
    }
  }

  // Upload a file to a course
  Future<bool> uploadFile({
    required String courseId,
    required File file,
    String? description,
  }) async {
    try {
      _isUploadingNotifier.value = true;
      _stateNotifier.value = DriveState.uploading;
      _errorNotifier.value = null;

      final uploadResult = await _driveServices.uploadDriveFile(
        courseId: courseId,
        file: file,
        description: description,
      );

      // Add the new file to the current list
      final currentFiles = List<DriveFileEntity>.from(_filesNotifier.value);
      currentFiles.insert(0, uploadResult.file); // Add to beginning
      _filesNotifier.value = currentFiles;

      _stateNotifier.value = DriveState.uploaded;
      _isUploadingNotifier.value = false;
      
      return true;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = DriveState.error;
      _isUploadingNotifier.value = false;
      
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return false;
    }
  }

  // Clear error state
  void clearError() {
    _errorNotifier.value = null;
    if (_stateNotifier.value == DriveState.error) {
      _stateNotifier.value = DriveState.initial;
    }
  }

  // Reset controller state
  void reset() {
    _stateNotifier.value = DriveState.initial;
    _filesNotifier.value = [];
    _errorNotifier.value = null;
    _isUploadingNotifier.value = false;
  }

  // Dispose resources
  void dispose() {
    _stateNotifier.dispose();
    _filesNotifier.dispose();
    _errorNotifier.dispose();
    _isUploadingNotifier.dispose();
  }

  // Helper method to format file size
  String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  // Delete a file
  Future<bool> deleteFile(String fileId) async {
    try {
      _stateNotifier.value = DriveState.loading;
      _errorNotifier.value = null;

      final success = await _driveServices.deleteDriveFile(fileId);
      
      if (success) {
        // Remove the file from the current list
        final currentFiles = List<DriveFileEntity>.from(_filesNotifier.value);
        currentFiles.removeWhere((file) => file.id == fileId);
        _filesNotifier.value = currentFiles;
        
        _stateNotifier.value = DriveState.loaded;
        return true;
      } else {
        _errorNotifier.value = 'Failed to delete file';
        _stateNotifier.value = DriveState.error;
        return false;
      }
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = DriveState.error;
      
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }

  // Rename a file
  Future<bool> renameFile(String fileId, String newFileName) async {
    try {
      _stateNotifier.value = DriveState.loading;
      _errorNotifier.value = null;

      final updatedFile = await _driveServices.renameDriveFile(fileId, newFileName);
      
      // Update the file in the current list
      final currentFiles = List<DriveFileEntity>.from(_filesNotifier.value);
      final fileIndex = currentFiles.indexWhere((file) => file.id == fileId);
      
      if (fileIndex != -1) {
        currentFiles[fileIndex] = updatedFile;
        _filesNotifier.value = currentFiles;
      }
      
      _stateNotifier.value = DriveState.loaded;
      return true;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = DriveState.error;
      
      if (kDebugMode) {
        print('Error renaming file: $e');
      }
      return false;
    }
  }

  // Helper method to get file icon based on file type
  String getFileIcon(String? fileType) {
    if (fileType == null) return '📄';
    
    final type = fileType.toLowerCase();
    
    if (type.contains('pdf')) return '📄';
    if (type.contains('doc') || type.contains('docx')) return '📝';
    if (type.contains('xls') || type.contains('xlsx')) return '📊';
    if (type.contains('ppt') || type.contains('pptx')) return '📽️';
    if (type.contains('image') || type.contains('jpg') || type.contains('png') || type.contains('gif')) return '🖼️';
    if (type.contains('video') || type.contains('mp4') || type.contains('avi')) return '🎥';
    if (type.contains('audio') || type.contains('mp3') || type.contains('wav')) return '🎵';
    if (type.contains('zip') || type.contains('rar') || type.contains('7z')) return '🗜️';
    if (type.contains('text') || type.contains('txt')) return '📃';
    
    return '📄';
  }
}