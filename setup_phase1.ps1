# Femboard Project Setup - Phase 1: Init + Dev branch + Initial Setup + Landing Page
$ErrorActionPreference = "Stop"
$projectDir = "c:\Users\aruch\Work\temp\clash\femboard"
Set-Location $projectDir

# ============================================================
# PHASE 1: Initialize repo and main branch
# ============================================================
git init
git checkout -b main

# --- Commit 1: Initial commit ---
@"
# Femboard 🌸

A cute and cozy web forum for the femboy community! Built with love and pastels.

## Features (Planned)
- 💬 Discussion boards with multiple categories
- 👤 User profiles with avatars
- 🎨 Cute pastel theme
- 📱 Responsive design

## Tech Stack
- **Backend:** Node.js + Express
- **Database:** SQLite3
- **Frontend:** Vanilla HTML/CSS/JS
- **Template Engine:** EJS

## Getting Started

``````bash
npm install
npm run dev
``````

## License

MIT
"@ | Set-Content -Path "README.md" -Encoding UTF8

@"
node_modules/
.env
*.db
*.sqlite
.DS_Store
Thumbs.db
logs/
*.log
dist/
.vscode/
"@ | Set-Content -Path ".gitignore" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-15T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-15T10:00:00+07:00"
git add -A
git commit -m "Initial commit - add README and .gitignore"

# --- Commit 2: Add package.json ---
@"
{
  "name": "femboard",
  "version": "0.1.0",
  "description": "A cute web forum for the femboy community",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "seed": "node scripts/seed.js"
  },
  "keywords": ["forum", "board", "community", "femboy"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "ejs": "^3.1.9",
    "better-sqlite3": "^9.4.3",
    "express-session": "^1.17.3",
    "bcryptjs": "^2.4.3",
    "multer": "^1.4.5-lts.1",
    "dotenv": "^16.3.1",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
"@ | Set-Content -Path "package.json" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-15T10:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-15T10:30:00+07:00"
git add -A
git commit -m "Add package.json with project dependencies"

# ============================================================
# Create dev branch
# ============================================================
git checkout -b dev

# ============================================================
# FEATURE: Initial Server Setup
# ============================================================
git checkout -b feature/initial-setup

# --- Commit 3: Basic Express server ---
New-Item -ItemType Directory -Path "config" -Force | Out-Null
New-Item -ItemType Directory -Path "routes" -Force | Out-Null
New-Item -ItemType Directory -Path "models" -Force | Out-Null
New-Item -ItemType Directory -Path "middleware" -Force | Out-Null
New-Item -ItemType Directory -Path "public" -Force | Out-Null
New-Item -ItemType Directory -Path "public/css" -Force | Out-Null
New-Item -ItemType Directory -Path "public/js" -Force | Out-Null
New-Item -ItemType Directory -Path "public/uploads" -Force | Out-Null
New-Item -ItemType Directory -Path "views" -Force | Out-Null
New-Item -ItemType Directory -Path "views/partials" -Force | Out-Null
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null

@"
require('dotenv').config();
const express = require('express');
const path = require('path');
const helmet = require('helmet');
const morgan = require('morgan');
const session = require('express-session');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false
}));

// Logging
app.use(morgan('dev'));

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET || 'femboard-secret-key-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Make user available to all templates
app.use((req, res, next) => {
  res.locals.user = req.session.user || null;
  next();
});

