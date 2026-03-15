# Femboard Setup - Phase 4: User Auth System
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\aruch\Work\temp\clash\femboard"

# ============================================================
# FEATURE: User Authentication
# ============================================================
git checkout dev
git checkout -b feature/user-auth

# --- Commit 27: User model ---
@"
const { getDatabase } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create(username, email, password) {
    const db = getDatabase();
    const passwordHash = await bcrypt.hash(password, 12);
    
    const result = db.prepare(
      'INSERT INTO users (username, email, password_hash, display_name) VALUES (?, ?, ?, ?)'
    ).run(username, email.toLowerCase(), passwordHash, username);
    
    return result.lastInsertRowid;
  }

  static getById(id) {
    const db = getDatabase();
    return db.prepare(
      'SELECT id, username, email, display_name, avatar_url, bio, role, created_at FROM users WHERE id = ?'
    ).get(id);
  }

  static getByUsername(username) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM users WHERE username = ?'
    ).get(username);
  }

  static getByEmail(email) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM users WHERE email = ?'
    ).get(email.toLowerCase());
  }

  static async verifyPassword(user, password) {
    return bcrypt.compare(password, user.password_hash);
  }

  static updateProfile(id, { displayName, bio }) {
    const db = getDatabase();
    db.prepare(
      'UPDATE users SET display_name = ?, bio = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?'
    ).run(displayName, bio, id);
  }

  static updateAvatar(id, avatarUrl) {
    const db = getDatabase();
    db.prepare(
      'UPDATE users SET avatar_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?'
    ).run(avatarUrl, id);
  }

  static getStats(id) {
    const db = getDatabase();
    const postCount = db.prepare(
      'SELECT COUNT(*) as count FROM posts WHERE user_id = ?'
    ).get(id).count;
    
    const threadCount = db.prepare(
      'SELECT COUNT(*) as count FROM threads WHERE user_id = ?'
    ).get(id).count;

    return { postCount, threadCount };
  }

  static search(query) {
    const db = getDatabase();
    return db.prepare(
      `SELECT id, username, display_name, avatar_url, role 
       FROM users WHERE username LIKE ? OR display_name LIKE ? LIMIT 20`
    ).all(`%${query}%`, `%${query}%`);
  }
}

module.exports = User;
"@ | Set-Content -Path "models/User.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-29T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-29T10:00:00+07:00"
git add -A
git commit -m "Add User model with password hashing"

# --- Commit 28: Auth middleware ---
@"
// Authentication middleware

function requireAuth(req, res, next) {
  if (!req.session.user) {
    if (req.headers['content-type'] === 'application/json') {
      return res.status(401).json({ error: 'Authentication required' });
    }
    return res.redirect('/auth/login?redirect=' + encodeURIComponent(req.originalUrl));
  }
  next();
}

function requireAdmin(req, res, next) {
  if (!req.session.user || req.session.user.role !== 'admin') {
    if (req.headers['content-type'] === 'application/json') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    return res.status(403).render('404', { title: '403 - Forbidden' });
  }
  next();
}

function requireModerator(req, res, next) {
  if (!req.session.user || !['admin', 'moderator'].includes(req.session.user.role)) {
    if (req.headers['content-type'] === 'application/json') {
      return res.status(403).json({ error: 'Moderator access required' });
    }
    return res.status(403).render('404', { title: '403 - Forbidden' });
  }
  next();
}

function guestOnly(req, res, next) {
  if (req.session.user) {
    return res.redirect('/');
  }
  next();
}

module.exports = { requireAuth, requireAdmin, requireModerator, guestOnly };
"@ | Set-Content -Path "middleware/auth.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-29T12:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-29T12:00:00+07:00"
git add -A
git commit -m "Add authentication middleware helpers"

# --- Commit 29: Auth routes ---
@"
const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { guestOnly } = require('../middleware/auth');

// Login page
router.get('/login', guestOnly, (req, res) => {
  res.render('auth/login', {
    title: 'Login - Femboard',
    error: null,
    extraCss: 'auth.css',
    extraJs: false
  });
});

