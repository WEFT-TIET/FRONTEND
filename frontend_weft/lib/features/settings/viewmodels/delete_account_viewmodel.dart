import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/settings/services/delete_services.dart';
import 'package:frontend_weft/features/settings/models/delete_user_model.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';

final deleteAccountViewModelProvider = StateNotifierProvider<DeleteAccountViewModel, DeleteAccountState>((ref) {
  final deleteService = ref.watch(deleteServiceProvider);
  final authLocalRepository = ref.watch(authLocalRepositoryProvider);
  return DeleteAccountViewModel(deleteService, authLocalRepository);
});

class DeleteAccountState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  DeleteAccountState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class DeleteAccountViewModel extends StateNotifier<DeleteAccountState> {
  final DeleteService _deleteService;
  final AuthLocalRepository _authLocalRepository;

  DeleteAccountViewModel(this._deleteService, this._authLocalRepository) 
      : super(DeleteAccountState());

  Future<void> deleteAccount(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _deleteService.deleteAccount(email, password);
      
      if (response.success) {
        // Clear all local authentication data
        await _authLocalRepository.clearUser(); // This clears user, access token, and refresh token
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
          isLoading: false, 
          errorMessage: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Please check your connection and try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}