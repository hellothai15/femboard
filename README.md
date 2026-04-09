# Femboard ๐ธ

A cute and cozy web forum for the femboy community! Built with love and pastels.

![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)
![Express](https://img.shields.io/badge/Express-4.x-blue?logo=express)
![License](https://img.shields.io/badge/License-MIT-pink)

## โจ Features

- ๐’ฌ **Discussion Boards** - Multiple themed categories for every interest
- ๐‘ค **User Profiles** - Customizable profiles with avatar uploads
- ๐จ **Cute Pastel Theme** - Gorgeous glassmorphism design with animations
- ๐“ฑ **Responsive Design** - Looks great on desktop, tablet, and mobile
- ๐”’ **Secure Auth** - bcrypt password hashing and session management
- ๐ก๏ธ **Safe Space** - Role-based moderation system

## ๐€ Getting Started

### Prerequisites

- Node.js 18+
- npm

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/femboard.git
cd femboard
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Seed the database:
```bash
npm run seed
```

5. Start the development server:
```bash
npm run dev
```

6. Open http://localhost:3000 in your browser ๐ธ

## ๐“ Project Structure

```
femboard/
โ”โ”€โ”€ config/          # Database configuration
โ”โ”€โ”€ middleware/       # Auth middleware
โ”โ”€โ”€ models/          # Data models (User, Board, Thread, Post)
โ”โ”€โ”€ public/          # Static assets
โ”   โ”โ”€โ”€ css/         # Stylesheets
โ”   โ”โ”€โ”€ js/          # Client-side JavaScript
โ”   โ””โ”€โ”€ uploads/     # User-uploaded files
โ”โ”€โ”€ routes/          # Express route handlers
โ”โ”€โ”€ scripts/         # Utility scripts
โ”โ”€โ”€ views/           # EJS templates
โ”   โ”โ”€โ”€ auth/        # Login & register pages
โ”   โ”โ”€โ”€ boards/      # Board & thread pages
โ”   โ”โ”€โ”€ partials/    # Reusable template parts
โ”   โ””โ”€โ”€ profile/     # User profile pages
โ””โ”€โ”€ server.js        # App entry point
```

## ๐จ Board Categories

| Board | Description |
|-------|-------------|
| /cute/ | Cute Outfits & Fashion |
| /beauty/ | Beauty & Skincare |
| /fit/ | Fitness & Health |
| /tech/ | Technology |
| /random/ | Random Discussion |
| /support/ | Support & Advice |
| /creative/ | Creative Corner |
| /gaming/ | Gaming |

## ๐ ๏ธ Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** SQLite3 (via better-sqlite3)
- **Templates:** EJS
- **Auth:** bcryptjs + express-session
- **Styling:** Custom CSS with CSS Variables

## ๐“ Contributing

1. Fork the repository
2. Create your feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request

## ๐“ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ๐’– Acknowledgments

- Built with love for the community
- Inspired by cute aesthetics and cozy vibes
- Special thanks to all contributors!

---

Made with ๐ธ by the Femboard team
