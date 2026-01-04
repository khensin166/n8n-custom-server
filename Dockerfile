# --- Base Image ---
# Terbukti: Ini adalah Alpine Linux
FROM n8nio/n8n:latest

# --- Masuk sebagai Root (Wajib) ---
USER root

# --- Install Python (Alpine Style - Absolute Path) ---
# Kita gunakan /sbin/apk untuk memastikan sistem menemukannya.
# Perintah ini akan menginstall Python 3 dan PIP.
RUN /sbin/apk add --update --no-cache python3 py3-pip

# --- SOLUSI IPv4 (WAJIB) ---
# Memaksa n8n menggunakan IPv4 agar connect ke Supabase Pooler
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

# --- Kembali ke User Node ---
USER node