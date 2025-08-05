// import 'package:flutter/material.dart';
// import 'message_service.dart';

// class AppLifecycleService extends WidgetsBindingObserver {
//   static final AppLifecycleService _instance = AppLifecycleService._internal();
//   factory AppLifecycleService() => _instance;
//   AppLifecycleService._internal();

//   final MessageService _messageService = MessageService();
//   bool _isInitialized = false;

//   void initialize() {
//     if (!_isInitialized) {
//       WidgetsBinding.instance.addObserver(this);
//       _isInitialized = true;
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         _messageService.updateOnlineStatus(true);
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.detached:
//         _messageService.updateOnlineStatus(false);
//         break;
//     }
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//   }
// }
