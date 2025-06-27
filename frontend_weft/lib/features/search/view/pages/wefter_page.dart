import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class WEFTerPage extends StatefulWidget {
  const WEFTerPage({super.key});

  @override
  _WEFTerPageState createState() => _WEFTerPageState();
}

class _WEFTerPageState extends State<WEFTerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPallete.gradient1, AppPallete.gradient2, AppPallete.gradient3
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'WEFT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Color(0xFF2d2d4a),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Color(0xFF3d3d5a),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Who\'s the WEFTer?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Type a name... or just stalk randomly, we don\'t judge',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                            _buildInputField(
                              controller: _nameController,
                              label: 'Name',
                              placeholder: 'Ex: Chad Brobowsky or That One Top',
                            ),
                            SizedBox(height: 20),
                            _buildInputField(
                              controller: _batchController,
                              label: 'Batch',
                              placeholder: 'Grad year? Left for your people!',
                            ),
                            SizedBox(height: 20),
                            _buildInputField(
                              controller: _branchController,
                              label: 'Branch',
                              placeholder: 'Ex: Code Sleep Repeat or Mech, Cho',
                            ),
                            SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF6366f1),
                                    Color(0xFF8b5cf6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366f1).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () {
                                    _findWEFTer();
                                  },
                                  child: Center(
                                    child: Text(
                                      'Find the WEFTer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF3d3d5a),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF4d4d6a),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _findWEFTer() {
    String name = _nameController.text;
    String batch = _batchController.text;
    String branch = _branchController.text;

    print('Searching for WEFTer:');
    print('Name: $name');
    print('Batch: $batch');
    print('Branch: $branch');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for WEFTer...'),
        backgroundColor: Color(0xFF6366f1),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _branchController.dispose();
    super.dispose();
  }
}