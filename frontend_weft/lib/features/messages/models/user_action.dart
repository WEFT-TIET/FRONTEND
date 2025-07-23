// models/user_action.dart
enum UserAction {
  block,
  report,
  viewProfile,
  deleteChat,
  muteChat,
  unmuteChat,
}

class UserActionData {
  final UserAction action;
  final String userId;
  final String chatId;
  final String? reason;

  UserActionData({
    required this.action,
    required this.userId,
    required this.chatId,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action.toString().split('.').last,
      'userId': userId,
      'chatId': chatId,
      'reason': reason,
    };
  }
}