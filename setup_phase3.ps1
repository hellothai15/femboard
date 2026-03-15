# Femboard Setup - Phase 3: Board System
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\aruch\Work\temp\clash\femboard"

# ============================================================
# FEATURE: Board System
# ============================================================
git checkout dev
git checkout -b feature/board-system

# --- Commit 18: Board model ---
@"
const { getDatabase } = require('../config/database');

class Board {
  static getAll() {
    const db = getDatabase();
    return db.prepare(`
      SELECT b.*, 
        COUNT(DISTINCT t.id) as thread_count,
        COUNT(DISTINCT p.id) as post_count,
        MAX(p.created_at) as latest_post_at
      FROM boards b
      LEFT JOIN threads t ON t.board_id = b.id
      LEFT JOIN posts p ON p.thread_id = t.id
      GROUP BY b.id
      ORDER BY b.sort_order ASC
    `).all();
  }

  static getBySlug(slug) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM boards WHERE slug = ?').get(slug);
  }

  static getById(id) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM boards WHERE id = ?').get(id);
  }

  static getThreads(boardId, page = 1, limit = 20) {
    const db = getDatabase();
    const offset = (page - 1) * limit;
    
    return db.prepare(`
      SELECT t.*, 
        u.username, u.display_name, u.avatar_url,
        COUNT(p.id) as reply_count,
        MAX(p.created_at) as last_reply_at
      FROM threads t
      JOIN users u ON u.id = t.user_id
      LEFT JOIN posts p ON p.thread_id = t.id
      WHERE t.board_id = ?
      GROUP BY t.id
      ORDER BY t.is_pinned DESC, t.updated_at DESC
      LIMIT ? OFFSET ?
    `).all(boardId, limit, offset);
  }

  static getThreadCount(boardId) {
    const db = getDatabase();
    return db.prepare('SELECT COUNT(*) as count FROM threads WHERE board_id = ?').get(boardId).count;
  }
}

module.exports = Board;
"@ | Set-Content -Path "models/Board.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-25T09:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-25T09:30:00+07:00"
git add -A
git commit -m "Add Board model with query methods"

# --- Commit 19: Thread model ---
@"
const { getDatabase } = require('../config/database');

class Thread {
  static create(boardId, userId, title) {
    const db = getDatabase();
    const result = db.prepare(
      'INSERT INTO threads (board_id, user_id, title) VALUES (?, ?, ?)'
    ).run(boardId, userId, title);
    return result.lastInsertRowid;
  }

  static getById(id) {
    const db = getDatabase();
    return db.prepare(`
      SELECT t.*, 
        u.username, u.display_name, u.avatar_url,
        b.name as board_name, b.slug as board_slug
      FROM threads t
      JOIN users u ON u.id = t.user_id
      JOIN boards b ON b.id = t.board_id
      WHERE t.id = ?
    `).get(id);
  }

  static getPosts(threadId, page = 1, limit = 25) {
    const db = getDatabase();
    const offset = (page - 1) * limit;
    
    return db.prepare(`
      SELECT p.*, 
        u.username, u.display_name, u.avatar_url, u.role,
        u.created_at as user_joined
      FROM posts p
      JOIN users u ON u.id = p.user_id
      WHERE p.thread_id = ?
      ORDER BY p.created_at ASC
      LIMIT ? OFFSET ?
    `).all(threadId, limit, offset);
  }

  static getPostCount(threadId) {
    const db = getDatabase();
    return db.prepare('SELECT COUNT(*) as count FROM posts WHERE thread_id = ?').get(threadId).count;
  }

  static incrementViews(id) {
    const db = getDatabase();
    db.prepare('UPDATE threads SET view_count = view_count + 1 WHERE id = ?').run(id);
  }

  static updateTimestamp(id) {
    const db = getDatabase();
    db.prepare('UPDATE threads SET updated_at = CURRENT_TIMESTAMP WHERE id = ?').run(id);
  }

  static togglePin(id) {
    const db = getDatabase();
    db.prepare('UPDATE threads SET is_pinned = NOT is_pinned WHERE id = ?').run(id);
  }

