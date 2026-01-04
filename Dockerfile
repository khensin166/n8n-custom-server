# # --- Base Image ---
# # Menggunakan versi terbaru n8n
# # FROM n8nio/n8n:latest
# FROM n8nio/n8n:latest

# # --- Masuk sebagai Root ---
# # Kita perlu akses root untuk menginstall package tambahan
# USER root

# # --- Custom 1: Install Python (Opsional) ---
# # Banyak user n8n butuh Python untuk manipulasi data kompleks
# # RUN apk add --update --no-cache python3 py3-pip
# RUN apt-get update && \
#     apt-get install -y python3 python3-pip --no-install-recommends && \
#     rm -rf /var/lib/apt/lists/*

# # --- Custom 2: Install Paket Tambahan Lainnya (Opsional) ---
# # Contoh: Install library requests untuk Python
# # RUN pip3 install requests --break-system-packages

# # Contoh: Install library npm global tambahan (misal: moment, lodash)
# # RUN npm install -g moment

# # Kita tanamkan perintah ini langsung di dalam image
# # Supaya n8n TIDAK BISA menolak untuk pakai IPv4
# ENV NODE_OPTIONS="--dns-result-order=ipv4first"

# USER node

FROM n8nio/n8n:latest

USER root

# --- PERINTAH DETEKTIF ---
# Kita sengaja menyuruh docker untuk mencetak nama OS, lalu force exit.
# Tujuannya agar kita bisa lihat di LOG Railway: OS apa ini sebenarnya?
RUN cat /etc/os-release && echo "--- CEK DISINI ---" && exit 1

USER node