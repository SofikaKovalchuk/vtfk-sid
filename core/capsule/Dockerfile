FROM rust:1.79-alpine AS build
WORKDIR /app
RUN apk add --no-cache musl-dev

# Кешування: спочатку маніфести залежностей (Рівень 2)
COPY ../sid/Cargo.toml ../sid/Cargo.lock* ./
RUN mkdir src && echo "fn main() {}" > src/main.rs \
    && cargo build --release --target x86_64-unknown-linux-musl \
    && rm -rf src

# Реальний код копіюється останнім
COPY ../sid/src ./src
RUN touch src/main.rs && cargo build --release --target x86_64-unknown-linux-musl

# Фінальний шар: порожній образ scratch (Рівень 3)
FROM scratch
COPY --from=build /app/target/x86_64-unknown-linux-musl/release/sid /sid
ENTRYPOINT ["/sid"]
