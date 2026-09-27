# Stage 1: Build React application
FROM node:20-alpine AS builder

WORKDIR /app

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@9 --activate

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install dependencies
RUN pnpm install

# Copy source code
COPY . .

# Accept build-time API URL argument for Vite
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Build React static assets
RUN pnpm run build

# Stage 2: Production Web Server (Nginx)
FROM nginx:alpine AS runner

# Copy built static files to Nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy Nginx server configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
