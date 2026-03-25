FROM node:18-alpine

WORKDIR /app

COPY package.json vite.config.js index.html ./
COPY src ./src

RUN npm install

EXPOSE 3000

CMD ["npm", "run", "dev"]