  static toggleLock(id) {
    const db = getDatabase();
    db.prepare('UPDATE threads SET is_locked = NOT is_locked WHERE id = ?').run(id);
  }
}

module.exports = Thread;
"@ | Set-Content -Path "models/Thread.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-25T11:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-25T11:00:00+07:00"
git add -A
git commit -m "Add Thread model with CRUD operations"

# --- Commit 20: Post model ---
@"
const { getDatabase } = require('../config/database');

class Post {
  static create(threadId, userId, content) {
    const db = getDatabase();
    const result = db.prepare(
      'INSERT INTO posts (thread_id, user_id, content) VALUES (?, ?, ?)'
    ).run(threadId, userId, content);
    return result.lastInsertRowid;
  }

  static getById(id) {
    const db = getDatabase();
    return db.prepare(`
      SELECT p.*, u.username, u.display_name, u.avatar_url
      FROM posts p
      JOIN users u ON u.id = p.user_id
      WHERE p.id = ?
    `).get(id);
  }

  static update(id, content) {
    const db = getDatabase();
    db.prepare(
      'UPDATE posts SET content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?'
    ).run(content, id);
  }

  static delete(id) {
    const db = getDatabase();
    db.prepare('DELETE FROM posts WHERE id = ?').run(id);
  }

  static getRecentByUser(userId, limit = 10) {
    const db = getDatabase();
    return db.prepare(`
      SELECT p.*, t.title as thread_title, b.slug as board_slug
      FROM posts p
      JOIN threads t ON t.id = p.thread_id
      JOIN boards b ON b.id = t.board_id
      WHERE p.user_id = ?
      ORDER BY p.created_at DESC
      LIMIT ?
    `).all(userId, limit);
  }
}

module.exports = Post;
"@ | Set-Content -Path "models/Post.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-25T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-25T14:00:00+07:00"
git add -A
git commit -m "Add Post model with CRUD and user queries"

# --- Commit 21: Board routes ---
@"
const express = require('express');
const router = express.Router();
const Board = require('../models/Board');
const Thread = require('../models/Thread');
const Post = require('../models/Post');

// Board listing page
router.get('/', (req, res) => {
  const boards = Board.getAll();
  res.render('boards/index', {
    title: 'Boards - Femboard',
    boards,
    extraCss: 'board.css',
    extraJs: 'board.js'
  });
});

// Individual board page
router.get('/:slug', (req, res) => {
  const board = Board.getBySlug(req.params.slug);
  
  if (!board) {
    return res.status(404).render('404', { title: '404 - Board Not Found' });
  }

  const page = parseInt(req.query.page) || 1;
  const threads = Board.getThreads(board.id, page);
  const totalThreads = Board.getThreadCount(board.id);
  const totalPages = Math.ceil(totalThreads / 20);

  res.render('boards/board', {
    title: `/${board.slug}/ - ${board.name} - Femboard`,
    board,
    threads,
    page,
    totalPages,
    extraCss: 'board.css',
    extraJs: 'board.js'
  });
});

// View thread
router.get('/:slug/thread/:id', (req, res) => {
  const thread = Thread.getById(req.params.id);
  
  if (!thread) {
    return res.status(404).render('404', { title: '404 - Thread Not Found' });
  }

  Thread.incrementViews(thread.id);

  const page = parseInt(req.query.page) || 1;
  const posts = Thread.getPosts(thread.id, page);
  const totalPosts = Thread.getPostCount(thread.id);
  const totalPages = Math.ceil(totalPosts / 25);

  res.render('boards/thread', {
    title: `${thread.title} - Femboard`,
    thread,
    posts,
    page,
    totalPages,
    extraCss: 'board.css',
    extraJs: 'board.js'
  });
});

// Create new thread (POST)
router.post('/:slug/new', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ error: 'You must be logged in to create a thread' });
  }

  const board = Board.getBySlug(req.params.slug);
  if (!board) {
    return res.status(404).json({ error: 'Board not found' });
  }

  const { title, content } = req.body;

  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required' });
  }

  if (title.length < 3 || title.length > 200) {
    return res.status(400).json({ error: 'Title must be between 3 and 200 characters' });
  }

  const threadId = Thread.create(board.id, req.session.user.id, title);
  Post.create(threadId, req.session.user.id, content);

  res.redirect(`/boards/${board.slug}/thread/${threadId}`);
});

