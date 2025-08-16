import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_local_repository.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';

class AuthDebugUtils {
  static Future<void> debugAuthState(WidgetRef ref) async {
    print("🔍 === AUTH DEBUG START ===");
    
    // Check current user state
    final currentUser = ref.read(authViewModelProvider);
    print("👤 Current user in state: ${currentUser != null ? 'Yes' : 'No'}");
    if (currentUser != null) {
      print("   - ID: '${currentUser.id}'");
      print("   - Name: '${currentUser.name}'");
      print("   - Email: '${currentUser.email}'");
      print("   - Access Token: '${currentUser.accessToken}'");
      print("   - Access Token Length: ${currentUser.accessToken.length}");
      print("   - Refresh Token: '${currentUser.refreshToken ?? 'null'}'");
    }
    
    // Check stored tokens
    final authRepo = ref.read(authLocalRepositoryProvider);
    final storedUser = await authRepo.getUser();
    final storedAccessToken = await authRepo.getAccessToken();
    final storedRefreshToken = await authRepo.getRefreshToken();
    
    print("💾 Stored user: ${storedUser != null ? 'Yes' : 'No'}");
    if (storedUser != null) {
      print("   - Stored User ID: '${storedUser.id}'");
      print("   - Stored User Name: '${storedUser.name}'");
      print("   - Stored User Email: '${storedUser.email}'");
      print("   - Stored User Access Token: '${storedUser.accessToken}'");
    }
    
    print("🔑 Stored Access Token: '${storedAccessToken ?? 'null'}'");
    print("🔑 Stored Access Token Length: ${storedAccessToken?.length ?? 0}");
    print("🔑 Stored Refresh Token: '${storedRefreshToken ?? 'null'}'");
    print("🔑 Stored Refresh Token Length: ${storedRefreshToken?.length ?? 0}");
    
    print("🔍 === AUTH DEBUG END ===");
  }
}