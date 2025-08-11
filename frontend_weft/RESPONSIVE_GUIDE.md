# Responsive Design System Documentation

This document explains how to use the responsive design system implemented in the WEFT app to ensure consistent appearance across all mobile devices.

## Overview

The responsive system consists of several key components:

1. **ResponsiveUtils** - Core utility functions for responsive sizing and spacing
2. **ResponsiveTextStyles** - Consistent text styles that scale across devices  
3. **ResponsiveProfileName** - Smart profile name display that adapts to available space
4. **ResponsiveAuthWidgets** - Reusable auth form components
5. **ResponsiveConfig** - Global configuration and constants

## Key Components

### ResponsiveUtils

Main utility class that provides responsive sizing based on screen dimensions:

```dart
// Get responsive font size
double fontSize = context.responsiveFontSize(16);

// Get responsive padding
EdgeInsets padding = context.responsivePadding(horizontal: 16, vertical: 12);

// Get responsive spacing
double spacing = context.responsiveSpacing(20);

// Get responsive border radius
BorderRadius radius = context.responsiveBorderRadius(12);

// Get responsive icon size
double iconSize = context.responsiveIconSize(24);

// Check screen size
bool isSmallScreen = context.isSmallScreen;
bool isMediumScreen = context.isMediumScreen;
bool isLargeScreen = context.isLargeScreen;
```

### ResponsiveTextStyles

Pre-defined text styles that scale consistently:

```dart
Text(
  'Heading',
  style: ResponsiveTextStyles.getHeading1(context).copyWith(
    color: Colors.white,
  ),
)

Text(
  'Body text',
  style: ResponsiveTextStyles.getBodyLarge(context).copyWith(
    color: Colors.grey,
  ),
)
```

### ResponsiveProfileName

Smart widget for displaying profile names that automatically wraps long names:

```dart
ResponsiveProfileName(
  name: user.name,
  isVerified: user.isVerified,
  color: Colors.white,
)
```

## Device Breakpoints

The system uses these breakpoints to determine device categories:

- **Small Screen**: Width < 375px (older/smaller phones)
- **Medium Screen**: 375px ≤ Width ≤ 414px (standard phones)  
- **Large Screen**: Width > 414px (larger phones, phablets)

## Scaling Factors

All responsive calculations use these constraints:

- **Minimum Scale**: 0.8x (prevents elements from becoming too small)
- **Maximum Scale**: 1.2x - 1.4x (prevents elements from becoming too large)
- **Base Reference**: iPhone 6/7/8 dimensions (375x812)

## Best Practices

### 1. Always Use Responsive Utilities

❌ **Don't do this:**
```dart
Container(
  padding: EdgeInsets.all(16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 18),
  ),
)
```

✅ **Do this:**
```dart
Container(
  padding: context.responsivePadding(),
  child: Text(
    'Hello',
    style: ResponsiveTextStyles.getBodyLarge(context),
  ),
)
```

### 2. Use Context Extensions

The system provides convenient context extensions:

```dart
// Instead of ResponsiveUtils.screenWidth(context)
double width = context.screenWidth;

// Instead of ResponsiveUtils.getSpacing(context, 16)
double spacing = context.responsiveSpacing(16);
```

### 3. Test on Multiple Screen Sizes

Always test your UI on:
- Small screens (iPhone SE, older Android phones)
- Medium screens (iPhone 12/13/14, standard Android phones)
- Large screens (iPhone 12/13/14 Pro Max, large Android phones)

### 4. Handle Text Overflow

For profile names and long text, use the responsive widgets:

```dart
// For profile names
ResponsiveProfileName(name: longName)

// For other text
Text(
  longText,
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
  style: ResponsiveTextStyles.getBodyLarge(context),
)
```

### 5. Use Semantic Spacing

Use the provided spacing constants rather than arbitrary numbers:

```dart
// Standard spacing values
SizedBox(height: context.responsiveSpacing(8))   // Small spacing
SizedBox(height: context.responsiveSpacing(16))  // Medium spacing  
SizedBox(height: context.responsiveSpacing(24))  // Large spacing
SizedBox(height: context.responsiveSpacing(32))  // Extra large spacing
```

## Common Issues and Solutions

### Issue: Profile names getting cut off
**Solution**: Use `ResponsiveProfileName` widget instead of plain Text.

### Issue: Buttons too small on large screens
**Solution**: Use `ResponsiveUtils.getButtonHeight(context)` for button heights.

### Issue: Text too small/large on different devices  
**Solution**: Use `ResponsiveTextStyles` instead of hardcoded TextStyle.

### Issue: Inconsistent spacing across screens
**Solution**: Use `context.responsiveSpacing()` and `context.responsivePadding()`.

### Issue: Icons not scaling properly
**Solution**: Use `context.responsiveIconSize()` for all icon sizes.

## Implementation Checklist

When adding a new screen or component:

- [ ] Import responsive utilities
- [ ] Use responsive text styles
- [ ] Use responsive spacing and padding  
- [ ] Use responsive icon sizes
- [ ] Test on multiple screen sizes
- [ ] Handle text overflow appropriately
- [ ] Use semantic spacing values
- [ ] Avoid hardcoded dimensions

## Future Considerations

The system is designed to be extensible. Future additions might include:

- Tablet-specific layouts
- Orientation-specific adjustments
- Dynamic type scaling based on system settings
- Accessibility improvements

## Migration Guide

To update existing non-responsive code:

1. Replace hardcoded padding with `context.responsivePadding()`
2. Replace hardcoded font sizes with `ResponsiveTextStyles`
3. Replace hardcoded spacing with `context.responsiveSpacing()`
4. Replace hardcoded icon sizes with `context.responsiveIconSize()`
5. Test thoroughly on different screen sizes
