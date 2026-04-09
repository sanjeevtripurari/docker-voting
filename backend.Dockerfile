FROM node:18-alpine

WORKDIR /app

COPY voting-app/backend/package*.json ./
RUN npm install --production

COPY voting-app/backend ./

EXPOSE 5000

CMD ["node", "server.js"]