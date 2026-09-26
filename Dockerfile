# Build: pasang seluruh dependensi lalu build frontend.
FROM node:24-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime: hanya dependensi produksi + hasil build.
FROM node:24-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV SIMAS_DATA_DIR=/data
ENV PORT=3001

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/dist ./dist
COPY server ./server
COPY public ./public

RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 3001
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3001)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server/index.js"]
