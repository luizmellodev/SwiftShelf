# Contributing to SwiftUI Snippet Gallery

Thank you for contributing! Follow these steps to add your SwiftUI snippet.

## Snippet Structure

Each snippet must be in its own folder under `/snippets/` with the following naming convention:

```
snippets/
component-name.username/
meta.yml # Metadata about your snippet
snippet.swift # Your SwiftUI code
screenshot.png # Screenshot of your component (9:16 aspect ratio recommended)
```

### Folder Naming Convention

- **Format**: `component-name.username`
- **Important**: The dot (.) separates the component name from the username, not a hyphen
- **Examples**:
  - `animated-button.johndoe` (component: "animated-button", username: "johndoe")
  - `gradient-card.janesmith` (component: "gradient-card", username: "janesmith")
  - `loading-spinner.mikejohnson` (component: "loading-spinner", username: "mikejohnson")
- **Rules**:
  - Use kebab-case for component names and usernames
  - No spaces or special characters
  - Must match the `github-username` in meta.yml

## meta.yml Format

```yaml
title: Your Snippet Title
author: Your Name
github-username: yourusername
tags:
  - tag1
  - tag2
  - tag3
description: A brief description of what your snippet does
```

### Required Fields:

- **title**: Short, descriptive name for your snippet
- **author**: Your display name (can be your real name or GitHub username)
- **github-username**: Your GitHub username (must match folder name)
- **tags**: Array of relevant tags (max 3, must use approved tags)
- **description**: One sentence explaining what the snippet does

## Complete Examples

Here are 3 complete examples of how your meta.yml should look:

### Example 1: Animated Button

```yaml
title: Animated Button
author: John Doe
github-username: john-doe
tags:
  - button
  - animation
  - ui
description: A beautiful animated button with spring animation and haptic feedback
```

**Folder:** `animated-button.john-doe/`

### Example 2: Gradient Card

```yaml
title: Gradient Card
author: Jane Smith
github-username: jane-smith
tags:
  - card
  - gradient
  - layout
description: A modern card component with gradient background and glassmorphism effect
```

**Folder:** `gradient-card.jane-smith/`

### Example 3: Loading Spinner

```yaml
title: Loading Spinner
author: Mike Johnson
github-username: mike-johnson
tags:
  - loading
  - animation
  - ui
description: Smooth rotating loading spinner with customizable colors
```

**Folder:** `loading-spinner.mike-johnson/`

### Key Points

- All fields are required
- Use exactly 3 tags (no more, no less)
- Tags must be from the approved list
- github-username must match your folder name
- Description should be one clear sentence

## Tags Guidelines

- **Maximum**: 3 tags per snippet
- **Format**: Use approved tags only (lowercase, kebab-case)
- **Purpose**: Help users discover your snippet
- **Total**: 150+ approved tags available

### Tag Categories:

- **UI Components**: `button`, `card`, `input`, `text`, `image`, `icon`, `badge`, `chip`, `avatar`, `list`, `grid`, `stack`, `spacer`, `divider`, `separator`
- **Layout & Navigation**: `layout`, `container`, `section`, `modal`, `sheet`, `popover`, `tooltip`, `overlay`, `navigation`, `tab`, `menu`, `sidebar`, `header`, `footer`, `breadcrumb`
- **Forms**: `form`, `field`, `picker`, `selector`, `toggle`, `switch`, `slider`, `stepper`, `checkbox`, `radio`
- **Data Display**: `table`, `chart`, `graph`, `timeline`, `calendar`, `progress`, `meter`, `stat`, `metric`
- **Feedback**: `alert`, `notification`, `toast`, `loading`, `spinner`, `skeleton`, `empty`, `error`, `success`, `warning`
- **Media**: `video`, `audio`, `player`, `gallery`, `carousel`
- **Animation**: `animation`, `transition`, `motion`, `gesture`, `interaction`
- **Theming**: `theme`, `color`, `gradient`, `shadow`, `border`, `radius`
- **Utility**: `utility`, `helper`, `wrapper`, `responsive`, `adaptive`
- **Platform**: `ios`, `macos`, `watchos`, `tvos`
- **Category**: `ui`, `component`, `screen`, `view`, `widget`, `element`
- **State**: `state`, `interactive`, `static`, `dynamic`
- **Size**: `small`, `medium`, `large`, `compact`, `expanded`
- **Style**: `minimal`, `modern`, `classic`, `elegant`, `bold`, `subtle`
- **Function**: `auth`, `login`, `signup`, `profile`, `settings`, `search`, `filter`, `sort`, `action`, `control`

## snippet.swift Format

Your Swift file should:

- Import SwiftUI
- Define a reusable View struct
- Be self-contained and ready to copy-paste
- Include comments if the code is complex

Example:

```swift
import SwiftUI

struct MyCustomButton: View {
    var body: some View {
        Button("Tap Me") {
            // Action here
        }
        .buttonStyle(.borderedProminent)
    }
}
```

## screenshot.png

- **Aspect ratio**: 9:16 (iPhone screenshot) - will be validated automatically
- **Format**: PNG only - other formats will be rejected
- **Size**: Under 500KB - larger files will be rejected
- **Resolution**: 800-2000px width, 1000-3000px height (iPhone-like)
- **Content**: Show your component in action

### Validation

Your screenshot will be automatically validated for:

- ✅ Correct format (PNG only)
- ✅ File size (under 500KB)
- ✅ Aspect ratio (close to 9:16)
- ✅ Resolution (iPhone-like dimensions)

## How to Submit

1. **Fork** this repository
2. **Create** a new folder in `/snippets/` with format `component-name.username`
3. **Add** your three files: `meta.yml`, `snippet.swift`, `screenshot.png`
4. **Ensure** the `github-username` in meta.yml matches your folder name
5. **Commit** your changes
6. **Open** a Pull Request

## Validation

Your PR will automatically run validation checks:

- ✅ All required files exist
- ✅ YAML syntax is correct
- ✅ All required fields are present (including github-username)
- ✅ Folder name matches github-username format
- ✅ Tags are valid (max 3, approved tags only)
- ✅ Swift file imports SwiftUI
- ✅ Screenshot meets requirements (format, size, aspect ratio, resolution)

## Guidelines

- Keep snippets **simple and focused** on one component/feature
- Use **clear, descriptive names**
- Add **relevant tags** for discoverability
- Ensure your code is **properly formatted**
- Test your snippet before submitting

## Questions?

Open an issue if you need help!
