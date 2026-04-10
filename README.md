# Femboard 🌸

A cute and cozy web forum built for the femboy community. Designed with pastel aesthetics, a welcoming vibe, and everything you need to hang out and be yourself.

![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)
![Express](https://img.shields.io/badge/Express-4.x-blue?logo=express)
![License](https://img.shields.io/badge/License-MIT-pink)

## ✨ Features

- 💬 **Discussion Boards** — Browse and post across multiple topic-based boards
- 👤 **User Profiles** — Create your profile, upload an avatar, and show off your bio
- 🎨 **Cute Pastel Theme** — Glassmorphism UI with smooth animations and pastel colors
- 📱 **Responsive** — Works on desktop, tablet, and mobile out of the box
- 🔒 **Secure Authentication** — Passwords are hashed with bcrypt, sessions managed server-side
- 🛡️ **Moderation Tools** — Role-based access with admin and moderator support

## 🚀 Getting Started

### What You Need

- Node.js 18 or higher
- npm

### Setup

Clone the repo and install everything:
```bash
git clone https://github.com/yourusername/femboard.git
cd femboard
npm install
```

Copy the example environment file and tweak it if needed:
```bash
cp .env.example .env
```

Seed the database with default boards:
```bash
npm run seed
```

Start the dev server:
```bash
npm run dev
```

Then head over to [http://localhost:3000](http://localhost:3000) and you're good to go 🌸

### Running with Docker

If you prefer Docker, just build and run:
```bash
docker build -t femboard .
docker run -p 3000:3000 femboard
```

## 📁 Project Structure

```
femboard/
├── config/          # Database setup
├── middleware/       # Auth checks and permission guards
├── models/          # Data models — User, Board, Thread, Post
├── public/
│   ├── css/         # Stylesheets (main, auth, board, profile, responsive)
│   ├── js/          # Client-side scripts
│   └── uploads/     # Uploaded avatars go here
├── routes/          # Express route handlers
├── scripts/         # Seed script and utilities
├── views/           # EJS templates
│   ├── auth/        # Login and registration
│   ├── boards/      # Board listing, threads, posts
│   ├── partials/    # Shared layout (navbar, header, footer)
│   └── profile/     # Profile view and edit
└── server.js        # Main entry point
```

## 🎨 Boards

| Board | What's it for? |
|-------|----------------|
| `/cute/` | Outfit sharing and fashion advice |
| `/beauty/` | Skincare tips, makeup, and self-care |
| `/fit/` | Workouts, nutrition, and staying healthy |
| `/tech/` | Tech talk, programming, and gadgets |
| `/random/` | Whatever's on your mind |
| `/support/` | A safe space to vent, ask for advice, or just talk |
| `/creative/` | Art, music, writing — show off your creative side |
| `/gaming/` | Video games, tabletop, and everything in between |

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js |
| Framework | Express.js |
| Database | SQLite3 (via better-sqlite3) |
| Templates | EJS |
| Auth | bcryptjs + express-session |
| Styling | Custom CSS with CSS variables |

## 📝 Contributing

We'd love contributions! Here's the quick version:

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/something-cool`)
3. Make your changes and commit them (`git commit -m 'Add something cool'`)
4. Push your branch (`git push origin feature/something-cool`)
5. Open a Pull Request

Check out [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## 📄 License

MIT — see [LICENSE](LICENSE) for the full text.

## 💖 Acknowledgments

Built with love for the community. Inspired by cute aesthetics and the desire to make a cozy little corner of the internet. Thanks to everyone who contributes!

---

Made with 🌸 by the Femboard team
