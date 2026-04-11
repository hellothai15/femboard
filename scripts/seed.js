const { getDatabase, closeDatabase } = require('../config/database');

function seed() {
  const db = getDatabase();
  
  console.log('Seeding database...');

  // Default boards
  const boards = [
    { slug: 'cute', name: 'Cute Outfits', description: 'Share your cutest outfits and get fashion advice!', icon: 'C', color: '#FF69B4' },
    { slug: 'beauty', name: 'Beauty & Skincare', description: 'Skincare routines, makeup tips, and beauty hacks', icon: 'B', color: '#E91E9B' },
    { slug: 'fit', name: 'Fitness & Health', description: 'Workout routines, nutrition, and staying healthy', icon: 'H', color: '#9B59B6' },
    { slug: 'tech', name: 'Technology', description: 'Tech discussions, programming, and gadgets', icon: 'T', color: '#3498DB' },
    { slug: 'random', name: 'Random', description: 'Anything goes! Chat about whatever you want', icon: 'R', color: '#F39C12' },
    { slug: 'support', name: 'Support & Advice', description: 'A safe space for support, advice, and encouragement', icon: 'S', color: '#E74C3C' },
    { slug: 'creative', name: 'Creative Corner', description: 'Art, music, writing, and other creative works', icon: 'A', color: '#2ECC71' },
    { slug: 'gaming', name: 'Gaming', description: 'Video games, tabletop games, and everything in between', icon: 'G', color: '#8E44AD' }
  ];

  const insertBoard = db.prepare(
    'INSERT OR IGNORE INTO boards (slug, name, description, icon, color, sort_order) VALUES (?, ?, ?, ?, ?, ?)'
  );

  boards.forEach((board, index) => {
    insertBoard.run(board.slug, board.name, board.description, board.icon, board.color, index);
  });

  console.log('Boards seeded successfully!');
  console.log('Database seeding complete!');
  
  closeDatabase();
}

seed();
