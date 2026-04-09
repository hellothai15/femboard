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
    cb(null, vatar--);
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
    title: ${profileUser.display_name || profileUser.username} - Femboard,
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
    return res.redirect(/profile//edit);
  }

  const avatarUrl = /uploads/;
  User.updateAvatar(req.session.user.id, avatarUrl);
  req.session.user.avatar_url = avatarUrl;

  res.redirect(/profile//edit);
});

module.exports = router;
