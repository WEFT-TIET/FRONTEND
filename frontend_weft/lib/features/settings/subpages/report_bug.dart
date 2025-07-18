import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportBugPage extends StatefulWidget {
  final String userEmail; // User's college email from sign-in

  const ReportBugPage({super.key, required this.userEmail});

  @override
  State<ReportBugPage> createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage> {
  final TextEditingController _bugDescriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bugDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitBugReport() async {
    // Validate input
    if (_bugDescriptionController.text.isEmpty) {
      _showToast("Please describe the bug before submitting", isError: true);
      return;
    }

    if (_bugDescriptionController.text.length < 20) {
      _showToast("Please provide more details (at least 20 characters)", 
                 isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Configure email server (replace with your credentials)
      final smtpServer = gmail('weftatwork@gmail.com', 'your_app_password_here');

      // 2. Create email message
      final message = Message()
        ..from = Address(widget.userEmail, 'WEFT User')
        ..recipients.add('weftatwork@gmail.com')
        ..subject = 'Bug Report from ${widget.userEmail.split('@')[0]}'
        ..text = '''
Bug Report Details:
-------------------
User: ${widget.userEmail}
Date: ${DateTime.now().toString()}

Description:
${_bugDescriptionController.text}

Device Info:
- Platform: ${Theme.of(context).platform}
- Timezone: ${DateTime.now().timeZoneName}
''';

      // 3. Send the email
      await send(message, smtpServer);

      // 4. Show success & reset form
      _showToast("Bug report sent successfully!");
      _bugDescriptionController.clear();
    } catch (e) {
      debugPrint('Error sending bug report: $e');
      _showToast("Failed to send. Please try again later.", isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            AppPallete.gradient3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          title: const Text(
            'Report a Bug',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report a Bug',
                      style: TextStyle(
                        color: AppPallete.textPrimaryDark,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reporting from: ${widget.userEmail}',
                      style: TextStyle(
                        color: AppPallete.textPrimaryDark.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

                // Bug Description Field
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _bugDescriptionController,
                          maxLines: 12,
                          minLines: 10,
                          decoration: InputDecoration(
                            labelText: 'Describe the issue',
                            hintText: '• What happened?\n• Steps to reproduce\n• Expected behavior',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppPallete.textPrimaryDark.withOpacity(0.4),
                              ),
                            ),
                            filled: true,
                            fillColor: AppPallete.cardColorDark.withOpacity(0.2),
                            
                          ),
                          style: const TextStyle(
                            color: AppPallete.textPrimaryDark,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please include as many details as possible. Screenshots can be sent directly to weftatwork@gmail.com',
                          style: TextStyle(
                            color: AppPallete.textPrimaryDark.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Send Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBugReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.textPrimaryDark,
                      foregroundColor: AppPallete.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppPallete.backgroundDark,
                              strokeWidth: 3,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded),
                              SizedBox(width: 10),
                              Text(
                                'Send Report',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}