# --- Base Image ---
# Menggunakan versi terbaru n8n
FROM n8nio/n8n:latest

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

# --- Kembali ke User Node (PENTING) ---
# Jangan jalankan n8n sebagai root demi keamanan
USER node