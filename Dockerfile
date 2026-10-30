FROM node:24-slim AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

ARG NEXT_PUBLIC_IMAGE_UPLOAD_MAX_SIZE

ENV NEXT_PUBLIC_IMAGE_UPLOAD_MAX_SIZE=${NEXT_PUBLIC_IMAGE_UPLOAD_MAX_SIZE}

RUN npm run build

FROM node:24-slim AS production

WORKDIR /app

COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/standalone ./

ENV HOSTNAME=0.0.0.0
ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", "server.js"]