// Reply to thread (POST)
router.post('/:slug/thread/:id/reply', (req, res) => {
  if (!req.session.user) {
    return res.status(401).json({ error: 'You must be logged in to reply' });
  }

  const thread = Thread.getById(req.params.id);
  if (!thread) {
    return res.status(404).json({ error: 'Thread not found' });
  }

  if (thread.is_locked) {
    return res.status(403).json({ error: 'This thread is locked' });
  }

  const { content } = req.body;
  if (!content || content.trim().length === 0) {
    return res.status(400).json({ error: 'Content is required' });
  }

  Post.create(thread.id, req.session.user.id, content);
  Thread.updateTimestamp(thread.id);

  res.redirect(`/boards/${thread.board_slug}/thread/${thread.id}`);
});

module.exports = router;
"@ | Set-Content -Path "routes/boards.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-26T09:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-26T09:00:00+07:00"
git add -A
git commit -m "Add board routes with thread creation and replies"

# --- Commit 22: Board views ---
New-Item -ItemType Directory -Path "views/boards" -Force | Out-Null

@"
<%- include('../partials/header', { extraCss: 'board.css', extraJs: 'board.js' }) %>

<section class="boards-page">
  <div class="container">
    <div class="page-header">
      <h1>📋 All Boards</h1>
      <p class="page-description">Pick a board and start chatting!</p>
    </div>

    <div class="boards-grid">
      <% boards.forEach(board => { %>
        <a href="/boards/<%= board.slug %>" class="board-card" style="--board-color: <%= board.color %>">
          <div class="board-card-icon"><%= board.icon %></div>
          <div class="board-card-info">
            <h3>/<%= board.slug %>/ - <%= board.name %></h3>
            <p><%= board.description %></p>
          </div>
          <div class="board-card-stats">
            <span class="board-stat">
              <strong><%= board.thread_count || 0 %></strong> threads
            </span>
            <span class="board-stat">
              <strong><%= board.post_count || 0 %></strong> posts
            </span>
          </div>
        </a>
      <% }); %>
    </div>
  </div>
</section>

<%- include('../partials/footer_partial', { extraJs: 'board.js' }) %>
"@ | Set-Content -Path "views/boards/index.ejs" -Encoding UTF8

@"
<%- include('../partials/header', { extraCss: 'board.css', extraJs: 'board.js' }) %>

<section class="board-page">
  <div class="container">
    <div class="breadcrumb">
      <a href="/">Home</a> / <a href="/boards">Boards</a> / <span>/<%= board.slug %>/</span>
    </div>

    <div class="page-header" style="--board-color: <%= board.color %>">
      <div class="board-title-row">
        <span class="board-page-icon"><%= board.icon %></span>
        <div>
          <h1>/<%= board.slug %>/ - <%= board.name %></h1>
          <p class="page-description"><%= board.description %></p>
        </div>
      </div>
      <% if (user) { %>
        <button class="btn btn-primary" onclick="openNewThreadModal()">
          ✏️ New Thread
        </button>
      <% } %>
    </div>

    <div class="thread-list">
      <% if (threads.length === 0) { %>
        <div class="empty-state">
          <div class="empty-icon">🌸</div>
          <h3>No threads yet!</h3>
          <p>Be the first to start a discussion in this board.</p>
        </div>
      <% } else { %>
        <% threads.forEach(thread => { %>
          <a href="/boards/<%= board.slug %>/thread/<%= thread.id %>" class="thread-card">
            <div class="thread-meta">
              <% if (thread.is_pinned) { %><span class="badge badge-pinned">📌 Pinned</span><% } %>
              <% if (thread.is_locked) { %><span class="badge badge-locked">🔒 Locked</span><% } %>
            </div>
            <h3 class="thread-title"><%= thread.title %></h3>
            <div class="thread-info">
              <img src="<%= thread.avatar_url %>" alt="" class="thread-avatar">
              <span class="thread-author"><%= thread.display_name || thread.username %></span>
              <span class="thread-replies">💬 <%= thread.reply_count || 0 %> replies</span>
              <span class="thread-views">👁️ <%= thread.view_count %> views</span>
            </div>
          </a>
        <% }); %>
      <% } %>
    </div>

    <% if (totalPages > 1) { %>
      <div class="pagination">
        <% for(let i = 1; i <= totalPages; i++) { %>
          <a href="?page=<%= i %>" class="page-link <%= i === page ? 'active' : '' %>"><%= i %></a>
        <% } %>
      </div>
    <% } %>
  </div>
