# SwiftShelf

A community-driven gallery of reusable SwiftUI components and code snippets.

## Disclaimer

This project is not an official Apple project and is not affiliated with Apple or the Swift programming language brand (despite the name SwiftShelf). It is a non-profit and community-driven initiative. To access official information about the Swift language, please visit [swift.org](https://swift.org).

## About

This project showcases beautiful, reusable SwiftUI components submitted by the community. Each snippet includes:

- Screenshot preview
- Copy-paste ready SwiftUI code
- Tags for easy discovery
- Author attribution

## How It Works

1. **Submit a PR**: Add your snippet folder to `/snippets/`
2. **Auto-validation**: GitHub Actions validates your submission
3. **Merge**: Once approved, your PR is merged to main
4. **Live**: Your snippet appears on the gallery instantly! 🎉

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed instructions.

### Quick Start

1. **Fork this repo**
2. **Create a folder** in `/snippets/` with format: `component-name.username`
3. **Add three required files:**
   - `meta.yml` - Metadata (title, author, github-username, tags, description)
   - `snippet.swift` - Your SwiftUI code
   - `screenshot.png` - Screenshot (9:16 aspect ratio, PNG format, under 500KB)
4. **Open a Pull Request**

Your PR will be automatically validated and merged if all checks pass!

### 📁 Folder Structure

```
snippets/
└── animated-button.luizmellodev/
├── meta.yml # Metadata
├── snippet.swift # SwiftUI code
└── screenshot.png # Preview image (9:16 ratio)
```

### 📋 meta.yml Format

```yaml
title: "Animated Button"
author: "Your Name"
github-username: yourusername
description: "A beautiful animated button with spring animation"
tags:
  - button
  - animation
  - ui
```

### 🏷️ Tag Rules

- **Exactly 3 tags** (no more, no less)
- **Use approved tags only** from our comprehensive list
- **Mix different categories** (e.g., one UI tag + one animation tag + one platform tag)

### 📸 Screenshot Requirements

- **Format:** PNG only
- **Aspect ratio:** 9:16 (vertical)
- **Size:** Under 500KB
- **Resolution:** 800-2000px width, 1000-3000px height
- **Content:** Show your component in action with realistic content

### ✅ Validation

Your submission will be automatically validated for:

- ✅ Folder naming convention
- ✅ Required files presence
- ✅ meta.yml format and required fields
- ✅ Tag validation (approved tags only)
- ✅ Screenshot format, size, and aspect ratio
- ✅ SwiftUI code structure

### 🚫 Common Mistakes to Avoid

- ❌ Using more than 3 tags
- ❌ Using unapproved tags
- ❌ Wrong folder naming (use dots, not hyphens)
- ❌ Screenshot not in 9:16 aspect ratio
- ❌ Screenshot over 500KB
- ❌ Missing required fields in meta.yml

## 📝 License

MIT License - feel free to use these snippets in your projects!
