# --- Base Image ---
# Menggunakan versi terbaru n8n
# FROM n8nio/n8n:latest
FROM n8nio/n8n:1.75.2-alpine

# --- Masuk sebagai Root ---
# Kita perlu akses root untuk menginstall package tambahan
USER root

# --- Custom 1: Install Python (Opsional) ---
# Banyak user n8n butuh Python untuk manipulasi data kompleks
RUN apk add --update --no-cache python3 py3-pip

# --- Custom 2: Install Paket Tambahan Lainnya (Opsional) ---
# Contoh: Install library requests untuk Python
# RUN pip3 install requests --break-system-packages

# Contoh: Install library npm global tambahan (misal: moment, lodash)
# RUN npm install -g moment

# Kita tanamkan perintah ini langsung di dalam image
# Supaya n8n TIDAK BISA menolak untuk pakai IPv4
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

USER node