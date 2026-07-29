# Presenter Runbook

Steps to prepare and run the Docker Sandboxes live demo.

## 1. Push the repo to GitHub and create issues

```bash
gh repo create docker-faq --public --source=. --push
cd docker-faq && bash scripts/create-issues.sh
```

Verify three issues appear in the repo before the demo.

## 2. Configure secrets

Run on the host. These propagate into every sandbox launched from the kit:

```bash
sbx secret set -g anthropic -t "$ANTHROPIC_API_KEY"
gh auth token | sbx secret set -g github
```

## 3. Launch the three demo sandboxes

One sandbox per issue. Adjust `--name` and `--issue` as needed:

```bash
sbx run --clone --name faq-compose  --kit ../docker-faq-demo-kit/ --repo <org>/docker-faq
sbx run --clone --name faq-seed     --kit ../docker-faq-demo-kit/ --repo <org>/docker-faq
sbx run --clone --name faq-style    --kit ../docker-faq-demo-kit/ --repo <org>/docker-faq
```

> **Note:** The exact `sbx run` syntax for kit-launched sandboxes is Early Access and subject to change. Verify the invocation against current `sbx run --help` output before rehearsal.

## 4. Rehearsal checklist

1. **Brand guide wiring** — confirm the agent reads the brand guide shipped in the kit (it lands at `/home/agent/` inside the sandbox). With kits, agent context may land under a `kits-agent-context/` index path; verify the styled output uses the correct palette before the demo.
2. **End-to-end dry runs** — run each issue at least twice; tune issue wording if the agent output is weak.
3. **Network policy audit** — after a full rehearsal run `sbx policy log`. Add any blocked domains (Docker Hub pull CDNs are the likely gap) to `allowedDomains` in `docker-faq-demo-kit/spec.yaml`.
4. **PR creation** — confirm `gh pr create` succeeds from inside a kit sandbox. GitHub credential injection via the built-in `github` service should apply automatically, but verify — if PRs fail, add GitHub `serviceDomains`/`serviceAuth` wiring to `spec.yaml`.
5. **Pre-warm** — start all three sandboxes the night before. Image pulls happen per-VM and add significant latency on first launch.
6. **Font fallback** — if Google Fonts is unreliable even when `fonts.googleapis.com` and `fonts.gstatic.com` are allowed, edit the brand guide in the kit to specify the system font stack only and remove both font domains from `allowedDomains`. Fully deterministic, slightly less flashy.

## 5. On-stage final verification

Run a **fourth** fresh sandbox with port 3000 published:

```bash
sbx run --clone --name faq-verify --kit ../docker-faq-demo-kit/ --repo <org>/docker-faq
sbx ports faq-verify --publish 3000:3000/tcp
```

Open http://localhost:3000 on the presenter machine to confirm the fully-fixed stack renders correctly. Never verify on the host directly.
