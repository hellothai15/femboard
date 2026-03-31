const { getDatabase } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create(username, email, password) {
    const db = getDatabase();
    const passwordHash = await bcrypt.hash(password, 12);
    
    const result = db.prepare(
      'INSERT INTO users (username, email, password_hash, display_name) VALUES (?, ?, ?, ?)'
    ).run(username, email.toLowerCase(), passwordHash, username);
    
    return result.lastInsertRowid;
  }

  static getById(id) {
    const db = getDatabase();
    return db.prepare(
      'SELECT id, username, email, display_name, avatar_url, bio, role, created_at FROM users WHERE id = ?'
    ).get(id);
  }

  static getByUsername(username) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM users WHERE username = ?'
    ).get(username);
  }

  static getByEmail(email) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM users WHERE email = ?'
    ).get(email.toLowerCase());
  }

  static async verifyPassword(user, password) {
    return bcrypt.compare(password, user.password_hash);
  }

  static updateProfile(id, { displayName, bio }) {
    const db = getDatabase();
    db.prepare(
      'UPDATE users SET display_name = ?, bio = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?'
    ).run(displayName, bio, id);
  }

  static updateAvatar(id, avatarUrl) {
    const db = getDatabase();
    db.prepare(
      'UPDATE users SET avatar_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?'
    ).run(avatarUrl, id);
  }

  static getStats(id) {
    const db = getDatabase();
    const postCount = db.prepare(
      'SELECT COUNT(*) as count FROM posts WHERE user_id = ?'
    ).get(id).count;
    
    const threadCount = db.prepare(
      'SELECT COUNT(*) as count FROM threads WHERE user_id = ?'
    ).get(id).count;

    return { postCount, threadCount };
  }

  static search(query) {
    const db = getDatabase();
    return db.prepare(
      SELECT id, username, display_name, avatar_url, role 
       FROM users WHERE username LIKE ? OR display_name LIKE ? LIMIT 20
    ).all(%%, %%);
  }
}

module.exports = User;
