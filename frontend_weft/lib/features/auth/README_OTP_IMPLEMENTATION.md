# OTP Verification Implementation

This document outlines the OTP verification implementation for the WEFT app registration flow.

## Backend API Endpoints

Based on the `handlers.go` file, the backend provides:

1. **POST /register** - Initiates registration and sends OTP email
   - Returns: "Verification mail sent"
   - Status: 200

2. **POST /complete-registration** - Verifies OTP and completes registration
   - Body: `{"email": "user@example.com", "otp": "123456"}`
   - Returns: `{"AccessToken": "...", "RefreshToken": "..."}`
   - Status: 201

## Frontend Implementation

### Files Created/Modified

1. **New Files:**
   - `otp_verification_page.dart` - OTP input UI with 6-digit code entry
   - `registration_storage.dart` - Temporary storage for registration data (for resend functionality)

2. **Modified Files:**
   - `auth_service.dart` - Added OTP verification methods
   - `auth_viewmodel.dart` - Added OTP verification logic
   - `signup_page.dart` - Updated to navigate to OTP verification
   - `main.dart` - Added OTP verification route

### Registration Flow

1. **User fills signup form** → `SignupPage`
2. **Submit registration** → Calls `initiateRegistration()` 
3. **Backend sends OTP email** → Returns "Verification mail sent"
4. **Navigate to OTP page** → `OtpVerificationPage`
5. **User enters OTP** → Calls `verifyOtp()`
6. **Backend verifies OTP** → Returns tokens
7. **Save tokens and navigate to home** → Registration complete

### Key Features

- **6-digit OTP input** with automatic focus management
- **Resend OTP functionality** (re-triggers registration endpoint)
- **Temporary storage** of registration data for resend
- **Error handling** with user-friendly messages
- **Loading states** for better UX

### Usage

The OTP verification is automatically integrated into the existing signup flow. When users complete the signup form, they'll be redirected to the OTP verification page where they can:

1. Enter the 6-digit code received via email
2. Resend the code if needed
3. Complete registration and be logged in automatically

### Error Handling

- Invalid OTP codes show appropriate error messages
- Expired OTPs are handled gracefully
- Network errors are caught and displayed to users
- Resend functionality includes proper error handling

### Security Considerations

- Registration data is stored temporarily only for resend functionality
- Data is cleared after successful registration
- OTP codes are validated server-side
- Tokens are securely stored using SharedPreferences