</section>

<!-- New Thread Modal -->
<div class="modal" id="newThreadModal">
  <div class="modal-backdrop" onclick="closeNewThreadModal()"></div>
  <div class="modal-content">
    <div class="modal-header">
      <h2>✏️ New Thread in /<%= board.slug %>/</h2>
      <button class="modal-close" onclick="closeNewThreadModal()">&times;</button>
    </div>
    <form action="/boards/<%= board.slug %>/new" method="POST">
      <div class="form-group">
        <label for="title">Thread Title</label>
        <input type="text" id="title" name="title" required minlength="3" maxlength="200" placeholder="What's on your mind?">
      </div>
      <div class="form-group">
        <label for="content">Content</label>
        <textarea id="content" name="content" required rows="6" placeholder="Write your post here..."></textarea>
      </div>
      <div class="form-actions">
        <button type="button" class="btn btn-outline" onclick="closeNewThreadModal()">Cancel</button>
        <button type="submit" class="btn btn-primary">Create Thread 🌸</button>
      </div>
    </form>
  </div>
</div>

<%- include('../partials/footer_partial', { extraJs: 'board.js' }) %>
"@ | Set-Content -Path "views/boards/board.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-26T11:30:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-26T11:30:00+07:00"
git add -A
git commit -m "Add board listing and individual board views"

# --- Commit 23: Thread view ---
@"
<%- include('../partials/header', { extraCss: 'board.css', extraJs: 'board.js' }) %>

<section class="thread-page">
  <div class="container">
    <div class="breadcrumb">
      <a href="/">Home</a> / <a href="/boards">Boards</a> / <a href="/boards/<%= thread.board_slug %>">/<%= thread.board_slug %>/</a> / <span><%= thread.title %></span>
    </div>

    <div class="thread-header">
      <h1><%= thread.title %></h1>
      <div class="thread-header-meta">
        <span>Started by <strong><%= thread.display_name || thread.username %></strong></span>
        <span>👁️ <%= thread.view_count %> views</span>
        <% if (thread.is_locked) { %><span class="badge badge-locked">🔒 Locked</span><% } %>
      </div>
    </div>

    <div class="posts-list">
      <% posts.forEach((post, index) => { %>
        <div class="post-card" id="post-<%= post.id %>">
          <div class="post-sidebar">
            <img src="<%= post.avatar_url %>" alt="<%= post.username %>" class="post-avatar">
            <a href="/profile/<%= post.username %>" class="post-username"><%= post.display_name || post.username %></a>
            <span class="post-role role-<%= post.role %>"><%= post.role %></span>
          </div>
          <div class="post-body">
            <div class="post-header">
              <span class="post-number">#<%= index + 1 + ((page - 1) * 25) %></span>
              <span class="post-date"><%= new Date(post.created_at).toLocaleString() %></span>
            </div>
            <div class="post-content">
              <%- post.content.replace(/\n/g, '<br>') %>
            </div>
            <div class="post-actions">
              <% if (user) { %>
                <button class="post-action-btn" onclick="quotePost(<%= post.id %>)">💬 Quote</button>
              <% } %>
            </div>
          </div>
        </div>
      <% }); %>
    </div>

    <% if (totalPages > 1) { %>
      <div class="pagination">
        <% for(let i = 1; i <= totalPages; i++) { %>
          <a href="?page=<%= i %>" class="page-link <%= i === page ? 'active' : '' %>"><%= i %></a>
        <% } %>
      </div>
    <% } %>

    <% if (user && !thread.is_locked) { %>
      <div class="reply-section">
        <h3>💬 Post a Reply</h3>
        <form action="/boards/<%= thread.board_slug %>/thread/<%= thread.id %>/reply" method="POST">
          <div class="form-group">
            <textarea name="content" id="replyContent" required rows="4" placeholder="Write your reply..."></textarea>
          </div>
          <button type="submit" class="btn btn-primary">Post Reply 🌸</button>
        </form>
      </div>
    <% } else if (!user) { %>
      <div class="login-prompt">
        <p>💖 <a href="/auth/login">Log in</a> or <a href="/auth/register">sign up</a> to reply!</p>
      </div>
    <% } %>
  </div>