// Login handler
router.post('/login', guestOnly, async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.render('auth/login', {
        title: 'Login - Femboard',
        error: 'Please fill in all fields',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    const user = User.getByUsername(username);
    
    if (!user || !(await User.verifyPassword(user, password))) {
      return res.render('auth/login', {
        title: 'Login - Femboard',
        error: 'Invalid username or password',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    // Set session
    req.session.user = {
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      avatar_url: user.avatar_url,
      role: user.role
    };

    const redirect = req.query.redirect || '/';
    res.redirect(redirect);
  } catch (err) {
    console.error('Login error:', err);
    res.render('auth/login', {
      title: 'Login - Femboard',
      error: 'An error occurred. Please try again.',
      extraCss: 'auth.css',
      extraJs: false
    });
  }
});

// Register page
router.get('/register', guestOnly, (req, res) => {
  res.render('auth/register', {
    title: 'Sign Up - Femboard',
    error: null,
    extraCss: 'auth.css',
    extraJs: false
  });
});

// Register handler
router.post('/register', guestOnly, async (req, res) => {
  try {
    const { username, email, password, confirmPassword } = req.body;

    // Validation
    if (!username || !email || !password || !confirmPassword) {
      return res.render('auth/register', {
        title: 'Sign Up - Femboard',
        error: 'Please fill in all fields',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    if (password !== confirmPassword) {
      return res.render('auth/register', {
        title: 'Sign Up - Femboard',
        error: 'Passwords do not match',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    if (password.length < 8) {
      return res.render('auth/register', {
        title: 'Sign Up - Femboard',
        error: 'Password must be at least 8 characters',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    if (!/^[a-zA-Z0-9_]{3,20}$/.test(username)) {
      return res.render('auth/register', {
        title: 'Sign Up - Femboard',
        error: 'Username must be 3-20 characters (letters, numbers, underscores only)',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    // Check if username or email already exists
    if (User.getByUsername(username)) {
      return res.render('auth/register', {
        title: 'Sign Up - Femboard',
        error: 'Username already taken',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    if (User.getByEmail(email)) {
      return res.render('auth/register', {
        title: 'Sign Up - Femboard',
        error: 'Email already registered',
        extraCss: 'auth.css',
        extraJs: false
      });
    }

    // Create user
    const userId = await User.create(username, email, password);
    const newUser = User.getById(userId);

    // Auto-login
    req.session.user = {
      id: newUser.id,
      username: newUser.username,
      display_name: newUser.display_name,
      avatar_url: newUser.avatar_url,
      role: newUser.role
    };

    res.redirect('/');
  } catch (err) {
    console.error('Registration error:', err);
    res.render('auth/register', {
      title: 'Sign Up - Femboard',
      error: 'An error occurred. Please try again.',
      extraCss: 'auth.css',
      extraJs: false
    });
  }
});

// Logout
router.get('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) console.error('Logout error:', err);
    res.redirect('/');
  });
});

module.exports = router;
"@ | Set-Content -Path "routes/auth.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-30T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-30T10:00:00+07:00"
git add -A
git commit -m "Add authentication routes for login, register, and logout"

# --- Commit 30: Auth views ---
New-Item -ItemType Directory -Path "views/auth" -Force | Out-Null

@"
<%- include('../partials/header', { extraCss: 'auth.css', extraJs: false }) %>

<section class="auth-page">
  <div class="auth-container">
    <div class="auth-card">
      <div class="auth-header">
        <span class="auth-icon">🌸</span>
        <h1>Welcome Back!</h1>
        <p>Log in to your Femboard account</p>
      </div>

      <% if (error) { %>
        <div class="alert alert-error">
          <span>⚠️</span> <%= error %>
        </div>
      <% } %>

      <form action="/auth/login" method="POST" class="auth-form">
        <div class="form-group">
          <label for="username">Username</label>
          <div class="input-wrapper">
            <span class="input-icon">👤</span>
            <input type="text" id="username" name="username" required placeholder="Your username" autocomplete="username">
          </div>
        </div>
        
        <div class="form-group">
          <label for="password">Password</label>
          <div class="input-wrapper">
            <span class="input-icon">🔒</span>
            <input type="password" id="password" name="password" required placeholder="Your password" autocomplete="current-password">
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block">Log In 💖</button>
      </form>

      <div class="auth-footer">
        <p>Don't have an account? <a href="/auth/register">Sign up here!</a></p>
      </div>
    </div>
  </div>
</section>

<%- include('../partials/footer_partial', { extraJs: false }) %>
"@ | Set-Content -Path "views/auth/login.ejs" -Encoding UTF8

@"
<%- include('../partials/header', { extraCss: 'auth.css', extraJs: false }) %>

<section class="auth-page">
  <div class="auth-container">
    <div class="auth-card">
      <div class="auth-header">
        <span class="auth-icon">✨</span>
        <h1>Join Femboard!</h1>
        <p>Create your account and join our community</p>
      </div>

      <% if (error) { %>
        <div class="alert alert-error">
          <span>⚠️</span> <%= error %>
        </div>
      <% } %>

      <form action="/auth/register" method="POST" class="auth-form">
        <div class="form-group">
          <label for="username">Username</label>
          <div class="input-wrapper">
            <span class="input-icon">👤</span>
            <input type="text" id="username" name="username" required minlength="3" maxlength="20" pattern="[a-zA-Z0-9_]+" placeholder="Choose a username" autocomplete="username">
          </div>
          <span class="form-hint">3-20 characters, letters, numbers, and underscores</span>
        </div>
        
        <div class="form-group">
          <label for="email">Email</label>
          <div class="input-wrapper">
            <span class="input-icon">📧</span>
            <input type="email" id="email" name="email" required placeholder="your@email.com" autocomplete="email">
          </div>
        </div>
        
        <div class="form-group">
          <label for="password">Password</label>
          <div class="input-wrapper">
            <span class="input-icon">🔒</span>
            <input type="password" id="password" name="password" required minlength="8" placeholder="Min 8 characters" autocomplete="new-password">
          </div>
        </div>
        
        <div class="form-group">
          <label for="confirmPassword">Confirm Password</label>
          <div class="input-wrapper">
            <span class="input-icon">🔒</span>
            <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Confirm your password" autocomplete="new-password">
          </div>
        </div>

        <button type="submit" class="btn btn-primary btn-block">Create Account 🌸</button>
      </form>

      <div class="auth-footer">
        <p>Already have an account? <a href="/auth/login">Log in here!</a></p>
      </div>
    </div>
  </div>
</section>

<%- include('../partials/footer_partial', { extraJs: false }) %>
"@ | Set-Content -Path "views/auth/register.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-30T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-30T14:00:00+07:00"
git add -A
git commit -m "Add login and registration views"

# --- Commit 31: Auth CSS ---
@"
/* =============================================
   Authentication page styles
   ============================================= */

.auth-page {
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-2xl);
  background: var(--gradient-soft);
}

.auth-container {
  width: 100%;
  max-width: 440px;
}

.auth-card {
  background: white;
  border-radius: var(--radius-xl);
  padding: var(--space-2xl);
  box-shadow: var(--shadow-lg);
  animation: slideUp 0.5s ease-out;
}

.auth-header {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.auth-icon {
  font-size: 3rem;
  display: inline-block;
  margin-bottom: var(--space-md);
  animation: bounce-soft 2s ease-in-out infinite;
}

.auth-header h1 {
  font-size: 1.8rem;
  margin-bottom: var(--space-xs);
}

.auth-header p {
  color: var(--neutral-500);
}

.auth-form .form-group {
  margin-bottom: var(--space-lg);
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 12px;
  font-size: 1.1rem;
  pointer-events: none;
  z-index: 1;
}

.input-wrapper input {
  width: 100%;
  padding: 0.8rem 1rem 0.8rem 2.5rem;
  border: 2px solid var(--neutral-200);
  border-radius: var(--radius-md);
  font-family: var(--font-primary);
  font-size: 0.95rem;
  transition: all var(--transition-fast);
  background: var(--neutral-50);
}

.input-wrapper input:focus {
  outline: none;
  border-color: var(--pink-400);
  box-shadow: 0 0 0 3px rgba(255, 105, 180, 0.15);
  background: white;
}

.form-hint {
  display: block;
  margin-top: var(--space-xs);
  font-size: 0.8rem;
  color: var(--neutral-400);
}

.btn-block {
  width: 100%;
  padding: 0.9rem;
  font-size: 1rem;
  margin-top: var(--space-md);
}

.alert {
  padding: 0.8rem 1rem;
  border-radius: var(--radius-md);
  margin-bottom: var(--space-lg);
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.alert-error {
  background: #FEF2F2;
  color: #DC2626;
  border: 1px solid #FECACA;
}

.alert-success {
  background: #F0FDF4;
  color: #16A34A;
  border: 1px solid #BBF7D0;
}

.auth-footer {
  text-align: center;
  margin-top: var(--space-xl);
  padding-top: var(--space-lg);
  border-top: 1px solid var(--neutral-200);
  font-size: 0.9rem;
  color: var(--neutral-500);
}

.auth-footer a {
  color: var(--pink-600);
  font-weight: 600;
}

.auth-footer a:hover {
  text-decoration: underline;
}
"@ | Set-Content -Path "public/css/auth.css" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-31T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-31T10:00:00+07:00"
git add -A
git commit -m "Style authentication pages with cute theme"

# --- Commit 32: Wire auth routes ---
$serverContent = Get-Content -Path "server.js" -Raw
$serverContent = $serverContent.Replace(
"const boardRoutes = require('./routes/boards');",
"const boardRoutes = require('./routes/boards');
const authRoutes = require('./routes/auth');"
)
$serverContent = $serverContent.Replace(
"app.use('/boards', boardRoutes);",
"app.use('/boards', boardRoutes);
app.use('/auth', authRoutes);"
)
Set-Content -Path "server.js" -Value $serverContent -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-31T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-31T11:00:00+07:00"
git add -A
git commit -m "Wire up auth routes in server.js"

# Merge feature/user-auth into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-03-31T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-31T14:00:00+07:00"
git merge feature/user-auth --no-ff -m "Merge feature/user-auth into dev"

Write-Host "Phase 4 complete!" -ForegroundColor Green
