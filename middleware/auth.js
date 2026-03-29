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
