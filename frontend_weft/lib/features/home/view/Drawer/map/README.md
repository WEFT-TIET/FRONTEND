# Trusted Users Feature

This feature allows users to manage trusted contacts who can see their location on the campus map.

## Features

### 1. Trusted Users Management
- Add users to trusted list
- Remove users from trusted list
- View all trusted users with their status

### 2. Ghost Mode
- Toggle ghost mode to hide your location from all trusted users
- Visual indicator when ghost mode is active

### 3. User Search
- Search for users by name or username
- Add users to trusted list from search results
- Visual feedback for already trusted users

### 4. Location Sharing
- Trusted users can see each other's locations on the map
- Real-time location updates
- Privacy controls with ghost mode

## File Structure

```
map/
├── models/
│   └── trusted_user_model.dart          # User model with location and ghost mode
├── services/
│   └── trusted_users_service.dart       # Riverpod StateNotifier for state management
├── pages/
│   ├── map_page.dart                    # Main map page with trusted users icon
│   └── trusted_users_page.dart          # Trusted users management page
└── widgets/
    ├── trusted_user_tile.dart           # Widget for displaying trusted users
    └── search_user_tile.dart            # Widget for search results
```

## Usage

### Accessing Trusted Users
1. Navigate to the Campus Map page
2. Tap the people icon in the top right corner
3. This opens the Trusted Users page

### Adding Users to Trusted List
1. In the Trusted Users page, use the search bar
2. Type a username or name to search
3. Tap the "+" button next to a user to add them
4. Users already in your trusted list will show "Added"

### Managing Ghost Mode
1. In the Trusted Users page, toggle the "Ghost" switch
2. When enabled, your location will be hidden from all trusted users
3. The switch shows visual feedback when active

### Removing Users
1. In the trusted users list, tap the three dots menu
2. Select "Remove from trusted list"
3. Confirm the removal

## State Management

The feature uses Riverpod for state management:

- `TrustedUsersState`: Contains the current state
- `TrustedUsersNotifier`: Handles all state updates
- `trustedUsersProvider`: Provides access to the state

## API Integration

The current implementation uses mock data. To integrate with real APIs:

1. Update the `searchUsers()` method in `TrustedUsersNotifier`
2. Update the `loadTrustedUsers()` method
3. Implement real API calls for add/remove operations
4. Add WebSocket or polling for real-time location updates

## Theme Integration

The feature follows the app's dark theme with:
- Gradient backgrounds matching the app palette
- Glass effect containers
- Consistent color scheme using `AppPallete`
- Proper contrast and accessibility

## Future Enhancements

- Real-time location updates via WebSocket
- Push notifications for location requests
- Location history and analytics
- Advanced privacy settings
- Group location sharing 