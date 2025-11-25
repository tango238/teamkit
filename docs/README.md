# GitHub Pages Configuration

This directory contains the GitHub Pages site for Team Kit.

## Local Development

To preview the site locally:

```bash
cd docs
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

## Deployment

This site is configured to deploy via GitHub Pages.

### Setup Instructions

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select:
   - Branch: `main`
   - Folder: `/docs`
4. Click **Save**

Your site will be available at: `https://<username>.github.io/teamkit/`

## Customization

Before deploying, update the following:

1. **Repository URL**: Replace `https://github.com/yourusername/teamkit` with your actual repository URL in:
   - `index.html` (multiple locations)

2. **GitHub Username**: Update `yourusername` with your actual GitHub username

## File Structure

```
docs/
├── index.html      # Main landing page
├── style.css       # Styles with dark theme and glassmorphism
├── script.js       # Interactive features
└── README.md       # This file
```

## Features

- 🎨 Modern dark theme with gradient accents
- ✨ Glassmorphism effects
- 📱 Fully responsive design
- 🎭 Smooth scroll animations
- 📋 Code copy functionality
- 🚀 Optimized performance
