Tentu, ini adalah draft README.md yang profesional dan lengkap untuk repositori GitHub kamu.

Dokumentasi ini mencakup arsitektur khusus yang kita bangun (Custom Docker Image dengan Python + Fix IPv4) dan konfigurasi spesifik Supabase (Session Mode) agar kamu tidak lupa di kemudian hari.

Silakan simpan kode di bawah ini dengan nama file README.md di dalam folder proyekmu.

Markdown

# Self-Hosted n8n on Railway & Supabase

![n8n](https://img.shields.io/badge/n8n-Workflow_Automation-orange?style=for-the-badge&logo=n8n)
![Railway](https://img.shields.io/badge/Railway-Deployment-0b0d36?style=for-the-badge&logo=railway)
![Supabase](https://img.shields.io/badge/Supabase-Database-3ecf8e?style=for-the-badge&logo=supabase)
![Docker](https://img.shields.io/badge/Docker-Custom_Image-2496ed?style=for-the-badge&logo=docker)

Repositori ini berisi konfigurasi custom untuk menjalankan **n8n** secara mandiri (self-hosted) menggunakan **Railway** sebagai compute dan **Supabase** sebagai database (PostgreSQL).

Konfigurasi ini dirancang khusus untuk mengatasi masalah konektivitas IPv6 antara Railway dan Supabase, serta mendukung instalasi paket tambahan (seperti Python).

## 🚀 Fitur & Modifikasi

* **IPv4 Forced Connection:** Menggunakan `NODE_OPTIONS="--dns-result-order=ipv4first"` untuk memaksa n8n menggunakan jalur IPv4, mengatasi error `ENETUNREACH` pada jaringan Railway.
* **Python Support:** Dockerfile sudah dimodifikasi untuk menyertakan Python 3 dan PIP, memungkinkan eksekusi script Python di dalam n8n.
* **Supabase Pooler Compatible:** Dikonfigurasi untuk berjalan stabil menggunakan Connection Pooler Supabase (Port 6543) dalam mode *Session*.
* **Cost Efficient:** Memisahkan *Compute* (Railway) dan *Storage* (Supabase Free Tier) untuk efisiensi biaya.

## 📋 Prasyarat

1.  Akun **Railway** (Trial atau Hobby Plan).
2.  Akun **Supabase** (Free Tier cukup).
3.  Akun **GitHub**.

## 🛠️ Langkah Instalasi

### 1. Persiapan Database (Supabase)

Agar n8n dapat berjalan stabil tanpa memutus koneksi, kita harus menggunakan **Session Mode** pada Connection Pooler.

1.  Masuk ke Dashboard Supabase -> **Project Settings** -> **Database**.
2.  Cari bagian **Connection Pooling Configuration**.
3.  Ubah **Pool Mode** dari `Transaction` menjadi **`Session`**.
4.  Catat kredensial berikut dari tab *Connection parameters* (matikan "Use connection string" untuk melihat detailnya):
    * **Host:** (Gunakan alamat Pooler, misal: `aws-0-ap-southeast-1.pooler.supabase.com`)
    * **Port:** `6543`
    * **User:** (Format lengkap: `postgres.project_id`)
    * **Password:** (Password database kamu)

### 2. Setup Repository

Pastikan file `Dockerfile` di repo ini berisi baris berikut untuk menangani jaringan:

```dockerfile
FROM n8nio/n8n:latest

USER root
# Install Python & Dependencies
RUN apk add --update --no-cache python3 py3-pip

# FORCE IPv4 (CRITICAL FIX)
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

USER node
```
