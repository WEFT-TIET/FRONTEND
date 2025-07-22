// import 'package:flutter/material.dart';
// import 'package:frontend_weft/core/theme/app_pallete.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'milan.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';






// class RegistrationPage extends StatefulWidget {
//   @override
//   _RegistrationPageState createState() => _RegistrationPageState();
// }

// class _RegistrationPageState extends State<RegistrationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _hobbiesController = TextEditingController();
  
//   File? _selectedImage;
//   Uint8List? _imageBytes;
//   DateTime? _selectedDate;
//   String _selectedGender = 'Male';
//   String _selectedSexuality = 'Straight';
  
//   final List<String> _genders = ['Male', 'Female', 'Non-binary', 'Other'];
//   final List<String> _sexualities = ['Straight'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppPallete.scaffoldBackgroundColorDark,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppPallete.scaffoldBackgroundColorDark,
//               AppPallete.gradient1,
//               AppPallete.gradient2,
//               AppPallete.gradient3,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Header
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 30),
//                     child: Column(
//                       children: [
//                         Text(
//                           " Welcome to Milan! ",
//                           style: TextStyle(
//                             color: AppPallete.textPrimaryDark,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             shadows: [
//                               Shadow(
//                                 blurRadius: 10,
//                                 color: AppPallete.secondaryDark.withOpacity(0.5),
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           " Create your perfect connecting profile ",
//                           style: TextStyle(
//                             color: AppPallete.profileTextSecondary,
//                             fontSize: 16,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Profile Picture Section
//                   _buildGlassContainer(
//                     child: Column(
//                       children: [
//                         Text(
//                           "📸 Your Picture",
//                           style: TextStyle(
//                             color: AppPallete.textPrimaryDark,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 15),
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: Container(
//                             width: 150,
//                             height: 150,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppPallete.glassWhite20,
//                                   AppPallete.glassWhite10,
//                                 ],
//                               ),
//                               border: Border.all(
//                                 color: AppPallete.glassWhite10,
//                                 width: 2,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppPallete.secondaryDark.withOpacity(0.3),
//                                   blurRadius: 15,
//                                   offset: Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: _imageBytes != null
//                                 ? ClipRRect(
//                                     borderRadius: BorderRadius.circular(75),
//                                     child: Image.memory(
//                                       _imageBytes!,
//                                       fit: BoxFit.cover,
//                                       width: 150,
//                                       height: 150,
//                                     ),
//                                   )
//                                 : Icon(
//                                     Icons.camera_alt,
//                                     size: 50,
//                                     color: AppPallete.profileTextSecondary,
//                                   ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           "Tap to add photo",
//                           style: TextStyle(
//                             color: AppPallete.profileTextSecondary,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Name Field
//                   _buildGlassContainer(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "💫 What's your name?",
//                           style: TextStyle(
//                             color: AppPallete.textPrimaryDark,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         _buildGlassTextField(
//                           controller: _nameController,
//                           hintText: "Enter your name",
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             return null;
//                           },
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Date of Birth
//                   _buildGlassContainer(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "🎂 When's your special day?",
//                           style: TextStyle(
//                             color: AppPallete.textPrimaryDark,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         GestureDetector(
//                           onTap: _selectDate,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppPallete.glassWhite10,
//                                   AppPallete.glassWhite05,
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: AppPallete.glassWhite10,
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   _selectedDate != null
//                                       ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
//                                       : "Select your birthday",
//                                   style: TextStyle(
//                                     color: _selectedDate != null
//                                         ? AppPallete.textPrimaryDark
//                                         : AppPallete.profileTextSecondary,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.calendar_today,
//                                   color: AppPallete.secondaryDark,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Gender and Sexuality Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildGlassContainer(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "🚹 Gender",
//                                 style: TextStyle(
//                                   color: AppPallete.textPrimaryDark,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                               _buildGlassDropdown(
//                                 value: _selectedGender,
//                                 items: _genders,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedGender = value!;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 15),
//                       Expanded(
//                         child: _buildGlassContainer(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Sexuality",
//                                 style: TextStyle(
//                                   color: AppPallete.textPrimaryDark,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                               _buildGlassDropdown(
//                                 value: _selectedSexuality,
//                                 items: _sexualities,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedSexuality = value!;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 20),

//                   // Hobbies
//                   _buildGlassContainer(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "🎨 Your Hobbies & Interests",
//                           style: TextStyle(
//                             color: AppPallete.textPrimaryDark,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         _buildGlassTextField(
//                           controller: _hobbiesController,
//                           hintText: "Dancing, Reading, Gaming, Cooking...",
//                           maxLines: 2,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please share your hobbies';
//                             }
//                             return null;
//                           },
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   // Description
//                   _buildGlassContainer(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "💭 Tell us about yourself",
//                           style: TextStyle(
//                             color: AppPallete.textPrimaryDark,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         _buildGlassTextField(
//                           controller: _descriptionController,
//                           hintText: "Share something interesting about yourself...",
//                           maxLines: 3,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please write a short description';
//                             }
//                             return null;
//                           },
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 30),

