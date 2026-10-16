#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "==> Ballerz Fußballschule deploy"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }
}

need npm
need npx
need tofu || need terraform

TOFU_BIN="tofu"
command -v tofu >/dev/null 2>&1 || TOFU_BIN="terraform"

echo "==> Applying infrastructure with $TOFU_BIN"
pushd infra >/dev/null
if [[ ! -f terraform.tfvars ]]; then
  echo "Create infra/terraform.tfvars from terraform.tfvars.example first."
  exit 1
fi
$TOFU_BIN init -upgrade
$TOFU_BIN apply -auto-approve
D1_ID="$($TOFU_BIN output -raw d1_database_id)"
R2_NAME="$($TOFU_BIN output -raw r2_bucket_name)"
PAGES_NAME="$($TOFU_BIN output -raw pages_project_name)"
popd >/dev/null

echo "D1 database id: $D1_ID"
echo "R2 bucket:      $R2_NAME"
echo "Pages project:  $PAGES_NAME"

if [[ -f wrangler.toml ]]; then
  sed -i.bak "s/database_id = \".*\"/database_id = \"$D1_ID\"/" wrangler.toml
  sed -i.bak "s/preview_database_id = \".*\"/preview_database_id = \"$D1_ID\"/" wrangler.toml
  rm -f wrangler.toml.bak
fi

echo "==> npm install + build"
npm ci || npm install
npm run build

echo "==> Applying D1 schema (remote)"
npx wrangler d1 execute ballerz-db --remote --file=./schema.sql || true

set_secret() {
  local name="$1"
  local value="${!name:-}"
  if [[ -n "$value" ]]; then
    echo "Setting secret $name"
    echo "$value" | npx wrangler pages secret put "$name" --project-name="$PAGES_NAME"
  else
    echo "Skip secret $name (not set)"
  fi
}

set_secret STRIPE_SECRET_KEY
set_secret STRIPE_WEBHOOK_SECRET
set_secret BREVO_API_KEY
set_secret BREVO_SENDER_EMAIL
set_secret TURNSTILE_SECRET_KEY

echo "==> Deploying to Cloudflare Pages"
npx wrangler pages deploy dist --project-name="$PAGES_NAME" --commit-dirty=true

echo ""
echo "Done."
echo "  Project: https://${PAGES_NAME}.pages.dev"
echo "  Stripe webhook: https://${PAGES_NAME}.pages.dev/api/stripe-webhook"
