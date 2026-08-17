# ============================================================
# OpenClaw Agent — service TERPISAH di Render (akun #2).
# 9Router sekarang di service terpisah (repo 9router-solo, akun #1),
# jadi TIDAK perlu Caddy. OpenClaw serve Control UI langsung di port
# gateway (8000). Provider model mengarah ke URL publik 9Router.
# ============================================================

FROM ghcr.io/openclaw/openclaw:latest

COPY openclaw.json /home/node/.openclaw/openclaw.json

USER node
ENV OPENCLAW_GATEWAY_PORT=8000
ENV OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-gateway-dev-token}"
EXPOSE 8000

# Belmo memakai HEALTHCHECK untuk menandai container healthy.
# Root Control UI balas 200/307 saat gateway siap.
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:8000/').then(r=>process.exit(r.status<400?0:1)).catch(()=>process.exit(1))"