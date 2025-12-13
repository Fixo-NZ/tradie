import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/license_upload_api_service.dart';

class LicenseFile {
  final String name;
  final String path;
  final String type; // 'license' or 'id'

  LicenseFile({
    required this.name,
    required this.path,
    required this.type,
  });
}

class LicenseUploadState {
  final List<LicenseFile> licenseFiles;
  final List<LicenseFile> idFiles;
  final bool isLoading;
  final String? errorMessage;

  const LicenseUploadState({
    this.licenseFiles = const [],
    this.idFiles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LicenseUploadState copyWith({
    List<LicenseFile>? licenseFiles,
    List<LicenseFile>? idFiles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LicenseUploadState(
      licenseFiles: licenseFiles ?? this.licenseFiles,
      idFiles: idFiles ?? this.idFiles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LicenseUploadViewModel extends StateNotifier<LicenseUploadState> {
  LicenseUploadViewModel() : super(const LicenseUploadState());

  void addLicenseFile(String name, String path) {
    final newFile = LicenseFile(name: name, path: path, type: 'license');
    final updated = [...state.licenseFiles, newFile];
    state = state.copyWith(licenseFiles: updated);
  }

  void removeLicenseFile(int index) {
    if (index >= 0 && index < state.licenseFiles.length) {
      final updated = [...state.licenseFiles]..removeAt(index);
      state = state.copyWith(licenseFiles: updated);
    }
  }

  void addIdFile(String name, String path) {
    final newFile = LicenseFile(name: name, path: path, type: 'id');
    final updated = [...state.idFiles, newFile];
    state = state.copyWith(idFiles: updated);
  }

  void removeIdFile(int index) {
    if (index >= 0 && index < state.idFiles.length) {
      final updated = [...state.idFiles]..removeAt(index);
      state = state.copyWith(idFiles: updated);
    }
  }

  Future<bool> submitLicenseFiles() async {
    if (licenseFiles.isEmpty || idFiles.isEmpty) {
      state = state.copyWith(errorMessage: 'Please upload all required documents');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    print('📋 submitLicenseFiles: uploading ${licenseFiles.length} licenses + ${idFiles.length} IDs');
    try {
      final api = LicenseUploadApiService();

      // Convert stored paths to File objects
      final licenseFileObjs = licenseFiles.map((f) => File(f.path)).toList();
      final idFileObjs = idFiles.map((f) => File(f.path)).toList();

      final result = await api.submitLicenseDocuments(
        licenseFiles: licenseFileObjs,
        idFiles: idFileObjs,
      );

      print('📋 submitLicenseFiles result: $result');

      state = state.copyWith(isLoading: false);

      if (result['success'] == true) {
        print('All files uploaded successfully');
        return true;
      } else {
        // Extract error message from response body if available
        String errorMsg = 'Failed to upload documents';
        
        final body = result['body'];
        final statusCode = result['statusCode'] ?? 0;
        
        // Try to extract message from parsed JSON response
        if (body is Map) {
          if (body.containsKey('message')) {
            errorMsg = body['message'].toString();
          } else if (body.containsKey('error')) {
            errorMsg = body['error'].toString();
          }
        }
        
        // Add status code for debugging
        if (statusCode == 401) {
          errorMsg = 'Unauthorized - please log in again';
        } else if (statusCode == 422) {
          errorMsg = 'Validation error - check file format and size';
        } else if (statusCode >= 400) {
          errorMsg = 'Server error: $statusCode - ${result['error'] ?? errorMsg}';
        }
        
        print('Upload failed: $errorMsg');
        state = state.copyWith(
          errorMessage: errorMsg,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload documents: ${e.toString()}',
      );
      return false;
    }
  }

  List<LicenseFile> get licenseFiles => state.licenseFiles;
  List<LicenseFile> get idFiles => state.idFiles;
}

final licenseUploadViewModelProvider =
    StateNotifierProvider<LicenseUploadViewModel, LicenseUploadState>((ref) {
  return LicenseUploadViewModel();
});
