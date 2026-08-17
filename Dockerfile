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