</section>

<%- include('../partials/footer_partial', { extraJs: 'board.js' }) %>
"@ | Set-Content -Path "views/boards/thread.ejs" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-27T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-27T10:00:00+07:00"
git add -A
git commit -m "Add thread view with posts and reply form"

# --- Commit 24: Board CSS ---
@"
/* =============================================
   Board-specific styles
   ============================================= */

.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 var(--space-xl);
}

.breadcrumb {
  padding: var(--space-md) 0;
  font-size: 0.85rem;
  color: var(--neutral-500);
}

.breadcrumb a {
  color: var(--pink-500);
  font-weight: 600;
}

.breadcrumb a:hover {
  text-decoration: underline;
}

.page-header {
  margin-bottom: var(--space-2xl);
  padding: var(--space-xl) 0;
  border-bottom: 2px solid var(--neutral-200);
}

.page-header h1 {
  font-size: 2rem;
  margin-bottom: var(--space-sm);
}

.page-description {
  color: var(--neutral-500);
  font-size: 1rem;
}

.board-title-row {
  display: flex;
  align-items: center;
  gap: var(--space-lg);
}

.board-page-icon {
  font-size: 3rem;
}

/* ---------- Board Cards ---------- */
.boards-page {
  padding: var(--space-2xl) 0;
}

.boards-grid {
  display: flex;
  flex-direction: column;
  gap: var(--space-md);
}

.board-card {
  display: flex;
  align-items: center;
  gap: var(--space-lg);
  padding: var(--space-lg);
  background: white;
  border-radius: var(--radius-md);
  border-left: 4px solid var(--board-color, var(--pink-500));
  box-shadow: var(--shadow-sm);
  transition: all var(--transition-base);
}

.board-card:hover {
  transform: translateX(4px);
  box-shadow: var(--shadow-md);
}

.board-card-icon {
  font-size: 2.5rem;
  flex-shrink: 0;
}

.board-card-info {
  flex: 1;
}

.board-card-info h3 {
  font-size: 1.1rem;
  margin-bottom: var(--space-xs);
}

.board-card-info p {
  color: var(--neutral-500);
  font-size: 0.9rem;
}

.board-card-stats {
  display: flex;
  gap: var(--space-lg);
  flex-shrink: 0;
}

.board-stat {
  text-align: center;
  font-size: 0.85rem;
  color: var(--neutral-500);
}

.board-stat strong {
  display: block;
  font-size: 1.1rem;
  color: var(--neutral-800);
}

/* ---------- Thread List ---------- */
.thread-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
}

.thread-card {
  display: block;
  padding: var(--space-lg);
  background: white;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
  transition: all var(--transition-base);
  border: 1px solid transparent;
}

.thread-card:hover {
  border-color: var(--pink-300);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.thread-meta {
  display: flex;
  gap: var(--space-sm);
  margin-bottom: var(--space-xs);
}

.badge {
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: var(--radius-full);
  font-weight: 600;
}

.badge-pinned {
  background: var(--pink-100);
  color: var(--pink-600);
}

.badge-locked {
  background: var(--neutral-200);
  color: var(--neutral-600);
}

.thread-title {
  font-size: 1.1rem;
  margin-bottom: var(--space-sm);
  color: var(--neutral-900);
}

.thread-info {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  font-size: 0.85rem;
  color: var(--neutral-500);
}

.thread-avatar {
  width: 24px;
  height: 24px;
  border-radius: var(--radius-full);
  border: 2px solid var(--pink-200);
}

.thread-author {
  font-weight: 600;
  color: var(--neutral-700);
}

/* ---------- Post Cards ---------- */
.thread-page {
  padding: var(--space-2xl) 0;
}

.thread-header {
  margin-bottom: var(--space-2xl);
  padding: var(--space-xl);
  background: var(--gradient-soft);
  border-radius: var(--radius-lg);
}

.thread-header h1 {
  font-size: 1.8rem;
  margin-bottom: var(--space-sm);
}

.thread-header-meta {
  display: flex;
  gap: var(--space-lg);
  color: var(--neutral-500);
  font-size: 0.9rem;
}

.posts-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-md);
  margin-bottom: var(--space-2xl);
}

