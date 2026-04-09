const { getDatabase } = require('../config/database');

class Board {
  static getAll() {
    const db = getDatabase();
    return db.prepare(
      SELECT b.*, 
        COUNT(DISTINCT t.id) as thread_count,
        COUNT(DISTINCT p.id) as post_count,
        MAX(p.created_at) as latest_post_at
      FROM boards b
      LEFT JOIN threads t ON t.board_id = b.id
      LEFT JOIN posts p ON p.thread_id = t.id
      GROUP BY b.id
      ORDER BY b.sort_order ASC
    ).all();
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
    
    return db.prepare(
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
    ).all(boardId, limit, offset);
  }

  static getThreadCount(boardId) {
    const db = getDatabase();
    return db.prepare('SELECT COUNT(*) as count FROM threads WHERE board_id = ?').get(boardId).count;
  }
}

module.exports = Board;
