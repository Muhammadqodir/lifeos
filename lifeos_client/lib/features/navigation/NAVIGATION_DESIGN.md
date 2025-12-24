# Custom Bottom Navigation - shadcn Style

## Design Features

### 🎨 Visual Design
- **Border Top**: Subtle border using `colorScheme.border` to separate navigation from content
- **Background**: Uses `colorScheme.background` for consistency with shadcn theme
- **Rounded Corners**: 8px border radius for navigation buttons
- **Safe Area**: Respects device safe areas (notches, home indicators)

### 🎯 Interactive States

#### Selected State
- **Background**: `colorScheme.muted` - subtle highlight
- **Icon Color**: `colorScheme.foreground` - primary text color
- **Text Weight**: `FontWeight.w600` (semibold)
- **Text Color**: `colorScheme.foreground`

#### Unselected State
- **Background**: `Colors.transparent`
- **Icon Color**: `colorScheme.mutedForeground` - subtle gray
- **Text Weight**: `FontWeight.w500` (medium)
- **Text Color**: `colorScheme.mutedForeground`

#### Hover State (Desktop/Web)
- **Background**: `colorScheme.accent` - light highlight
- **Icon/Text**: Same as unselected

### ✨ Animations
- **Duration**: 200ms
- **Curve**: `Curves.easeInOut`
- **Properties**: Background color, text weight, icon color

### 📱 Layout
- **Padding**: 
  - Vertical: 8px
  - Horizontal: 8px (container), 12px (buttons)
- **Spacing**: 4px between icon and label
- **Icon Size**: 24px
- **Font Size**: 12px
- **Button Margin**: 4px horizontal (between buttons)

## Usage

```dart
CustomBottomNavigation(
  currentIndex: 0,
  onTap: (index) {
    // Handle navigation
  },
  items: [
    NavigationItem(
      label: 'Home',
      icon: HugeIcons.strokeRoundedHome01,
    ),
    // ... more items
  ],
)
```

## Color Scheme Mapping

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Background | White | Dark Gray |
| Border | Light Gray | Dark Border |
| Muted (Selected) | Light Gray | Muted Dark |
| Foreground | Near Black | Near White |
| Muted Foreground | Gray | Light Gray |
| Accent (Hover) | Very Light | Subtle Dark |

## Architecture

### Components
1. **CustomBottomNavigation** - Main container widget
2. **_NavigationButton** - Individual button with state
3. **NavigationItem** - Data class for navigation items

### Features
- Stateful buttons for hover effects
- Mouse region for desktop hover detection
- Gesture detector for tap handling
- Animated container for smooth transitions
- Responsive layout with Expanded widgets
