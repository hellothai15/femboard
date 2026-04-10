FROM node:18-alpine

WORKDIR /app

# Install dependencies first for better caching
COPY package.json ./
RUN npm install --production

# Copy the rest of the app
COPY . .

# Seed the database with default boards
RUN node scripts/seed.js

# Expose the port
EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "server.js"]
