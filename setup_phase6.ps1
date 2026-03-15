# Femboard Setup - Phase 6: Responsive Design + Final Merge
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\aruch\Work\temp\clash\femboard"

# ============================================================
# FEATURE: Responsive Design
# ============================================================
git checkout dev
git checkout -b feature/responsive-design

# --- Commit 38: Mobile breakpoints ---
@"
/* =============================================
   Responsive Design - Mobile & Tablet
   ============================================= */

/* ---------- Tablet (max 768px) ---------- */
@media (max-width: 768px) {
  .hero-title {
    font-size: 2.5rem;
  }

  .hero-subtitle {
    font-size: 1rem;
  }

  .hero-stats {
    gap: var(--space-lg);
  }

  .stat-number {
    font-size: 1.4rem;
  }

  .features-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-lg);
  }

  .boards-preview-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .section-title {
    font-size: 1.6rem;
  }

  .board-card {
    flex-direction: column;
    text-align: center;
    gap: var(--space-md);
  }

  .board-card-stats {
    justify-content: center;
  }

  .post-card {
    flex-direction: column;
  }

  .post-sidebar {
    width: 100%;
    flex-direction: row;
    justify-content: flex-start;
    gap: var(--space-md);
    border-right: none;
    border-bottom: 1px solid var(--neutral-200);
    padding: var(--space-md);
  }

  .post-avatar {
    width: 50px;
    height: 50px;
    border-radius: var(--radius-md);
  }

  .profile-main {
    flex-direction: column;
    align-items: center;
    text-align: center;
    margin-top: -50px;
  }

  .profile-avatar {
    width: 100px;
    height: 100px;
  }

  .profile-bio {
    max-width: 100%;
  }

  .footer-links {
    flex-direction: column;
    gap: var(--space-xl);
  }

  .thread-header-meta {
    flex-direction: column;
    gap: var(--space-sm);
  }
}

/* ---------- Mobile (max 480px) ---------- */
@media (max-width: 480px) {
  .nav-links {
    display: none;
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    flex-direction: column;
    background: rgba(253, 250, 255, 0.98);
    backdrop-filter: blur(16px);
    padding: var(--space-lg);
    border-bottom: 1px solid var(--neutral-200);
    box-shadow: var(--shadow-md);
    gap: var(--space-sm);
  }

  .nav-links.nav-open {
    display: flex;
  }

  .nav-toggle {
    display: flex;
  }

  .nav-toggle.nav-active span:nth-child(1) {
    transform: rotate(45deg) translate(5px, 5px);
  }

  .nav-toggle.nav-active span:nth-child(2) {
    opacity: 0;
  }

  .nav-toggle.nav-active span:nth-child(3) {
    transform: rotate(-45deg) translate(5px, -5px);
  }

  .hero {
    padding: var(--space-2xl) var(--space-md);
    min-height: 60vh;
  }

  .hero-title {
    font-size: 2rem;
  }

  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }

  .hero-stats {
    flex-direction: column;
    gap: var(--space-md);
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .boards-preview-grid {
    grid-template-columns: 1fr;
  }

  .cta-content {
    padding: var(--space-xl);
  }

  .cta-content h2 {
    font-size: 1.5rem;
  }

  .container {
    padding: 0 var(--space-md);
  }

  .page-header h1 {
    font-size: 1.5rem;
  }

  .thread-title {
    font-size: 1rem;
  }

  .thread-info {
    flex-wrap: wrap;
    gap: var(--space-sm);
  }

  .profile-stats-bar {
    justify-content: center;
  }

  .settings-card {
    padding: var(--space-lg);
  }

  .avatar-upload {
    flex-direction: column;
    align-items: flex-start;
  }

  .auth-card {
    padding: var(--space-lg);
  }
}

/* ---------- Toast Notifications ---------- */
.toast {
  position: fixed;
  bottom: -100px;
  left: 50%;
  transform: translateX(-50%);
  padding: 0.8rem 1.5rem;
  border-radius: var(--radius-full);
  font-weight: 600;
  font-size: 0.9rem;
  z-index: 300;
  transition: all var(--transition-base);
  box-shadow: var(--shadow-lg);
}

.toast-show {
  bottom: 30px;
}

.toast-info {
  background: var(--blue-500);
  color: white;
}

