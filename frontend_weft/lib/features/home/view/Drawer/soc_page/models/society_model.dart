import 'package:flutter/material.dart';

class Society {
  final String id;
  final String name;
  final String fullName;
   final String instagramHandle;
  final IconData icon;
  //final String memberCount;
 
  final String description;

  Society({
    required this.id,
    required this.name,
    required this.fullName,
    required this.instagramHandle,
    required this.icon,
    //required this.memberCount,
    
    required this.description,
  });
}