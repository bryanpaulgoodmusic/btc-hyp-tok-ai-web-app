#!/bin/bash
#!/usr/bin/env bash
# =============================================================
# migrate.sh
# Run this once from the repo root (btc-hyp-tok-ai-web-app/)
# to reorganise the three captured subdirs into public/
# and remove redundant duplicates.
# =============================================================
set -e

ROOT="$(pwd)"
PUB="$ROOT/public"

echo "→ Creating public/ directory tree..."
mkdir -p "$PUB/app/assets"
mkdir -p "$PUB/_DataURI"
mkdir -p "$PUB/app/_DataURI"

# ------------------------------------------------------------------
# 1. ROOT page  (bitcoinhypertoken-ai.web.app/)
# ------------------------------------------------------------------
SRC1="$ROOT/bitcoinhypertoken_ai.web.app"

echo "→ Copying root index.html..."
cp "$SRC1/bitcoinhypertoken-ai.web.app/index.html" "$PUB/index.html"

echo "→ Copying root _DataURI/..."
cp -r "$SRC1/_DataURI/." "$PUB/_DataURI/"

# cdn.aitopia.ai – first (canonical) copy
echo "→ Copying cdn.aitopia.ai (canonical)..."
cp -r "$SRC1/cdn.aitopia.ai" "$PUB/cdn.aitopia.ai"

# ------------------------------------------------------------------
# 2. /app/ page  (bitcoinhypertoken-ai.web.app/app/)
# ------------------------------------------------------------------
SRC2="$ROOT/bitcoinhypertoken_ai.web.app-app"
SRC2_APP="$SRC2/bitcoinhypertoken-ai.web.app/app"

echo "→ Copying /app/index.html..."
cp "$SRC2_APP/index.html" "$PUB/app/index.html"

echo "→ Copying /app/slide-bg.webp..."
cp "$SRC2_APP/slide-bg.webp" "$PUB/app/slide-bg.webp"

echo "→ Copying /app/assets/..."
cp -r "$SRC2_APP/assets/." "$PUB/app/assets/"

echo "→ Copying favicon.ico..."
cp "$SRC2/bitcoinhypertoken-ai.web.app/favicon.ico" "$PUB/favicon.ico"

echo "→ Copying app _DataURI/..."
cp -r "$SRC2/_DataURI/." "$PUB/app/_DataURI/"

# CDN mirrors bundled with the /app/ snapshot
# (skip cdn.aitopia.ai – already copied from root)
for d in cdn.jsdelivr.net cdn.rocketx.exchange code.jquery.com \
          extensions.aitopia.ai fonts.googleapis.com fonts.gstatic.com \
          icons.llamao.fi ka-f.fontawesome.com kit.fontawesome.com; do
  if [ -d "$SRC2/$d" ]; then
    echo "→ Copying $d ..."
    cp -r "$SRC2/$d" "$PUB/$d"
  fi
done

# ------------------------------------------------------------------
# 3. /app/load.html page
# ------------------------------------------------------------------
SRC3="$ROOT/bitcoinhypertoken_ai.web.app-app-load"
SRC3_APP="$SRC3/bitcoinhypertoken-ai.web.app/app"

echo "→ Copying /app/load.html..."
cp "$SRC3_APP/load.html" "$PUB/app/load.html"

echo "→ Copying /app/load.gif..."
cp "$SRC3_APP/load.gif" "$PUB/app/load.gif"

echo "→ Copying /app/slide-bg.webp (load variant, skip if identical)..."
cp -n "$SRC3_APP/slide-bg.webp" "$PUB/app/slide-bg.webp" 2>/dev/null || true

echo "→ Merging load page assets into /app/assets/..."
cp -r "$SRC3_APP/assets/." "$PUB/app/assets/"

echo "→ Merging load _DataURI/ into /app/_DataURI/..."
cp -r "$SRC3/_DataURI/." "$PUB/app/_DataURI/"

# Merge load-page CDN mirrors (may add new files, won't overwrite)
for d in cdn.aitopia.ai cdn.rocketx.exchange cdnjs.cloudflare.com \
          extensions.aitopia.ai fonts.gstatic.com; do
  if [ -d "$SRC3/$d" ]; then
    echo "→ Merging $d from load snapshot..."
    cp -rn "$SRC3/$d/." "$PUB/$d/" 2>/dev/null || true
  fi
done

# ------------------------------------------------------------------
# 4. Place vercel.json at repo root
# ------------------------------------------------------------------
echo "→ Writing vercel.json..."
cat > "$ROOT/vercel.json" <<'VERCELJSON'
{
  "version": 2,
  "public": true,
  "outputDirectory": "public",
  "routes": [
    { "src": "/app/load\\.html", "dest": "/app/load.html" },
    { "src": "/app/?",           "dest": "/app/index.html" },
    { "src": "/",                "dest": "/index.html"     },
    { "src": "/(.*)",            "dest": "/$1"             }
  ]
}
VERCELJSON

# ------------------------------------------------------------------
# 5. Optionally remove the now-redundant source dirs
# ------------------------------------------------------------------
echo ""
echo "Done! Your public/ directory is ready."
echo ""
echo "To remove the original source dirs (optional):"
echo "  rm -rf bitcoinhypertoken_ai.web.app"
echo "  rm -rf bitcoinhypertoken_ai.web.app-app"
echo "  rm -rf bitcoinhypertoken_ai.web.app-app-load"
echo ""
echo "Then commit and push to GitHub, then deploy on Vercel:"
echo "  vercel --prod"