.toast-success {
  background: var(--success);
  color: white;
}

.toast-error {
  background: var(--error);
  color: white;
}

/* ---------- Scrollbar ---------- */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: var(--neutral-100);
}

::-webkit-scrollbar-thumb {
  background: var(--neutral-300);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--neutral-400);
}

/* ---------- Selection ---------- */
::selection {
  background: var(--pink-200);
  color: var(--neutral-900);
}
"@ | Set-Content -Path "public/css/responsive.css" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-05T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-05T10:00:00+07:00"
git add -A
git commit -m "Add responsive breakpoints for tablet and mobile"

# --- Commit 39: Link responsive CSS in header ---
$headerContent = Get-Content -Path "views/partials/header.ejs" -Raw
$headerContent = $headerContent.Replace(
'<link rel="stylesheet" href="/css/style.css">',
'<link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="/css/responsive.css">'
)
Set-Content -Path "views/partials/header.ejs" -Value $headerContent -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-05T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-05T11:00:00+07:00"
git add -A
git commit -m "Link responsive CSS stylesheet in header partial"

# --- Commit 40: Add meta tags and favicon ---
$headerContent = Get-Content -Path "views/partials/header.ejs" -Raw
$headerContent = $headerContent.Replace(
'<meta name="description" content="Femboard - A cute and cozy community forum for femboys">',
'<meta name="description" content="Femboard - A cute and cozy community forum for femboys">
  <meta name="theme-color" content="#FF69B4">
  <meta name="author" content="Femboard">
  <meta property="og:title" content="Femboard - A Cozy Community">
  <meta property="og:description" content="A cute and welcoming community forum. Share outfits, get advice, make friends!">
  <meta property="og:type" content="website">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🌸</text></svg>">'
)
Set-Content -Path "views/partials/header.ejs" -Value $headerContent -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-05T12:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-05T12:00:00+07:00"
git add -A
git commit -m "Add meta tags, Open Graph, and favicon"

# --- Commit 41: Improve accessibility ---
$navContent = Get-Content -Path "views/partials/navbar.ejs" -Raw
$navContent = $navContent.Replace(
'<nav class="navbar">',
'<nav class="navbar" role="navigation" aria-label="Main navigation">'
)
Set-Content -Path "views/partials/navbar.ejs" -Value $navContent -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-06T09:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-06T09:00:00+07:00"
git add -A
git commit -m "Improve accessibility with ARIA attributes"

# Merge feature/responsive-design into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-04-06T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-06T10:00:00+07:00"
git merge feature/responsive-design --no-ff -m "Merge feature/responsive-design into dev"

# ============================================================
# FEATURE: Bug fixes and polish
# ============================================================
git checkout -b fix/minor-improvements

# --- Commit 42: Add .keep file for uploads ---
@"
# Placeholder - this file ensures the uploads directory is tracked by git
"@ | Set-Content -Path "public/uploads/.gitkeep" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-07T09:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-07T09:00:00+07:00"
git add -A
git commit -m "Add .gitkeep for uploads directory"

# --- Commit 43: Update README with setup instructions ---
@"
# Femboard 🌸

A cute and cozy web forum for the femboy community! Built with love and pastels.

