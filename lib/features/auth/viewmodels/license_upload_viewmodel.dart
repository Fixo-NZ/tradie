import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    
    try {
      // Simulate API call - integrate with your actual API service
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload documents',
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
