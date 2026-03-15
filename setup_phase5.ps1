# Femboard Setup - Phase 5: User Profiles
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\aruch\Work\temp\clash\femboard"

# ============================================================
# FEATURE: User Profiles
# ============================================================
git checkout dev
git checkout -b feature/user-profiles

# --- Commit 33: Profile routes ---
@"
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const User = require('../models/User');
const Post = require('../models/Post');
const { requireAuth } = require('../middleware/auth');

// Multer config for avatar uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '..', 'public', 'uploads'));
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `avatar-${req.session.user.id}-${Date.now()}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB max
  fileFilter: (req, file, cb) => {
    const allowed = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowed.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// View profile
router.get('/:username', (req, res) => {
  const profileUser = User.getByUsername(req.params.username);
  
  if (!profileUser) {
    return res.status(404).render('404', { title: '404 - User Not Found' });
  }

  const stats = User.getStats(profileUser.id);
  const recentPosts = Post.getRecentByUser(profileUser.id, 10);

  res.render('profile/view', {
    title: `${profileUser.display_name || profileUser.username} - Femboard`,
    profileUser: {
      ...profileUser,
      password_hash: undefined // Don't expose password hash
    },
    stats,
    recentPosts,
    isOwnProfile: req.session.user && req.session.user.id === profileUser.id,
    extraCss: 'profile.css',
    extraJs: false
  });
});

// Edit profile page
router.get('/:username/edit', requireAuth, (req, res) => {
  if (req.session.user.username !== req.params.username) {
    return res.status(403).render('404', { title: '403 - Forbidden' });
  }

  const profileUser = User.getById(req.session.user.id);

  res.render('profile/edit', {
    title: 'Edit Profile - Femboard',
    profileUser,
    error: null,
    success: null,
    extraCss: 'profile.css',
    extraJs: false
  });
});

// Update profile
router.post('/:username/edit', requireAuth, (req, res) => {
  if (req.session.user.username !== req.params.username) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const { displayName, bio } = req.body;
  
  User.updateProfile(req.session.user.id, {
    displayName: displayName || req.session.user.username,
    bio: bio || ''
  });

  // Update session
  req.session.user.display_name = displayName || req.session.user.username;

  const profileUser = User.getById(req.session.user.id);

  res.render('profile/edit', {
    title: 'Edit Profile - Femboard',
    profileUser,
    error: null,
    success: 'Profile updated successfully!',
    extraCss: 'profile.css',
    extraJs: false
  });
});

// Upload avatar
router.post('/:username/avatar', requireAuth, upload.single('avatar'), (req, res) => {
  if (req.session.user.username !== req.params.username) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  if (!req.file) {
    return res.redirect(`/profile/${req.params.username}/edit`);
  }

  const avatarUrl = `/uploads/${req.file.filename}`;
  User.updateAvatar(req.session.user.id, avatarUrl);
  req.session.user.avatar_url = avatarUrl;

  res.redirect(`/profile/${req.params.username}/edit`);
});

module.exports = router;
"@ | Set-Content -Path "routes/profile.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-01T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-01T10:00:00+07:00"
git add -A
git commit -m "Add profile routes with avatar upload support"

# --- Commit 34: Profile views ---
New-Item -ItemType Directory -Path "views/profile" -Force | Out-Null

@"
<%- include('../partials/header', { extraCss: 'profile.css', extraJs: false }) %>

<section class="profile-page">
  <div class="container">
    <div class="profile-header">
      <div class="profile-cover"></div>
      <div class="profile-main">
        <div class="profile-avatar-wrapper">
          <img src="<%= profileUser.avatar_url %>" alt="<%= profileUser.username %>" class="profile-avatar">
          <% if (profileUser.role !== 'member') { %>
            <span class="profile-badge badge-<%= profileUser.role %>"><%= profileUser.role %></span>
          <% } %>
        </div>
        <div class="profile-info">
          <h1 class="profile-name"><%= profileUser.display_name || profileUser.username %></h1>
          <span class="profile-username">@<%= profileUser.username %></span>
          <% if (profileUser.bio) { %>
            <p class="profile-bio"><%= profileUser.bio %></p>
          <% } %>
          <div class="profile-meta">
            <span>📅 Joined <%= new Date(profileUser.created_at).toLocaleDateString('en-US', { year: 'numeric', month: 'long' }) %></span>
          </div>
        </div>
        <% if (isOwnProfile) { %>
          <a href="/profile/<%= profileUser.username %>/edit" class="btn btn-outline">✏️ Edit Profile</a>
        <% } %>
      </div>
    </div>

    <div class="profile-content">
      <div class="profile-stats-bar">
        <div class="profile-stat">
          <strong><%= stats.postCount %></strong>
          <span>Posts</span>
        </div>
        <div class="profile-stat">
          <strong><%= stats.threadCount %></strong>
          <span>Threads</span>
        </div>
      </div>

      <div class="profile-section">
        <h2>Recent Activity 📝</h2>
        <% if (recentPosts.length === 0) { %>
          <div class="empty-state">
            <div class="empty-icon">🌸</div>
            <p>No posts yet!</p>
          </div>
        <% } else { %>
          <div class="activity-list">
            <% recentPosts.forEach(post => { %>
              <a href="/boards/<%= post.board_slug %>/thread/<%= post.thread_id %>#post-<%= post.id %>" class="activity-card">
                <div class="activity-thread">
                  <span class="activity-label">replied in</span>
                  <strong><%= post.thread_title %></strong>
                </div>
                <p class="activity-preview"><%= post.content.substring(0, 150) %><%= post.content.length > 150 ? '...' : '' %></p>
                <span class="activity-date"><%= new Date(post.created_at).toLocaleDateString() %></span>
              </a>
            <% }); %>
          </div>
        <% } %>
      </div>
    </div>
  </div>
</section>

<%- include('../partials/footer_partial', { extraJs: false }) %>
"@ | Set-Content -Path "views/profile/view.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-02T09:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-02T09:00:00+07:00"
git add -A
git commit -m "Add profile view template"

# --- Commit 35: Profile edit view ---
@"
<%- include('../partials/header', { extraCss: 'profile.css', extraJs: false }) %>

<section class="profile-page">
  <div class="container">
    <div class="breadcrumb">
      <a href="/">Home</a> / <a href="/profile/<%= profileUser.username %>">Profile</a> / <span>Edit</span>
    </div>

    <div class="settings-card">
      <h1>✏️ Edit Profile</h1>

      <% if (error) { %>
        <div class="alert alert-error"><span>⚠️</span> <%= error %></div>
      <% } %>
      <% if (success) { %>
        <div class="alert alert-success"><span>✅</span> <%= success %></div>
      <% } %>

      <!-- Avatar Upload -->
      <div class="settings-section">
        <h2>Avatar</h2>
        <div class="avatar-upload">
          <img src="<%= profileUser.avatar_url %>" alt="Current avatar" class="current-avatar">
          <form action="/profile/<%= profileUser.username %>/avatar" method="POST" enctype="multipart/form-data" class="avatar-form">
            <input type="file" name="avatar" id="avatar" accept="image/*" class="file-input">
            <label for="avatar" class="btn btn-outline btn-sm">📷 Change Avatar</label>
            <button type="submit" class="btn btn-primary btn-sm">Upload</button>
          </form>
          <p class="form-hint">Max 2MB. JPG, PNG, GIF, or WebP.</p>
        </div>
      </div>

      <!-- Profile Info -->
      <div class="settings-section">
        <h2>Profile Information</h2>
        <form action="/profile/<%= profileUser.username %>/edit" method="POST">
          <div class="form-group">
            <label for="displayName">Display Name</label>
            <input type="text" id="displayName" name="displayName" value="<%= profileUser.display_name || '' %>" maxlength="50" placeholder="Your display name">
          </div>
          <div class="form-group">
            <label for="bio">Bio</label>
            <textarea id="bio" name="bio" rows="4" maxlength="500" placeholder="Tell everyone about yourself! 💖"><%= profileUser.bio || '' %></textarea>
            <span class="form-hint">Max 500 characters</span>
          </div>
          <button type="submit" class="btn btn-primary">Save Changes 💾</button>
        </form>
      </div>
    </div>
  </div>
</section>

<%- include('../partials/footer_partial', { extraJs: false }) %>
"@ | Set-Content -Path "views/profile/edit.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-02T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-02T11:00:00+07:00"
git add -A
git commit -m "Add profile edit view with avatar upload"

# --- Commit 36: Profile CSS ---
@"
/* =============================================
   Profile page styles
   ============================================= */

.profile-page {
  padding: var(--space-2xl) 0;
}

.profile-header {
  position: relative;
  margin-bottom: var(--space-2xl);
}

.profile-cover {
  height: 200px;
  background: var(--gradient-hero);
  border-radius: var(--radius-xl);
  position: relative;
  overflow: hidden;
}

.profile-cover::after {
  content: '';
  position: absolute;
  inset: 0;
  background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
}

.profile-main {
  display: flex;
  align-items: flex-end;
  gap: var(--space-xl);
  padding: 0 var(--space-xl);
  margin-top: -60px;
  position: relative;
  z-index: 2;
}

.profile-avatar-wrapper {
  position: relative;
  flex-shrink: 0;
}

.profile-avatar {
  width: 120px;
  height: 120px;
  border-radius: var(--radius-xl);
  border: 4px solid white;
  box-shadow: var(--shadow-md);
  object-fit: cover;
  background: var(--neutral-100);
}

.profile-badge {
  position: absolute;
  bottom: -4px;
  right: -4px;
  font-size: 0.7rem;
  padding: 2px 8px;
  border-radius: var(--radius-full);
  font-weight: 700;
  text-transform: uppercase;
  border: 2px solid white;
}

.badge-admin {
  background: var(--pink-500);
  color: white;
}

.badge-moderator {
  background: var(--purple-500);
  color: white;
}

.profile-info {
  flex: 1;
  padding-bottom: var(--space-md);
}

.profile-name {
  font-size: 1.8rem;
  margin-bottom: var(--space-xs);
}

.profile-username {
  color: var(--neutral-500);
  font-size: 1rem;
  font-weight: 600;
}

.profile-bio {
  margin-top: var(--space-md);
  color: var(--neutral-600);
  line-height: 1.6;
  max-width: 500px;
}

.profile-meta {
  margin-top: var(--space-sm);
  font-size: 0.85rem;
  color: var(--neutral-400);
}

.profile-content {
  margin-top: var(--space-xl);
}

.profile-stats-bar {
  display: flex;
  gap: var(--space-2xl);
  padding: var(--space-lg) var(--space-xl);
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  margin-bottom: var(--space-2xl);
}

.profile-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.profile-stat strong {
  font-size: 1.5rem;
  color: var(--pink-600);
  font-family: var(--font-heading);
}

.profile-stat span {
  font-size: 0.85rem;
  color: var(--neutral-500);
}

.profile-section {
  background: white;
  border-radius: var(--radius-lg);
  padding: var(--space-xl);
  box-shadow: var(--shadow-sm);
}

.profile-section h2 {
  font-size: 1.3rem;
  margin-bottom: var(--space-lg);
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
}

.activity-card {
  display: block;
  padding: var(--space-md);
  border-radius: var(--radius-md);
  border: 1px solid var(--neutral-200);
  transition: all var(--transition-fast);
}

.activity-card:hover {
  border-color: var(--pink-300);
  background: var(--pink-100);
}

.activity-label {
  font-size: 0.8rem;
  color: var(--neutral-400);
}

.activity-thread strong {
  color: var(--neutral-800);
  font-size: 0.95rem;
}

.activity-preview {
  color: var(--neutral-500);
  font-size: 0.85rem;
  margin-top: var(--space-xs);
  line-height: 1.5;
}

.activity-date {
  font-size: 0.8rem;
  color: var(--neutral-400);
  margin-top: var(--space-xs);
  display: block;
}

/* ---------- Settings / Edit ---------- */
.settings-card {
  background: white;
  border-radius: var(--radius-xl);
  padding: var(--space-2xl);
  box-shadow: var(--shadow-sm);
  max-width: 700px;
  margin: 0 auto;
}

.settings-card h1 {
  font-size: 1.8rem;
  margin-bottom: var(--space-2xl);
}

.settings-section {
  padding: var(--space-xl) 0;
  border-bottom: 1px solid var(--neutral-200);
}

.settings-section:last-child {
  border-bottom: none;
}

.settings-section h2 {
  font-size: 1.2rem;
  margin-bottom: var(--space-lg);
  color: var(--neutral-700);
}

.avatar-upload {
  display: flex;
  align-items: center;
  gap: var(--space-lg);
  flex-wrap: wrap;
}

.current-avatar {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-lg);
  border: 3px solid var(--pink-200);
  object-fit: cover;
}

.avatar-form {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.file-input {
  display: none;
}
"@ | Set-Content -Path "public/css/profile.css" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-03T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-03T10:00:00+07:00"
git add -A
git commit -m "Add profile page styles"

# --- Commit 37: Wire profile routes ---
$serverContent = Get-Content -Path "server.js" -Raw
$serverContent = $serverContent.Replace(
"const authRoutes = require('./routes/auth');",
"const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');"
)
$serverContent = $serverContent.Replace(
"app.use('/auth', authRoutes);",
"app.use('/auth', authRoutes);
app.use('/profile', profileRoutes);"
)
Set-Content -Path "server.js" -Value $serverContent -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-04-03T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-03T11:00:00+07:00"
git add -A
git commit -m "Wire up profile routes in server.js"

# Merge feature/user-profiles into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-04-03T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-04-03T14:00:00+07:00"
git merge feature/user-profiles --no-ff -m "Merge feature/user-profiles into dev"

Write-Host "Phase 5 complete!" -ForegroundColor Green