//                   // Submit Button
//                   Container(
//                     width: double.infinity,
//                     height: 55,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           AppPallete.secondaryDark,
//                           AppPallete.primaryDark,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppPallete.secondaryDark.withOpacity(0.4),
//                           blurRadius: 15,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: ElevatedButton(
//                       onPressed: _submitRegistration,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: Text(
//                         " Start connecting",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGlassContainer({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppPallete.glassWhite10,
//             AppPallete.glassWhite05,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: AppPallete.glassWhite10,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppPallete.primaryDark.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _buildGlassTextField({
//     required TextEditingController controller,
//     required String hintText,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       validator: validator,
//       style: TextStyle(
//         color: AppPallete.textPrimaryDark,
//         fontSize: 16,
//       ),
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: TextStyle(
//           color: AppPallete.profileTextSecondary,
//           fontSize: 16,
//         ),
//         filled: true,
//         fillColor: AppPallete.glassWhite10,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(
//             color: AppPallete.glassWhite10,
//             width: 1,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(
//             color: AppPallete.glassWhite10,
//             width: 1,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(
//             color: AppPallete.secondaryDark,
//             width: 2,
//           ),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }

//   Widget _buildGlassDropdown({
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppPallete.glassWhite10,
//             AppPallete.glassWhite05,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: AppPallete.glassWhite10,
//           width: 1,
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           onChanged: onChanged,
//           dropdownColor: AppPallete.cardColorDark,
//           style: TextStyle(
//             color: AppPallete.textPrimaryDark,
//             fontSize: 16,
//           ),
//           icon: Icon(
//             Icons.arrow_drop_down,
//             color: AppPallete.secondaryDark,
//           ),
//           items: items.map((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(item),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
//     if (image != null) {
//       // Read image bytes for web compatibility
//       final Uint8List imageBytes = await image.readAsBytes();
//       setState(() {
//         _imageBytes = imageBytes;
//         if (!kIsWeb) {
//           _selectedImage = File(image.path);
//         }
//       });
//     }
//   }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(Duration(days: 6570)), // 18 years ago
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: AppPallete.secondaryDark,
//               onPrimary: Colors.white,
//               surface: AppPallete.cardColorDark,
//               onSurface: AppPallete.textPrimaryDark,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
    
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }



//   Future<void> fetchImageDirectly(String imageUrl) async {
//     final response = await http.get(
//       Uri.parse(imageUrl),
//       headers: {
//         'Access-Control-Allow-Origin': '*',
//       },
//     );

//     print(response.statusCode);
//   }


//   Future<String?> uploadToCloudinary({File? file, Uint8List? bytes}) async {

//     const cloudName = 'dcp9mr9st'; // 🔁 Replace with your actual Cloudinary cloud name
//     const uploadPreset = 'ml_default'; // 🔁 Use your unsigned upload preset

//     try {
//       Uint8List imageBytes;
//       if (kIsWeb && bytes != null) {
//         imageBytes = bytes;
//       } else if (file != null) {
//         imageBytes = await file.readAsBytes();
//       } else {
//         print('No image to upload');
//         return null;
//       }

//       final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

//       final response = await http.post(
//         uri,
//         body: {
//           'file': 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
//           'upload_preset': uploadPreset,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['secure_url']; // ✅ Public image URL
//       } else {
//         print('Cloudinary upload failed: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error uploading to Cloudinary: $e');
//       return null;
//     }
//   }

//   void _showLoadingDialog(BuildContext context) {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//   }


//   Future<void> _submitRegistration() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please complete all required fields')),
//       );
//       return;
//     }

//     if (_imageBytes == null && _selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a profile photo')),
//       );
//       return;
//     }

//     try {
//       _showLoadingDialog(context); // 🌀 Show modal loading

//       final imageUrl = await uploadToCloudinary(
//         file: !kIsWeb ? _selectedImage : null,
//         bytes: kIsWeb ? _imageBytes : null,
//       );

//       if (imageUrl == null) {
//         Navigator.of(context, rootNavigator: true).pop(); // ❌ Hide dialog
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image upload failed. Try again.')),
//         );
//         return;
//       }

//       final userData = {
//         // your profile fields...
//         'photoUrl': imageUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       await FirebaseFirestore.instance.collection('users').add(userData);

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isRegistered', true);
//       await prefs.setString('displayName', _nameController.text.trim());

//       Navigator.of(context, rootNavigator: true).pop(); // ✅ Hide loading

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => Milan()),
//       );
//     } catch (e) {
//       Navigator.of(context, rootNavigator: true).pop(); // ⛔ Hide on error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something went wrong: $e')),
//       );
//       print('Registration error: $e');
//     }
//   }

  






//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _hobbiesController.dispose();
//     super.dispose();
//   }
// }