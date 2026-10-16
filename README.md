# Ballerz Fußballschule

Recreation of [ballerz-fussballschule.de](https://ballerz-fussballschule.de) on the free-tier stack:

- **Cloudflare Pages** (Astro + Pages Functions)
- **Cloudflare D1** (SQLite)
- **Cloudflare R2** (assets)
- **Stripe** (camp registration + shop checkout)
- **Brevo** (transactional email)
- **OpenTofu** IaC + `deploy.sh`

## GitHub

Repository: https://github.com/godofdream/ballerz-fussballschule

To place this under an **organization**:

1. Create org at https://github.com/organizations/plan
2. Transfer the repo: Settings → General → Danger Zone → Transfer ownership

Suggested org name: `ballerz-fs` or `ballerz-fussballschule`.

## Quick start

```bash
cp .env.example .env
cp infra/terraform.tfvars.example infra/terraform.tfvars
chmod +x deploy.sh
./deploy.sh
```

Local: `npm install && npx wrangler d1 execute ballerz-db --local --file=./schema.sql && npm run dev`

## Stripe webhook

`https://<project>.pages.dev/api/stripe-webhook` — event `checkout.session.completed`
