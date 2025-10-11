# Contributing to SwiftShelf

## How to Add a New Snippet

### 1. **Create Your Snippet Structure**

```
snippets/your-component.yourusername/
├── meta.yml          # Metadata
├── snippet.swift     # Swift code
└── screenshot.png    # Screenshot (PNG format)
```

**Folder Naming Convention:**

- Format: `component-name.username`
- Use kebab-case for both component names and usernames
- Examples: `animated-button.johndoe`, `gradient-card.janesmith`

### 2. **Fill the meta.yml**

```yaml
title: Your Component Name
author: Your Name
github-username: yourusername
tags:
  - tag1
  - tag2
  - tag3
description: Brief description of your component
```

**Important:** Use only allowed tags from `lib/allowed-tags.js`

### 3. **Create Your Swift Code**

**📦 Important: All code goes in `snippet.swift`!**

- Put **all your code** in a single file: `snippet.swift`
- Include all structs, enums, classes, extensions in the same file
- Don't create separate files - our system automatically separates them for display
- Use `// MARK: - Name` comments to organize sections (optional)
- The parser automatically detects: structs, enums, classes, extensions, and #Preview
- Must import SwiftUI
- Must define a View struct
- Include proper documentation
- Make it production-ready

### 4. **Add Screenshot**

- Must be PNG format
- Recommended: 9:16 aspect ratio (mobile-first)
- Max size: 500KB
- Show your component in action
- Use high-quality, clear images
- Avoid copyrighted content

**📸 Taking Screenshots from iOS Simulator**

Quick Steps:

1. Open your component in the iOS Simulator
2. Press `Command + S` to save a screenshot
3. Right-click the screenshot thumbnail that appears
4. Select "Save to Desktop" (or your preferred location)
5. Rename it to `screenshot.png`

### 5. **Submit Pull Request**

1. Fork the repository
2. Create your snippet folder
3. Submit PR with your changes
4. Our CI will automatically validate everything

## Automatic Process

### What Happens When You Submit a PR:

1. **Validation**

   - **Folder Structure**: Validates `component-name.username` format
   - **meta.yml Format**: Checks required fields and YAML syntax
   - **GitHub Username**: Verifies it matches folder username
   - **Swift Code**: Ensures `import SwiftUI` and valid View struct
   - **Screenshot**: Validates PNG format, size, and aspect ratio
   - **Tags**: Ensures only allowed tags are used (max 3)
   - **File Integrity**: Checks all required files exist

2. **Deployment**
   - If validation passes, it's automatically deployed
   - Your snippet is loaded dynamically from the `/snippets/` folder
   - Your component is live on the website

## File Structure

```
snippets/
├── animated-button.johndoe/
│   ├── meta.yml
│   ├── snippet.swift         # ALL your code goes here!
│   └── screenshot.png
├── gradient-card.janesmith/
│   ├── meta.yml
│   ├── snippet.swift         # Including all structs, enums, classes, extensions
│   └── screenshot.png
└── your-component.yourusername/
    ├── meta.yml
    ├── snippet.swift         # Don't create separate files - we parse and display automatically
    └── screenshot.png
```

### How Code Display Works

When you submit your snippet:

- Put all code (structs, enums, classes, extensions, #Preview) in `snippet.swift`
- Our parser automatically detects and separates different components
- Users see your code organized in tabs/sections
- You can use `// MARK: - Name` comments for better organization
- The system detects: struct, enum, class, extension, #Preview automatically

## Allowed Tags

Check `lib/allowed-tags.js` for the complete list. Common tags include:

- `ui`, `button`, `card`, `animation`
- `navigation`, `form`, `input`
- `screen`, `component`, `layout`

## Local Development

```bash
# Validate your snippets
npm run validate

# Run development server
npm run dev

# Build for production
npm run build
```

## What NOT to do

- Don't create multiple Swift files - everything goes in `snippet.swift`
- Don't use invalid tags
- Don't submit incomplete snippets
- Don't use copyrighted images
- Don't rename `snippet.swift` - it must be exactly that name

## Best Practices

- Use descriptive titles
- Write clean, documented code
- Put all code in one file (`snippet.swift`)
- Use `// MARK:` comments to organize different sections
- Include helpful comments
- Test your component
- Use high-quality screenshots
- Follow SwiftUI conventions

## Quality Standards

Your snippet should be:

- **Production-ready**: Copy-paste and use immediately
- **Well-documented**: Clear comments and structure
- **Modern**: Uses current SwiftUI best practices
- **Accessible**: Follows accessibility guidelines
- **Responsive**: Works on different screen sizes

## Need Help?

- Check existing snippets for examples
- Read the validation errors carefully
- Ask questions in GitHub Issues
- Join our community discussions

---

**Remember:** The goal is to create a library of high-quality, reusable SwiftUI components that help developers build amazing iOS apps faster!
