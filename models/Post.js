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
    return db.prepare(
      SELECT p.*, u.username, u.display_name, u.avatar_url
      FROM posts p
      JOIN users u ON u.id = p.user_id
      WHERE p.id = ?
    ).get(id);
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
    return db.prepare(
      SELECT p.*, t.title as thread_title, b.slug as board_slug
      FROM posts p
      JOIN threads t ON t.id = p.thread_id
      JOIN boards b ON b.id = t.board_id
      WHERE p.user_id = ?
      ORDER BY p.created_at DESC
      LIMIT ?
    ).all(userId, limit);
  }
}

module.exports = Post;
