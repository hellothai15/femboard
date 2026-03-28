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
    return db.prepare(
      SELECT t.*, 
        u.username, u.display_name, u.avatar_url,
        b.name as board_name, b.slug as board_slug
      FROM threads t
      JOIN users u ON u.id = t.user_id
      JOIN boards b ON b.id = t.board_id
      WHERE t.id = ?
    ).get(id);
  }

  static getPosts(threadId, page = 1, limit = 25) {
    const db = getDatabase();
    const offset = (page - 1) * limit;
    
    return db.prepare(
      SELECT p.*, 
        u.username, u.display_name, u.avatar_url, u.role,
        u.created_at as user_joined
      FROM posts p
      JOIN users u ON u.id = p.user_id
      WHERE p.thread_id = ?
      ORDER BY p.created_at ASC
      LIMIT ? OFFSET ?
    ).all(threadId, limit, offset);
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
