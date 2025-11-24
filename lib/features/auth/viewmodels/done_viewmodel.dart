import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/done_api_service.dart';

class DoneViewModel extends StateNotifier<DoneState> {
  final DoneApiService _apiService = DoneApiService();

  DoneViewModel() : super(DoneState()) {
    loadProfile();
  }

  void updateSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true);

      // ✅ Fetch profile data (Laravel returns nested JSON)
      final data = await _apiService.fetchProfile();
      final profileData = data['data'] is Map ? data['data'] : data;

      state = state.copyWith(
        firstName: profileData['first_name'],
        lastName: profileData['last_name'],
        email: profileData['email'],
        bio: profileData['bio'],
        businessName: profileData['business_name'],
        phone: profileData['phone'],
        // ✅ Laravel may return either 'avatar' (path) or 'avatar_url' (full URL)
        avatar: profileData['avatar'] ?? profileData['avatar_url'],
      );

      // ✅ Fetch and map skills
      final List<dynamic> skillsData = await _apiService.fetchSkills();
      final Map<int, String> skillsMap = {
        1: 'Painting',
        2: 'Electrical',
        3: 'Carpentry',
        4: 'Pest Control',
        5: 'Plumbing',
        6: 'Cleaning',
        7: 'Masonry',
        8: 'Landscaping',
        9: 'Repair',
        10: 'Aircon Service',
        11: 'Locksmith',
      };

      final List<String> skillStrings = skillsData
          .map((skill) =>
              skillsMap[int.tryParse(skill.toString())] ?? skill.toString())
          .toList();

      state = state.copyWith(
        skills: skillStrings,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      print('❌ Error loading profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile data',
      );
    }
  }
}

class DoneState {
  final int selectedTabIndex;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? bio;
  final String? businessName;
  final String? phone;
  final String? avatar;
  final List<String> skills;
  final bool isLoading;
  final String? error;

  DoneState({
    this.selectedTabIndex = 0,
    this.firstName,
    this.lastName,
    this.email,
    this.bio,
    this.businessName,
    this.phone,
    this.avatar,
    this.skills = const [],
    this.isLoading = false,
    this.error,
  });

  DoneState copyWith({
    int? selectedTabIndex,
    String? firstName,
    String? lastName,
    String? email,
    String? bio,
    String? businessName,
    String? phone,
    String? avatar,
    List<String>? skills,
    bool? isLoading,
    String? error,
  }) {
    return DoneState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      skills: skills ?? this.skills,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