.post-card {
  display: flex;
  background: white;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  border: 1px solid var(--neutral-200);
}

.post-sidebar {
  width: 160px;
  padding: var(--space-lg);
  background: var(--neutral-50);
  border-right: 1px solid var(--neutral-200);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-sm);
  flex-shrink: 0;
}

.post-avatar {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-lg);
  border: 3px solid var(--pink-200);
  object-fit: cover;
}

.post-username {
  font-weight: 700;
  font-size: 0.9rem;
  color: var(--pink-600);
  text-align: center;
}

.post-username:hover {
  text-decoration: underline;
}

.post-role {
  font-size: 0.75rem;
  padding: 2px 10px;
  border-radius: var(--radius-full);
  font-weight: 600;
}

.role-member {
  background: var(--blue-100);
  color: var(--blue-500);
}

.role-moderator {
  background: var(--purple-100);
  color: var(--purple-500);
}

.role-admin {
  background: var(--pink-100);
  color: var(--pink-600);
}

.post-body {
  flex: 1;
  padding: var(--space-lg);
  display: flex;
  flex-direction: column;
}

.post-header {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  color: var(--neutral-400);
  margin-bottom: var(--space-md);
  padding-bottom: var(--space-sm);
  border-bottom: 1px solid var(--neutral-200);
}

.post-number {
  font-weight: 700;
  color: var(--neutral-500);
}

.post-content {
  flex: 1;
  line-height: 1.7;
  color: var(--neutral-700);
}

.post-actions {
  margin-top: var(--space-md);
  padding-top: var(--space-sm);
  border-top: 1px solid var(--neutral-100);
}

.post-action-btn {
  font-size: 0.85rem;
  color: var(--neutral-500);
  padding: var(--space-xs) var(--space-sm);
  border-radius: var(--radius-sm);
  transition: all var(--transition-fast);
  cursor: pointer;
}

.post-action-btn:hover {
  background: var(--pink-100);
  color: var(--pink-600);
}

/* ---------- Reply Section ---------- */
.reply-section {
  background: white;
  border-radius: var(--radius-lg);
  padding: var(--space-xl);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--neutral-200);
}

.reply-section h3 {
  margin-bottom: var(--space-lg);
}

.login-prompt {
  text-align: center;
  padding: var(--space-xl);
  background: var(--gradient-soft);
  border-radius: var(--radius-lg);
}

.login-prompt a {
  color: var(--pink-600);
  font-weight: 600;
}

/* ---------- Empty State ---------- */
.empty-state {
  text-align: center;
  padding: var(--space-3xl);
  color: var(--neutral-500);
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: var(--space-md);
  animation: float 3s ease-in-out infinite;
}

/* ---------- Forms ---------- */
.form-group {
  margin-bottom: var(--space-lg);
}

.form-group label {
  display: block;
  margin-bottom: var(--space-sm);
  font-weight: 600;
  color: var(--neutral-700);
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid var(--neutral-200);
  border-radius: var(--radius-md);
  font-family: var(--font-primary);
  font-size: 0.95rem;
  transition: all var(--transition-fast);
  background: var(--neutral-50);
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--pink-400);
  box-shadow: 0 0 0 3px rgba(255, 105, 180, 0.15);
  background: white;
}

.form-group textarea {
  resize: vertical;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-md);
}

/* ---------- Modal ---------- */
.modal {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 200;
  align-items: center;
  justify-content: center;
}

