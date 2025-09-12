# Project Structure

This Flutter project has been restructured for better organization and maintainability.

## Folder Structure

```
lib/
├── constants/          # App-wide constants
│   └── app_constants.dart
├── models/            # Data models
│   ├── user_model.dart
│   └── post_model.dart
├── screens/           # Screen widgets
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── home_screen.dart
├── widgets/           # Reusable UI components
│   ├── custom_text_field.dart
│   ├── custom_button.dart
│   └── post_card.dart
├── services/          # Business logic and data services
│   └── post_service.dart
├── utils/             # Utility functions
│   └── navigation_helper.dart
└── main.dart          # App entry point
```

## Key Features

### Reusable Components
- **CustomTextField**: Standardized text input with consistent styling
- **CustomButton**: Reusable button component with multiple variants
- **PostCard**: Modular post display component

### Data Models
- **User**: User data structure with JSON serialization
- **Post**: Social media post with comments support
- **Comment**: Comment data structure

### Services
- **PostService**: Manages post data and operations (singleton pattern)

### Constants
- **AppConstants**: Centralized app constants for colors, strings, and dimensions

### Navigation
- **NavigationHelper**: Utility class for consistent navigation patterns

## Benefits of This Structure

1. **Maintainability**: Code is organized into logical modules
2. **Reusability**: Components can be reused across different screens
3. **Scalability**: Easy to add new features without affecting existing code
4. **Testability**: Services and models can be easily unit tested
5. **Consistency**: Standardized UI components ensure consistent look and feel

## Usage Examples

### Using Custom Components
```dart
CustomTextField(
  controller: emailController,
  hintText: 'Email',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
)

CustomButton(
  text: 'Login',
  onPressed: () => handleLogin(),
)
```

### Using Services
```dart
final postService = PostService();
postService.initializePosts();
final posts = postService.posts;
```

### Using Navigation Helper
```dart
NavigationHelper.navigateToScreen(context, HomeScreen());
NavigationHelper.navigateAndReplace(context, LoginScreen());
```

## Migration Notes

- All existing functionality has been preserved
- Navigation between screens works as before
- Post interactions (like, comment) are fully functional
- Theme switching and layout management remain unchanged