# Setup

## Required Credentials

- Telegram bot token
- ElevenLabs API key
- MySQL host, port, database, user, password
- Telegram webhook secret token, only if you replace the Telegram Trigger with Webhook mode

## Runtime Version

- n8n version used for import validation: `2.20.7-exp.0`
- Minimum expected n8n version: `1.80+`
- Entry mode selected: Telegram Trigger polling
- Error handling strategy: local user-facing failure branches where practical, plus `Telegram Agent Manager Error Handler` as the workflow-level Error Trigger workflow for unexpected failures.

## Entry Mode Rule

- If using Telegram Trigger polling, webhook secret validation is not applicable.
- If using a Webhook node, validate `X-Telegram-Bot-Api-Secret-Token` before any MySQL or ElevenLabs node runs.

This submission uses Telegram Trigger polling. The included workflow therefore does not use a webhook secret guard. If you convert the entry node to Webhook mode, add the guard before `Normalize Telegram Update` and stop with 403 on mismatch before any database or ElevenLabs operation.

## Setup Order

1. Create a MySQL database.
2. Run `database/schema.sql`.
3. Replace sample Telegram and ElevenLabs IDs in `database/seed.sql`.
4. Run `database/seed.sql`.
5. Import `workflow/telegram-elevenlabs-agent-manager.json` into n8n.
6. Import `workflow/telegram-agent-manager-error-handler.json`.
7. Configure Telegram, MySQL, and ElevenLabs credentials.
8. Set the main workflow's error workflow to `Telegram Agent Manager Error Handler`.
9. Activate the workflow.
10. Test `/start` from each seeded Telegram user.

## Supported Input Modes

The workflow supports two Telegram input modes:

- Inline keyboard menu flow.
- Simple free-form update commands, for example: `update my agent to answer Hello world`.

Free-form commands are parsed before the fallback menu route. If the user has one linked agent, the workflow can use it automatically. If the user has multiple linked agents and no selected session agent, the workflow sends the agent selection keyboard. In both cases, the selected internal `voice_agents.id` is re-authorized against the current Telegram user before any ElevenLabs API node runs.

## Credentials To Configure In n8n

- `Telegram Bot` credential for the `Telegram Trigger` and Telegram send-message nodes.
- `MySQL Telegram Agent Manager` credential for all MySQL nodes.
- `ElevenLabs API Key` credential or environment variable mapping for HTTP Request nodes that send the `xi-api-key` header.
- `TELEGRAM_BOT_TOKEN` environment variable only if using the HTTP Request fallback node for `answerCallbackQuery`.

## Database Validation

Run with your local database name and credentials:

```bash
mysql -u "$MYSQL_USER" -p "$MYSQL_DATABASE" < database/schema.sql
mysql -u "$MYSQL_USER" -p "$MYSQL_DATABASE" < database/seed.sql
mysql -u "$MYSQL_USER" -p "$MYSQL_DATABASE" -e "SELECT COUNT(*) AS users FROM telegram_users; SELECT COUNT(*) AS agents FROM voice_agents; SELECT COUNT(*) AS sessions FROM user_sessions; SELECT COUNT(*) AS kb_orphans FROM kb_orphan_documents;"
```

Expected counts:

```text
users: 3
agents: 4
sessions: 3
kb_orphans: 0
```

## Session Concurrency Behavior

Session state is stored per Telegram user, not per chat. Two rapid messages from the same user can race around `pending_action`; the MVP handles this by re-reading `user_sessions` at the start of each execution and by making cancel/update completion idempotent. No explicit locks are used for the MVP.

## Import Validation

Import the workflow JSON into a clean n8n workspace or temporary project. Confirm:

- The workflow loads without missing-node errors.
- Credentials appear as unresolved references, not raw secrets.
- No Telegram token, ElevenLabs key, or MySQL password is hard-coded in node parameters.
- A sample message payload and callback payload can pass through the entry/normalization path.