.modal.active {
  display: flex;
}

.modal-backdrop {
  position: absolute;
  inset: 0;
  background: rgba(45, 31, 61, 0.5);
  backdrop-filter: blur(4px);
}

.modal-content {
  position: relative;
  background: white;
  border-radius: var(--radius-xl);
  padding: var(--space-2xl);
  max-width: 600px;
  width: 90%;
  box-shadow: var(--shadow-lg);
  animation: slideUp 0.3s ease-out;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-xl);
}

.modal-header h2 {
  font-size: 1.3rem;
}

.modal-close {
  font-size: 1.5rem;
  color: var(--neutral-500);
  cursor: pointer;
  padding: var(--space-xs);
}

/* ---------- Pagination ---------- */
.pagination {
  display: flex;
  justify-content: center;
  gap: var(--space-xs);
  padding: var(--space-xl) 0;
}

.page-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  font-weight: 600;
  color: var(--neutral-600);
  transition: all var(--transition-fast);
}

.page-link:hover {
  background: var(--pink-100);
  color: var(--pink-600);
}

.page-link.active {
  background: var(--gradient-primary);
  color: white;
}
"@ | Set-Content -Path "public/css/board.css" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-27T14:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-27T14:00:00+07:00"
git add -A
git commit -m "Add board, thread, and post styles"

# --- Commit 25: Board JS ---
@"
// Board-specific JavaScript

// Modal handling
function openNewThreadModal() {
  const modal = document.getElementById('newThreadModal');
  if (modal) {
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
  }
}

function closeNewThreadModal() {
  const modal = document.getElementById('newThreadModal');
  if (modal) {
    modal.classList.remove('active');
    document.body.style.overflow = '';
  }
}

// Quote post
function quotePost(postId) {
  const postContent = document.querySelector(`#post-${postId} .post-content`);
  const replyTextarea = document.getElementById('replyContent');
  
  if (postContent && replyTextarea) {
    const text = postContent.innerText.trim();
    const quotedText = text.split('\n').map(line => `> ${line}`).join('\n');
    replyTextarea.value += `${quotedText}\n\n`;
    replyTextarea.focus();
    replyTextarea.scrollIntoView({ behavior: 'smooth' });
  }
}

// Close modal on Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    closeNewThreadModal();
  }
});

// Character counter for thread title
document.addEventListener('DOMContentLoaded', () => {
  const titleInput = document.getElementById('title');
  if (titleInput) {
    titleInput.addEventListener('input', () => {
      const remaining = 200 - titleInput.value.length;
      const counter = titleInput.parentElement.querySelector('.char-counter');
      if (counter) {
        counter.textContent = `${remaining} characters remaining`;
        counter.style.color = remaining < 20 ? 'var(--error)' : 'var(--neutral-400)';
      }
    });
  }
});
"@ | Set-Content -Path "public/js/board.js" -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-27T16:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-27T16:00:00+07:00"
git add -A
git commit -m "Add board JavaScript for modals and interactions"

# --- Commit 26: Wire up board routes in server.js ---
$serverContent = Get-Content -Path "server.js" -Raw
$serverContent = $serverContent.Replace(
"// Routes (will be added later)
app.get('/', (req, res) => {
  res.render('index', { title: 'Femboard - Home' });
});",
"// Routes
const boardRoutes = require('./routes/boards');

app.get('/', (req, res) => {
  res.render('index', { title: 'Femboard - Home' });
});

app.use('/boards', boardRoutes);"
)
Set-Content -Path "server.js" -Value $serverContent -Encoding UTF8

$env:GIT_AUTHOR_DATE = "2026-03-28T09:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-28T09:00:00+07:00"
git add -A
git commit -m "Wire up board routes in server.js"

# Merge feature/board-system into dev
git checkout dev
$env:GIT_AUTHOR_DATE = "2026-03-28T10:00:00+07:00"
$env:GIT_COMMITTER_DATE = "2026-03-28T10:00:00+07:00"
git merge feature/board-system --no-ff -m "Merge feature/board-system into dev"

Write-Host "Phase 3 complete!" -ForegroundColor Green
