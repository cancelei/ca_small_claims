# Playwright MCP ↔ Rails E2E Patterns — Cross-Reference & Quick File Guide

> Purpose: connect your **Rails + Playwright E2E cookbook** with the **Playwright MCP** ecosystem. Use this to navigate "what lives where", what each piece does, and how to bridge traditional Playwright tests with MCP-driven automation for the CA Small Claims application.

---

## 1) Quick Mental Model

- **Rails E2E (your tests):** you own the browser via Playwright's test runner; you boot Rails, seed/reset data, and write specs.
- **Playwright MCP:** an **MCP server** exposes browser tools (navigate, click, fill, etc.) so **AI clients** (Claude Desktop, VS Code Copilot Agent, Cursor, Windsurf, etc.) can drive the browser and even generate steps/tests. You configure it via your client's *mcpServers* settings and run: `npx @playwright/mcp@latest`.

**Bridge in practice:** let MCP (AI) explore/generate a flow -> export/curate as real Playwright specs -> slot into your `/tests` with the patterns from your Rails doc.

---

## 2) Section-by-Section Map (Rails doc ↔ MCP)

| Rails patterns section | What you do there | Closest MCP piece | How to marry them |
|---|---|---|---|
| **Layout & Boot** | Dedicated `/tests`, `webServer`, `Procfile.dev` | **MCP "Getting Started / Config"**: client config with `"command": "npx", "args": ["@playwright/mcp@latest"]` | Keep your Rails boot as-is. Run MCP server in parallel (or let client spawn it). Point MCP actions to `BASE_URL` you already use. |
| **Playwright config** | `playwright.config.js` (projects, reporter, tracing) | MCP server **caps** (e.g. `--caps=tracing`, `--caps=pdf`, `--caps=verify`) | Align artifacts: enable Playwright traces by default; enable MCP tracing cap when you want agentic sessions to capture extra evidence. |
| **Database strategies** | Reset endpoints, truncate, per-worker DBs | MCP **tools** are browser-centric; they won't reset Rails | Keep your `/test_only/reset` endpoint. Expose a "Reset" prompt or tool in your client to call that endpoint between MCP sessions. |
| **Auth patterns** | UI login, programmatic session, storage state | MCP **browser_fill_form**, **browser_type**, **browser_click** | Use MCP to perform first login and then persist **storageState.json** for your Playwright projects. |
| **Turbo waits** | Assert DOM outcomes; helper `waitForTurbo` | MCP uses **accessibility snapshots** vs pixels | The same guidance applies: assert on roles/labels/DOM results. Favor role-based descriptions when prompting the agent. |
| **Stimulus/Tailwind** | Prefer `getByRole`/`getByLabel` | MCP tools accept **human-readable element descriptions** + **refs** | Structure your markup with solid ARIA to make agent intent unambiguous and tool permission prompts accurate. |
| **Form Wizard** | Multi-step forms, PDF generation | MCP **browser_fill_form**, **browser_click** | Use MCP to explore wizard flows; export steps as deterministic specs. |
| **Helpers (uploads/downloads)** | `setInputFiles`, `page.waitForEvent('download')` | **browser_file_upload**, **browser_pdf_save** (with caps) | For code-gen or exploratory runs, let MCP upload/create PDFs; then port the steps into deterministic Playwright specs. |
| **Mailer checks** | Test endpoints / letter_opener_web | MCP can hit URLs & read JSON | Add a read-only `/test_only/last_mail` route; instruct the agent to fetch/validate subject/links before codifying it. |
| **Authorization (Pundit)** | Negative tests & forbidden flows | **browser_navigate** + assertions | Have the agent attempt direct URL access; export its successful checks as specs. |
| **Flake & CI** | Traces/videos; GH Actions matrix | MCP **tracing/verify** caps; clients' own logs | Store MCP run artifacts under `/tests/mcp-artifacts/` in CI for later triage alongside Playwright reports. |

---

## 3) Playwright MCP Essentials You'll Actually Touch

- **Client config snippet** (VS Code / Cursor / Claude Code, etc.):
  ```jsonc
  {
    "mcpServers": {
      "playwright": { "command": "npx", "args": ["@playwright/mcp@0.0.53"] }
    }
  }
  ```
  > **Performance tip**: Pin to a specific version (e.g., `@0.0.53`) instead of `@latest` to avoid npm version checks on every session. Update periodically with `npm view @playwright/mcp version`.
- **Common tools** (names abbreviated): `browser_navigate`, `browser_click`, `browser_type`, `browser_fill_form`, `browser_select_option`, `browser_hover`, `browser_file_upload`, XY mouse tools; optional via caps: `browser_pdf_save`, tracing & verification tools.
- **Capabilities flags** (pass as args in your client config): `--caps=tracing`, `--caps=pdf`, `--caps=verify`.
- **Access model**: tools act on **accessibility snapshot refs** + your **human-readable description** (agent asks permission per element), which plays nicely with semantic/ARIA-rich Rails views.

---

## 4) Practical "In-Betweens" (from Prompt -> Stable Spec)

