// widgets/chat_options_menu.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import '../models/user_action.dart';

class ChatOptionsMenu extends StatelessWidget {
  final Function(UserAction) onActionSelected;
  final String userName;

  const ChatOptionsMenu({
    super.key,
    required this.onActionSelected,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<UserAction>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 24,
      ),
      color: Color(0xFF3A3E7A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      onSelected: onActionSelected,
      itemBuilder: (context) => [
        _buildMenuItem(
          UserAction.viewProfile,
          Icons.person,
          'View Profile',
          Colors.white,
        ),
        _buildMenuItem(
          UserAction.muteChat,
          Icons.volume_off,
          'Mute Chat',
          Colors.white,
        ),
        PopupMenuDivider(height: 1),
        _buildMenuItem(
          UserAction.report,
          Icons.report,
          'Report User',
          Colors.orange,
        ),
        _buildMenuItem(
          UserAction.block,
          Icons.block,
          'Block User',
          Colors.red,
        ),
        _buildMenuItem(
          UserAction.deleteChat,
          Icons.delete,
          'Delete Chat',
          Colors.red,
        ),
      ],
    );
  }

  PopupMenuItem<UserAction> _buildMenuItem(
    UserAction action,
    IconData icon,
    String title,
    Color color,
  ) {
    return PopupMenuItem<UserAction>(
      value: action,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}