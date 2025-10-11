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
3. **Auto-generation**: CI automatically generates `snippets-data.ts`
4. **Merge**: Once approved, your PR is merged to main
5. **Live**: Your snippet appears on the gallery instantly! 🎉

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

### 🤖 Automatic System

- **No manual editing needed**: CI automatically generates `snippets-data.ts`
- **Zero intervention**: Your snippet appears on the website automatically
- **Full validation**: All rules are checked before deployment

### 📁 Folder Structure

```
snippets/
└── animated-button.luizmellodev/
    ├── meta.yml          # Metadata
    ├── snippet.swift     # SwiftUI code
    └── screenshot.png    # Preview image (9:16 ratio)
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

- **Maximum 3 tags** (1-3 tags allowed)
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

- ✅ **Folder naming convention**: `component-name.username` format
- ✅ **Required files presence**: meta.yml, snippet.swift, screenshot.png
- ✅ **meta.yml format**: All required fields and YAML syntax
- ✅ **GitHub username**: Must match folder username
- ✅ **Tag validation**: Approved tags only, maximum 3
- ✅ **Screenshot format**: PNG, size, and aspect ratio
- ✅ **SwiftUI code**: Must import SwiftUI and define View struct

### 🚫 Common Mistakes to Avoid

- ❌ Using more than 3 tags
- ❌ Using unapproved tags
- ❌ Wrong folder naming (use `component-name.username`, not `component-name-username`)
- ❌ GitHub username doesn't match folder
- ❌ Screenshot not in 9:16 aspect ratio
- ❌ Screenshot over 500KB
- ❌ Missing required fields in meta.yml
- ❌ Swift code without `import SwiftUI`

## 📝 License

MIT License - feel free to use these snippets in your projects!
