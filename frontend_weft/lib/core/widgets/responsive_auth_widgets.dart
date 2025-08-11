import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';

class ResponsiveAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  
  const ResponsiveAuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getButtonHeight(context, baseHeight: 56),
      decoration: BoxDecoration(
        borderRadius: context.responsiveBorderRadius(16),
        gradient: LinearGradient(
          colors: backgroundColor != null 
            ? [backgroundColor!, backgroundColor!] 
            : [AppPallete.gradient1, AppPallete.gradient2],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: context.responsiveBorderRadius(16),
          ),
        ),
        child: isLoading
          ? SizedBox(
              width: context.responsiveIconSize(24),
              height: context.responsiveIconSize(24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? AppPallete.textPrimaryDark,
                ),
              ),
            )
          : Text(
              text,
              style: ResponsiveTextStyles.getButton(context).copyWith(
                color: textColor ?? AppPallete.textPrimaryDark,
                fontSize: context.responsiveFontSize(16),
              ),
            ),
      ),
    );
  }
}

class ResponsiveAuthTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  
  const ResponsiveAuthTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: context.responsiveBorderRadius(16),
        color: AppPallete.glassWhite10,
        border: Border.all(
          color: AppPallete.glassWhite20,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        enabled: enabled,
        style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
          color: AppPallete.textPrimaryDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: ResponsiveTextStyles.getBodyLarge(context).copyWith(
            color: AppPallete.greyColor,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: context.responsiveBorderRadius(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: context.responsiveBorderRadius(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: context.responsiveBorderRadius(16),
            borderSide: const BorderSide(
              color: AppPallete.gradient2,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: context.responsiveBorderRadius(16),
            borderSide: const BorderSide(
              color: AppPallete.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: context.responsiveBorderRadius(16),
            borderSide: const BorderSide(
              color: AppPallete.red,
              width: 2,
            ),
          ),
          contentPadding: context.responsivePadding(horizontal: 20, vertical: 16),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}

class ResponsiveAuthTitle extends StatelessWidget {
  final String text;
  final Color? color;
  
  const ResponsiveAuthTitle({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ResponsiveTextStyles.getHeading1(context).copyWith(
        color: color ?? AppPallete.textPrimaryDark,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ResponsiveAuthSubtitle extends StatelessWidget {
  final String text;
  final Color? color;
  
  const ResponsiveAuthSubtitle({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
        color: color ?? AppPallete.greyColor,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ResponsiveAuthLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottomAction;
  
  const ResponsiveAuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.responsivePadding(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: context.screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.responsiveSpacing(40)),
                  ResponsiveAuthTitle(text: title),
                  if (subtitle != null) ...[
                    SizedBox(height: context.responsiveSpacing(16)),
                    ResponsiveAuthSubtitle(text: subtitle!),
                  ],
                  SizedBox(height: context.responsiveSpacing(48)),
                  ...children.map((child) => Padding(
                    padding: EdgeInsets.only(bottom: context.responsiveSpacing(20)),
                    child: child,
                  )),
                  if (bottomAction != null) ...[
                    SizedBox(height: context.responsiveSpacing(24)),
                    bottomAction!,
                  ],
                  SizedBox(height: context.responsiveSpacing(40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
