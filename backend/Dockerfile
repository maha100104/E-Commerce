# Stage 1: Build NestJS application
FROM node:20-alpine AS builder

WORKDIR /app

# Install build dependencies for native modules (e.g. bcrypt)
RUN apk add --no-cache python3 make g++

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@9 --activate

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install all dependencies
RUN pnpm install

# Copy source code
COPY . .

# Build production bundle
RUN pnpm run build

# Prune devDependencies for production runtime
RUN pnpm prune --prod

# Stage 2: Production Runtime
FROM node:20-alpine AS runner

WORKDIR /app

# Copy production node_modules and built application from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package.json ./

# Expose backend port
EXPOSE 3000

ENV PORT=3000

# Start NestJS production server
CMD ["node", "dist/src/main.js"]
