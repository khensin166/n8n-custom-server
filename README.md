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
### 3. Deploy ke Railway

1.  Buat **New Project** di Railway -> Pilih **Deploy from GitHub repo**.
2.  Pilih repositori ini.
3.  Tunggu hingga build awal selesai (kemungkinan akan gagal/crash di awal karena variabel belum diset, ini normal).
4.  Masuk ke tab **Variables** di dashboard Railway dan masukkan konfigurasi di bawah ini.

#### 🔑 Environment Variables (Wajib)

Masukkan variabel-variabel berikut agar n8n dapat terhubung ke database dan berjalan dengan stabil:

| Variable | Value (Contoh) | Penjelasan |
| :--- | :--- | :--- |
| `DB_TYPE` | `postgresdb` | Tipe database yang digunakan. |
| `DB_POSTGRESDB_HOST` | `aws-0-sg.pooler.supabase.com` | **PENTING:** Gunakan Host dari **Connection Pooler** (bukan Direct). |
| `DB_POSTGRESDB_PORT` | `6543` | **PENTING:** Wajib gunakan Port **6543** (Pooler). |
| `DB_POSTGRESDB_DATABASE`| `postgres` | Nama database default. |
| `DB_POSTGRESDB_USER` | `postgres.vgrgx...` | **PENTING:** Gunakan format user lengkap (`user.project_id`). |
| `DB_POSTGRESDB_PASSWORD`| `Rahasia123` | Password database Supabase kamu. |
| `DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED` | `false` | Mencegah error *SSL handshake* saat koneksi database. |
| `N8N_ENCRYPTION_KEY` | `k3n4nRaH4s1a...` | String acak untuk enkripsi kredensial. **JANGAN SAMPAI HILANG!** |
| `WEBHOOK_URL` | `https://project.up.railway.app/` | Domain publik Railway (Generate di tab *Settings* -> *Networking*). |
| `N8N_SECURE_COOKIE` | `false` | **WAJIB:** Set `false` agar bisa login di belakang proxy Railway (HTTP). |
| `N8N_PROXY_HOPS` | `1` | Mencegah error validasi Proxy/IP Address. |

#### ⚠️ Troubleshooting Umum

Jika n8n gagal *deploy* atau *crash*, cek kemungkinan berikut:

**1. Error `ENETUNREACH 2406:...` (IPv6 Error)**
* **Penyebab:** n8n mencoba koneksi via IPv6 yang tidak stabil di Railway.
* **Solusi:** Pastikan `NODE_OPTIONS="--dns-result-order=ipv4first"` sudah ada di Dockerfile. Pastikan Host menggunakan alamat Pooler Supabase.

**2. Error `db_termination` atau `unexpected EOF`**
* **Penyebab:** Supabase Pooler menggunakan mode *Transaction* yang tidak kompatibel dengan n8n.
* **Solusi:** Masuk ke Dashboard Supabase -> Database settings -> Ubah **Pool Mode** menjadi **Session**.

**3. Error `401 Unauthorized` saat Login**
* **Penyebab:** Masalah *Secure Cookie* karena Railway menggunakan HTTPS di depan tapi forward ke container via HTTP.
* **Solusi:** Pastikan variable `N8N_SECURE_COOKIE=false`.

**4. Error `ValidationError: X-Forwarded-For...`**
* **Penyebab:** n8n mencurigai header proxy dari Railway.
* **Solusi:** Pastikan variable `N8N_PROXY_HOPS=1`.

#### 🛡️ Keamanan (RLS)

Sangat disarankan untuk mengaktifkan **RLS (Row Level Security)** pada tabel-tabel n8n di Supabase (`execution_entity`, `credentials_entity`, dll) agar data tidak terekspos ke API publik Supabase.

* **Caranya:** Masuk Supabase -> Table Editor -> Klik tabel n8n -> Klik **Enable RLS**.
* **Catatan:** Tidak perlu membuat policy tambahan (karena n8n mengakses via user admin `postgres` yang otomatis mem-bypass RLS).

---
**Dibuat oleh Kenan**
