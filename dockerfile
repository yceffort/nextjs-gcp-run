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

COPY --from=build /app/.next ./.next
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]