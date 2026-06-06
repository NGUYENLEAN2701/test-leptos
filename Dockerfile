# --- Stage 1: Build ứng dụng Leptos bằng Trunk ---
FROM rust:slim AS builder

RUN apt-get update && apt-get upgrade -y && apt-get install -y libssl-dev pkg-config git openssl curl
RUN rustup toolchain install nightly
RUN rustup default nightly
RUN rustup target add wasm32-unknown-unknown

# Cài đặt trunk phiên bản mới nhất
RUN cargo install --locked trunk

WORKDIR /app
COPY . .

# Build dự án ra thư mục dist
RUN trunk build --release

# --- Stage 2: Dùng Caddy để phục vụ file tĩnh ---
FROM caddy:latest-alpine

# Copy file từ stage 1 sang stage 2
COPY --from=builder /app/dist /usr/share/caddy
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080