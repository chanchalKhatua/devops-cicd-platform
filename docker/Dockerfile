# ==========================================
# Stage 1 - Build React Application
# ==========================================
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files first for better Docker layer caching
COPY frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy application source code
COPY frontend/ .

# Build the production-ready React application
RUN npm run build


# ==========================================
# Stage 2 - Serve React Application
# ==========================================
FROM nginx:alpine

# Copy only the compiled React application
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose Nginx HTTP port
EXPOSE 80

# Keep Nginx running in the foreground
CMD ["nginx", "-g", "daemon off;"]
