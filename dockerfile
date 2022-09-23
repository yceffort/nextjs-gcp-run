# install
FROM node:16-alpine AS dependencies
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# build
FROM node:16-alpine AS build
WORKDIR /app
COPY . .

COPY --from=dependencies /app/node_modules ./node_modules

RUN npm run build

# run
FROM node:16-alpine AS release
WORKDIR /app

ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --from=build --chown=nextjs:nodejs /app/.next ./.next
COPY --from=build --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nextjs:nodejs /app/package.json ./package.json

USER nextjs
EXPOSE 3000

RUN ls -al
RUN pwd

CMD ["npm", "start"]