![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)
![Express](https://img.shields.io/badge/Express-4.x-blue?logo=express)
![License](https://img.shields.io/badge/License-MIT-pink)

## ✨ Features

- 💬 **Discussion Boards** - Multiple themed categories for every interest
- 👤 **User Profiles** - Customizable profiles with avatar uploads
- 🎨 **Cute Pastel Theme** - Gorgeous glassmorphism design with animations
- 📱 **Responsive Design** - Looks great on desktop, tablet, and mobile
- 🔒 **Secure Auth** - bcrypt password hashing and session management
- 🛡️ **Safe Space** - Role-based moderation system

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- npm

### Installation

1. Clone the repository:
``````bash
git clone https://github.com/yourusername/femboard.git
cd femboard
``````

2. Install dependencies:
``````bash
npm install
``````

3. Create environment file:
``````bash
cp .env.example .env
``````

4. Seed the database:
``````bash
npm run seed
``````

5. Start the development server:
``````bash
npm run dev
``````

6. Open http://localhost:3000 in your browser 🌸

## 📁 Project Structure

``````
femboard/
├── config/          # Database configuration
├── middleware/       # Auth middleware
├── models/          # Data models (User, Board, Thread, Post)
├── public/          # Static assets
│   ├── css/         # Stylesheets
│   ├── js/          # Client-side JavaScript
│   └── uploads/     # User-uploaded files
├── routes/          # Express route handlers
├── scripts/         # Utility scripts
├── views/           # EJS templates
│   ├── auth/        # Login & register pages
│   ├── boards/      # Board & thread pages
│   ├── partials/    # Reusable template parts
│   └── profile/     # User profile pages
└── server.js        # App entry point
``````

## 🎨 Board Categories

| Board | Description |
|-------|-------------|
| /cute/ | Cute Outfits & Fashion |
| /beauty/ | Beauty & Skincare |
| /fit/ | Fitness & Health |
| /tech/ | Technology |
| /random/ | Random Discussion |
| /support/ | Support & Advice |
| /creative/ | Creative Corner |
| /gaming/ | Gaming |

## 🛠️ Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** SQLite3 (via better-sqlite3)
- **Templates:** EJS
- **Auth:** bcryptjs + express-session
- **Styling:** Custom CSS with CSS Variables

## 📝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💖 Acknowledgments

- Built with love for the community
- Inspired by cute aesthetics and cozy vibes
- Special thanks to all contributors!

---

Made with 🌸 by the Femboard team
"@ | Set-Content -Path "README.md" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-07T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-07T10:00:00+07:00"
git add -A
git commit -m "Update README with comprehensive documentation"

# --- Commit 44: Add LICENSE ---
@"
MIT License

Copyright (c) 2026 Femboard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@ | Set-Content -Path "LICENSE" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-07T10:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-07T10:30:00+07:00"
git add -A
git commit -m "Add MIT LICENSE"

# --- Commit 45: Add contributing guidelines ---
@"
# Contributing to Femboard 💖

Thank you for your interest in contributing! We're excited to have you.

## Code of Conduct

Be kind, respectful, and inclusive. We're building a safe and welcoming community.

## How to Contribute

### Reporting Bugs
- Check existing issues first
- Include steps to reproduce
- Include browser/OS info

### Suggesting Features
- Open an issue with the `feature` label
- Describe the use case
- Be open to discussion

### Pull Requests
1. Fork the repo
2. Create a feature branch from `dev`
3. Write clean, documented code
4. Test your changes
5. Submit a PR to `dev`

## Development Setup

``````bash
git clone https://github.com/yourusername/femboard.git
cd femboard
npm install
cp .env.example .env
npm run seed
npm run dev
``````

## Style Guide

- Use consistent indentation (2 spaces)
- Follow existing code patterns
- Comment complex logic
- Use descriptive variable names

## Questions?

Open an issue or reach out to the maintainers. We're happy to help! 🌸
"@ | Set-Content -Path "CONTRIBUTING.md" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-07T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-07T11:00:00+07:00"
git add -A
git commit -m "Add contributing guidelines"

# Merge fix/minor-improvements into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-04-08T09:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-08T09:00:00+07:00"
git merge fix/minor-improvements --no-ff -m "Merge fix/minor-improvements into dev"

# ============================================================
# FINAL: Merge dev into main
# ============================================================
git checkout main
$env:GIT_AUTHOR_DATE = "2026-04-09T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-09T10:00:00+07:00"
git merge dev --no-ff -m "Merge dev into main - v0.1.0 release"

# Tag the release
$env:GIT_AUTHOR_DATE = "2026-04-09T10:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-09T10:30:00+07:00"
git tag -a v0.1.0 -m "v0.1.0 - Initial release of Femboard"

# Switch back to dev for future development
git checkout dev

# Clean up environment variables
Remove-Item Env:\GIT_AUTHOR_DATE
Remove-Item Env:\GIT_COMMITTER_DATE

Write-Host "Phase 6 complete! All done!" -ForegroundColor Green
Write-Host ""
Write-Host "=== Femboard Git History Summary ===" -ForegroundColor Cyan
Write-Host "Branches created:" -ForegroundColor Yellow
git branch -a
Write-Host ""
Write-Host "Commit count:" -ForegroundColor Yellow
git log --oneline --all | Measure-Object -Line
Write-Host ""
Write-Host "Recent commits:" -ForegroundColor Yellow
git log --oneline --graph --all -n 30
