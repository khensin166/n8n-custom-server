# --- 1. Gunakan Base Image Node.js (Alpine Asli) ---
# Image ini punya 'apk' yang berfungsi normal 100%
FROM node:20-alpine

# --- 2. Masuk sebagai Root ---
USER root

# --- 3. Install Python & Dependencies ---
# Karena ini Alpine asli, perintah 'apk' pasti jalan!
# Kita juga install 'build-base' jaga-jaga kalau n8n butuh compile sesuatu.
RUN apk add --update --no-cache python3 py3-pip build-base

# --- 4. Install n8n Manual ---
# Kita download n8n langsung dari NPM (Pusat Library Node.js)
RUN npm install -g n8n

# --- 5. SOLUSI IPv4 (WAJIB) ---
# Tetap kita pasang ini supaya connect ke Supabase Pooler lancar
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

# --- 6. Setup User & Start ---
# Pindah ke user 'node' supaya aman (bawaan image node:20-alpine)
USER node

# Perintah untuk menyalakan n8n saat server start
CMD ["n8n"]