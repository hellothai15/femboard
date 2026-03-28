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
  console.log(Femboard is running on http://localhost:);
});

module.exports = app;

