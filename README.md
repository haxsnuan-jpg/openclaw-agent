# OpenClaw Agent — satu service di Render (Free, tanpa kartu)

Deploy **OpenClaw** (AI agent lengkap: terminal, tools, skills, Control UI)
sebagai service mandiri di Render free. Model disuplai oleh service
**9Router** yang terpisah (repo `9router-solo`).

```
Akun Render A: 9Router saja  -> https://9router-xxx.onrender.com  (port 20128)
Akun Render B: OpenClaw      -> https://openclaw-xxx.onrender.com (port 8000)
```

> **Mengapa dipisah?** Render free memberi 750 jam/bulan per akun dan 512MB
> RAM per service. Dengan 2 akun (2 email), kamu dapat 2 service penuh —
> masing-masing tidak berebut memory (OpenClaw butuh ±280MB, 9Router ±200MB).

---

## Cara Deploy (langkah demi langkah)

### 0. Prasyarat
- Akun GitHub (gratis)
- Akun Render #2 (gratis, https://dashboard.render.com — **email beda**
  dari akun #1 untuk 9Router, biar dapat 750 jam lagi)
- Service 9Router sudah jalan (repo `9router-solo`) → catat URL-nya,
  mis. `https://9router-abc.onrender.com`

### 1. Push repo ini ke GitHub
```bash
cd openclaw-agent
git init && git add . && git commit -m "openclaw agent standalone"
git branch -M main
git remote add origin https://github.com/<username>/openclaw-agent.git
git push -u origin main
```

### 2. Buat Web Service di Render akun #2 (PENTING: pilih FREE!)
1. Buka https://dashboard.render.com → **New → Web Service**
2. Connect GitHub → pilih repo `openclaw-agent`
3. Set di form:
   - **Root Directory:** (kosongkan) — Dockerfile sudah di root repo
   - **Runtime:** Docker
   - **Instance Type:** **`Free`** ← **wajib pilih ini!**
     > Default dropdown adalah "Starter" ($7/bulan) → itu yang bikin Render
     > minta kartu. Pilih **Free** dan kartu tidak akan diminta.
   - **Region:** `Singapore` (terdekat, gratis)
   - **Port:** `8000`
4. Isi **Environment Variables**:
   | Key | Nilai |
   |---|---|
   | `NINEROUTER_URL` | `https://9router-abc.onrender.com` (URL service 9Router) |
   | `OPENCLAW_PUBLIC_URL` | `https://openclaw-abc.onrender.com` (URL service ini — bisa diisi dulu yang kira-kira, lalu perbaiki setelah deploy) |
   | `OPENCLAW_GATEWAY_TOKEN` | token kuat (lihat `/home/hasn/kunci.txt`) |
5. Klik **Create Web Service** → Render build Dockerfile otomatis (~5 menit)

### 3. Buka Control UI OpenClaw
1. Buka `https://openclaw-abc.onrender.com` (Control UI langsung di root).
2. Login pakai `OPENCLAW_GATEWAY_TOKEN` (bukan password biasa — device
   pairing dimatikan karena Render free tidak punya shell).
3. Cek model: `/v1/models` di 9Router harus punya `kr/*` dan `oc/*`.
4. Mulai chat di Control UI — OpenClaw akan memakai model dari 9Router.

> ⚠️ Kalau `OPENCLAW_PUBLIC_URL` belum pas, perbaiki di **Environment** →
> **Save**, lalu Render otomatis restart.

### 4. Set secret keepalive GitHub
1. Repo → **Settings → Secrets and variables → Actions**
2. Secret **`RENDER_URL`** = `https://openclaw-abc.onrender.com`
3. Tab **Actions** → jalankan **keepalive** sekali manual.

---

## Env Vars (Render)

| Key | Wajib? | Nilai |
|---|---|---|
| `NINEROUTER_URL` | wajib | URL 9Router (provider model) |
| `OPENCLAW_PUBLIC_URL` | wajib | URL service ini (whitelist Control UI) |
| `OPENCLAW_GATEWAY_TOKEN` | wajib | token login Control UI |

> Tanpa `NINEROUTER_URL` atau `OPENCLAW_PUBLIC_URL`, gateway OpenClaw
> **gagal start** (config memakainya sebagai required secret).

---

## Penting: keterbatasan (baca!)

- **Spin down 15 menit.** Keepalive GitHub mencegahnya.
- **Filesystem tidak persist.** Config sudah dibakar di image; data sesi
  hilang tiap restart (wajar untuk free).
- **750 jam instance/bulan.** Keepalive 24/7 ≈ 720 jam — pas muat untuk 1
  service per akun. Jangan deploy service gratis lain di akun yang sama.
- **Bukan untuk produksi.** Ini setup belajar/hobi gratis.

---

## Struktur repo

```
openclaw-agent/
├── Dockerfile              #   OpenClaw saja (port 8000, tanpa Caddy)
├── openclaw.json           #   provider "9router" -> NINEROUTER_URL/v1
├── .github/workflows/keepalive.yml  # keepalive tiap 5 menit (gratis)
├── render.yaml             #   panduan nilai (Render pakai dashboard manual)
└── .gitignore
```

---

## Referensi
- OpenClaw: https://github.com/openclaw/openclaw
- 9Router: https://github.com/decolua/9router
- Render free: https://render.com/docs/free