// Routes (will be added later)
app.get('/', (req, res) => {
  res.render('index', { title: 'Femboard - Home' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).render('404', { title: '404 - Not Found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`Femboard is running on http://localhost:${PORT}`);
});

module.exports = app;
"@ | Set-Content -Path "server.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-16T09:15:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-16T09:15:00+07:00"
git add -A
git commit -m "Add Express server with basic middleware setup"

# --- Commit 4: Database configuration ---
@"
const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'femboard.db');

let db;

function getDatabase() {
  if (!db) {
    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = ON');
    initializeDatabase();
  }
  return db;
}

function initializeDatabase() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      display_name TEXT,
      avatar_url TEXT DEFAULT '/uploads/default-avatar.png',
      bio TEXT DEFAULT '',
      role TEXT DEFAULT 'member',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS boards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      slug TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      icon TEXT DEFAULT '💬',
      color TEXT DEFAULT '#FF69B4',
      sort_order INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS threads (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      board_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      is_pinned BOOLEAN DEFAULT 0,
      is_locked BOOLEAN DEFAULT 0,
      view_count INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (board_id) REFERENCES boards(id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      thread_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      content TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (thread_id) REFERENCES threads(id),
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
  `);
}

function closeDatabase() {
  if (db) {
    db.close();
    db = null;
  }
}

module.exports = { getDatabase, closeDatabase };
"@ | Set-Content -Path "config/database.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-16T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-16T11:00:00+07:00"
git add -A
git commit -m "Add SQLite database configuration and schema"

# --- Commit 5: Environment config ---
@"
PORT=3000
NODE_ENV=development
SESSION_SECRET=change-this-to-a-random-string
DB_PATH=./femboard.db
"@ | Set-Content -Path ".env.example" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-16T11:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-16T11:30:00+07:00"
git add -A
git commit -m "Add environment configuration example"

# --- Commit 6: Seed script ---
@"
const { getDatabase, closeDatabase } = require('../config/database');

function seed() {
  const db = getDatabase();
  
  console.log('Seeding database...');

  // Default boards
  const boards = [
    { slug: 'cute', name: 'Cute Outfits', description: 'Share your cutest outfits and get fashion advice!', icon: '👗', color: '#FF69B4' },
    { slug: 'beauty', name: 'Beauty & Skincare', description: 'Skincare routines, makeup tips, and beauty hacks', icon: '💄', color: '#E91E9B' },
    { slug: 'fit', name: 'Fitness & Health', description: 'Workout routines, nutrition, and staying healthy', icon: '💪', color: '#9B59B6' },
    { slug: 'tech', name: 'Technology', description: 'Tech discussions, programming, and gadgets', icon: '💻', color: '#3498DB' },
    { slug: 'random', name: 'Random', description: 'Anything goes! Chat about whatever you want', icon: '🎲', color: '#F39C12' },
    { slug: 'support', name: 'Support & Advice', description: 'A safe space for support, advice, and encouragement', icon: '💖', color: '#E74C3C' },
    { slug: 'creative', name: 'Creative Corner', description: 'Art, music, writing, and other creative works', icon: '🎨', color: '#2ECC71' },
    { slug: 'gaming', name: 'Gaming', description: 'Video games, tabletop games, and everything in between', icon: '🎮', color: '#8E44AD' }
  ];

  const insertBoard = db.prepare(
    'INSERT OR IGNORE INTO boards (slug, name, description, icon, color, sort_order) VALUES (?, ?, ?, ?, ?, ?)'
  );

  boards.forEach((board, index) => {
    insertBoard.run(board.slug, board.name, board.description, board.icon, board.color, index);
  });

  console.log('Boards seeded successfully!');
  console.log('Database seeding complete!');
  
  closeDatabase();
}

seed();
"@ | Set-Content -Path "scripts/seed.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-16T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-16T14:00:00+07:00"
git add -A
git commit -m "Add database seed script with default boards"

# Merge feature/initial-setup into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-03-16T15:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-16T15:00:00+07:00"
git merge feature/initial-setup --no-ff -m "Merge feature/initial-setup into dev"

# ============================================================
# FEATURE: Landing Page
# ============================================================
git checkout -b feature/landing-page

# --- Commit 7: Base layout partial ---
@"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Femboard - A cute and cozy community forum for femboys">
  <title><%= typeof title !== 'undefined' ? title : 'Femboard' %></title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/css/style.css">
  <% if (typeof extraCss !== 'undefined' && extraCss) { %>
    <link rel="stylesheet" href="/css/<%= extraCss %>">
  <% } %>
</head>
<body>
  <%- include('partials/navbar') %>
  <main>
"@ | Set-Content -Path "views/partials/header.ejs" -Encoding UTF8

@"
  </main>
  <%- include('partials/footer') %>
  <script src="/js/app.js"></script>
  <% if (typeof extraJs !== 'undefined' && extraJs) { %>
    <script src="/js/<%= extraJs %>"></script>
  <% } %>
</body>
</html>
"@ | Set-Content -Path "views/partials/footer_partial.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-18T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-18T10:00:00+07:00"
git add -A
git commit -m "Add base HTML layout partials"

# --- Commit 8: Navbar partial ---
@"
<nav class="navbar">
  <div class="nav-container">
    <a href="/" class="nav-logo">
      <span class="logo-icon">🌸</span>
      <span class="logo-text">Femboard</span>
    </a>
    
    <div class="nav-links">
      <a href="/" class="nav-link">Home</a>
      <a href="/boards" class="nav-link">Boards</a>
      <% if (user) { %>
        <a href="/profile/<%= user.username %>" class="nav-link">
          <img src="<%= user.avatar_url %>" alt="avatar" class="nav-avatar">
          <%= user.display_name || user.username %>
        </a>
        <a href="/auth/logout" class="nav-link nav-btn btn-outline">Logout</a>
      <% } else { %>
        <a href="/auth/login" class="nav-link nav-btn btn-outline">Login</a>
        <a href="/auth/register" class="nav-link nav-btn btn-primary">Sign Up</a>
      <% } %>
    </div>

    <button class="nav-toggle" aria-label="Toggle navigation">
      <span></span>
      <span></span>
      <span></span>
    </button>
  </div>
</nav>
"@ | Set-Content -Path "views/partials/navbar.ejs" -Encoding UTF8

@"
<footer class="footer">
  <div class="footer-container">
    <div class="footer-brand">
      <span class="logo-icon">🌸</span>
      <span class="logo-text">Femboard</span>
      <p class="footer-tagline">A cozy corner of the internet</p>
    </div>
    <div class="footer-links">
      <div class="footer-column">
        <h4>Community</h4>
        <a href="/boards">Boards</a>
        <a href="/rules">Rules</a>
        <a href="/faq">FAQ</a>
      </div>
      <div class="footer-column">
        <h4>About</h4>
        <a href="/about">About Us</a>
        <a href="/contact">Contact</a>
        <a href="/privacy">Privacy Policy</a>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2026 Femboard. Made with 💖</p>
    </div>
  </div>
</footer>
"@ | Set-Content -Path "views/partials/footer.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-18T11:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-18T11:30:00+07:00"
git add -A
git commit -m "Add navbar and footer partials"

# --- Commit 9: Landing page view ---
@"
<%- include('partials/header', { extraCss: false, extraJs: false }) %>

<section class="hero">
  <div class="hero-content">
    <div class="hero-sparkles">✨</div>
    <h1 class="hero-title">Welcome to <span class="gradient-text">Femboard</span></h1>
    <p class="hero-subtitle">A cute and cozy community where everyone is welcome! Share outfits, get advice, make friends, and be yourself 💖</p>
    <div class="hero-buttons">
      <a href="/boards" class="btn btn-primary btn-lg">Browse Boards</a>
      <a href="/auth/register" class="btn btn-outline btn-lg">Join Us ✨</a>
    </div>
    <div class="hero-stats">
      <div class="stat">
        <span class="stat-number">0</span>
        <span class="stat-label">Members</span>
      </div>
      <div class="stat">
        <span class="stat-number">0</span>
        <span class="stat-label">Posts</span>
      </div>
      <div class="stat">
        <span class="stat-number">8</span>
        <span class="stat-label">Boards</span>
      </div>
    </div>
  </div>
  <div class="hero-decoration">
    <div class="floating-element fe-1">🌸</div>
    <div class="floating-element fe-2">💖</div>
    <div class="floating-element fe-3">✨</div>
    <div class="floating-element fe-4">🦋</div>
    <div class="floating-element fe-5">🌈</div>
  </div>
</section>

<section class="features">
  <h2 class="section-title">Why You'll Love It Here 💕</h2>
  <div class="features-grid">
    <div class="feature-card">
      <div class="feature-icon">🛡️</div>
      <h3>Safe Space</h3>
      <p>A welcoming, moderated community where you can be yourself without judgment.</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">👗</div>
      <h3>Fashion Corner</h3>
      <p>Share your cutest outfits, get style advice, and discover new looks!</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">💬</div>
      <h3>Active Discussions</h3>
      <p>Join conversations about everything from skincare to gaming to life advice.</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">🎨</div>
      <h3>Creative Community</h3>
      <p>Share your art, music, writing, and other creative projects with friends.</p>
    </div>
  </div>
</section>

<section class="boards-preview">
  <h2 class="section-title">Popular Boards 🌟</h2>
  <div class="boards-preview-grid">
    <a href="/boards/cute" class="board-preview-card" style="--card-accent: #FF69B4">
      <span class="board-icon">👗</span>
      <span class="board-name">Cute Outfits</span>
    </a>
    <a href="/boards/beauty" class="board-preview-card" style="--card-accent: #E91E9B">
      <span class="board-icon">💄</span>
      <span class="board-name">Beauty</span>
    </a>
    <a href="/boards/gaming" class="board-preview-card" style="--card-accent: #8E44AD">
      <span class="board-icon">🎮</span>
      <span class="board-name">Gaming</span>
    </a>
    <a href="/boards/random" class="board-preview-card" style="--card-accent: #F39C12">
      <span class="board-icon">🎲</span>
      <span class="board-name">Random</span>
    </a>
  </div>
  <a href="/boards" class="btn btn-outline">View All Boards →</a>
</section>

<section class="cta">
  <div class="cta-content">
    <h2>Ready to Join? 🌈</h2>
    <p>Create your account in seconds and start connecting with an amazing community!</p>
    <a href="/auth/register" class="btn btn-primary btn-lg">Create Account 💖</a>
  </div>
</section>

<%- include('partials/footer_partial', { extraJs: false }) %>
"@ | Set-Content -Path "views/index.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-18T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-18T14:00:00+07:00"
git add -A
git commit -m "Add landing page with hero section and features"

# --- Commit 10: 404 page ---
@"
<%- include('partials/header', { extraCss: false, extraJs: false }) %>

<section class="error-page">
  <div class="error-content">
    <div class="error-emoji">😿</div>
    <h1 class="error-code">404</h1>
    <h2 class="error-message">Page Not Found</h2>
    <p>Oops! The page you're looking for doesn't exist or has been moved.</p>
    <a href="/" class="btn btn-primary">Go Home 🏠</a>
  </div>
</section>

<%- include('partials/footer_partial', { extraJs: false }) %>
"@ | Set-Content -Path "views/404.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-18T15:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-18T15:00:00+07:00"
git add -A
git commit -m "Add 404 error page"

# Merge feature/landing-page into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-03-18T16:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-18T16:00:00+07:00"
git merge feature/landing-page --no-ff -m "Merge feature/landing-page into dev"

Write-Host "Phase 1 complete!" -ForegroundColor Green
