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
