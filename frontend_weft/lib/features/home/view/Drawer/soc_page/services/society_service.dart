import 'package:flutter/material.dart';
import 'package:frontend_weft/features/home/view/Drawer/soc_page/model/society_model.dart';

class SocietyService {
  static List<Society> societies = [
    Society(
      id: 'frosh',
      name: 'FROSH',
      icon: Icons.people,
      description: 'Its basically a society which organise events for freshers. You can join it in second year',
    ),
    Society(
      id: 'mlsc',
      name: 'MLSC',
      icon: Icons.computer,
      description: 'Microsoft Learn Student Club - A technical society focused on Microsoft technologies, coding competitions, and skill development. We help students learn new technologies and build amazing projects.',
      
    ),
    Society(
      id: 'faps',
      name: 'FAPS',
      icon: Icons.people,
      description: 'A society which you can join if you have interest in painting and photography.',
      
    ),
    Society(
      id: 'mars',
      name: 'MARS',
       icon: Icons.people,
      description: 'Mechatronics and robotics society in which they will help you give understanding about how to robots and stuff.',
    ),
    Society(
      id: 'ccs',
      name: 'CCS',
      icon: Icons.computer,
      description: 'Technical society which organise coding competitions and help you in learning new technologies.',
      
    ),
  ];

  static Society? getSocietyById(String id) {
    try {
      return societies.firstWhere((society) => society.id == id);
    } catch (e) {
      return null;
    }
  }
}