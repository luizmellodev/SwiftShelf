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

Snippets are loaded dynamically from the `/snippets/` folder at build time, so no additional generation steps are needed.

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

## 📝 License

MIT License - feel free to use these snippets in your projects!
