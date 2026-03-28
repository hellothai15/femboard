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
    title: // -  - Femboard,
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
    title: ${thread.title} - Femboard,
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

  res.redirect(/boards//thread/);
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

  res.redirect(/boards//thread/);
});

module.exports = router;