1) **Exploration** (MCP): "Open /users/sign_in, login as admin, go to /forms, start a new SC-100 form, complete wizard, generate PDF."
2) **Harvest** (export steps): capture the agent's successful sequence and selectors/labels.
3) **Codify** (Playwright spec): paste into `/tests/form_wizard.spec.js`, replace any brittle selectors with `getByRole/getByLabel`, reuse your helpers (`waitForTurbo`, seeders).
4) **Artifact parity**: keep **MCP traces** and **Playwright traces** side-by-side in CI.
5) **Lock down data**: ensure `/test_only/reset` runs before each exploration to avoid flaky state.

---

## 5) CA Small Claims Specific Flows

### Form Wizard Flow
```
1. Navigate to /forms/new
2. Select form type (SC-100, SC-104, etc.)
3. Complete each wizard step
4. Review submission
5. Generate PDF
6. Download or save
```

### Submission Workflow
```
1. Login as user
2. Start new submission
3. Select category
4. Complete form fields
5. Save draft / Submit
6. Track submission status
```

### Admin Review Flow
```
1. Login as admin
2. Navigate to /admin/submissions
3. Review pending submissions
4. Approve/reject with notes
5. Notify user
```

---

## 6) Repo/File Quick-Reference

- **`playwright.config.js`** — Playwright test configuration
- **`tests/`** — E2E test files
- **`tests/fixtures/`** — Test fixtures and base setup
- **`tests/helpers/`** — Shared test utilities
- **`tests/e2e/`** — End-to-end test specs
- **`tests/e2e/security/`** — Security-focused E2E tests

> Tip: Treat the **tools list** in the MCP README as your *coverage checklist*; for each critical UI flow in Rails, confirm you can drive it with only these tools (no image/pixel hacks).

---

## 7) Minimal Workflows You Can Reuse

- **Claude Code (CLI)**
  ```bash
  claude mcp add playwright -- npx @playwright/mcp@0.0.53
  # then chat: "Open http://localhost:3000, log in, start a new SC-100 form, complete it, export steps as Playwright test"
  ```

- **VS Code Copilot Agent**
  - Settings -> *Add MCP* -> paste the standard config with pinned version.
  - Command Palette: "Copilot: Start Agent" -> instruct the flow, then copy generated steps.

- **Cursor / Windsurf**
  - Settings -> MCP -> Add server with `npx @playwright/mcp@0.0.53`
  - Ask the agent to **generate a spec** that uses `getByRole`/`getByLabel` and avoids Tailwind classes.

---

## 8) Guard-Rails (Security & Stability)

- Keep test-only endpoints (`/test_only/*`) behind **localhost** OR a secret header (`X-E2E-Token`).
- Do **not** expose MCP server remotely without network policies; prefer STDIO spawn by the client.
- Persist **storageState.json** post-login and reuse across both MCP sessions and Playwright projects.
- For Turbo Streams, require agents/tests to assert **post-action DOM** (not network idle).

---

## 9) Where to Look Up Details Fast

- **MCP concepts:** Servers, Tools, Resources, Prompts; protocol ops (`tools/list`, `tools/call`, etc.).
- **Playwright MCP README:** tools catalog, client config blocks, caps flags.
- **Example clients:** HyperAgent and IDE agents that plug into MCP.
- **Community servers:** alternative Playwright MCP servers offer examples of prompts/configs you can borrow.

---

## 10) Copy-Paste Snippets

**Client config with tracing + PDF**
```jsonc
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@0.0.53", "--caps=tracing,pdf"]
    }
  }
}
```

**Reset before exploration (Claude Desktop custom tool message)**
```
POST {{BASE_URL}}/test_only/reset
Then: navigate to {{BASE_URL}}/users/sign_in and continue the flow.
```

**Exported steps into a spec scaffold**
```ts
import { test, expect } from '@playwright/test';
import { waitForTurbo } from '../helpers/turbo';

test('user completes SC-100 form wizard', async ({ page }) => {
  await page.goto('/users/sign_in');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: /sign in/i }).click();

  await page.goto('/forms/new');
  await page.getByRole('button', { name: /SC-100/i }).click();

  // Step 1: Plaintiff Information
  await page.getByLabel('Full Name').fill('John Doe');
  await page.getByLabel('Address').fill('123 Main St');
  await page.getByRole('button', { name: /next/i }).click();
  await waitForTurbo(page);

  // Step 2: Defendant Information
  await page.getByLabel('Defendant Name').fill('Jane Smith');
  await page.getByRole('button', { name: /next/i }).click();
  await waitForTurbo(page);

  // Continue through remaining steps...

  // Final: Generate PDF
  const [download] = await Promise.all([
    page.waitForEvent('download'),
    page.getByRole('button', { name: /generate pdf/i }).click()
  ]);
  expect(await download.path()).toBeTruthy();
});
```

---

## 11) Next Steps

- Plug MCP into your preferred client and **generate** the first flow for one domain (e.g., SC-100 Form).
- **Harden** it as a deterministic spec using your helpers and DB reset strategy.
- Add **caps** only where useful (tracing/PDF). Keep selectors semantic to help both the agent and specs.
