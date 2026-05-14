# Test Notes

## Seed Data

- Telegram user 1: `111111111` placeholder; replace before live testing.
- Telegram user 2: `222222222` placeholder; replace before live testing.
- Telegram user with no agents: `333333333` placeholder; keep active and with no agents.
- ElevenLabs agent IDs in `database/seed.sql` are placeholders and must be replaced with real agent IDs before live testing.

## Database Checks

- [x] Schema imports into a clean MySQL database.
- [x] Seed imports into the clean database.
- [x] Expected counts are observed: users 3, agents 4, sessions 3, kb_orphans 0.
- [x] User 1 ownership query returns only user 1 agents.
- [x] User 1 cross-user query for user 2 agent returns zero rows.

## Import Checks

- [x] Main workflow imports into a clean n8n workspace.
- [x] Error workflow imports into a clean n8n workspace.
- [x] Credentials remain unresolved references and no raw secrets appear in node parameters.
- [x] Sample Telegram message payload reaches `Normalize Telegram Update`.
- [x] Sample callback payload reaches `Normalize Telegram Update`.

## Manual Tests

- [x] `/start` shows menu for authorized user.
- [ ] `/menu` shows menu for authorized user.
- [x] User sees only their own agents.
- [x] User selects an agent successfully.
- [x] Free-form prompt command is parsed and routed through ownership checks.
- [x] Prompt update succeeds.
- [x] Welcome message update succeeds.
- [x] Knowledge-base text update succeeds.
- [x] Cross-user callback is rejected before any ElevenLabs call.
- [x] Deleted selected agent clears session and asks user to choose another.
- [ ] Empty text is rejected.
- [ ] Too-long prompt is rejected.
- [ ] Too-long welcome message is rejected.
- [ ] Too-long knowledge-base text is rejected.
- [ ] HTTP 429 returns rate-limit message and keeps pending action.
- [ ] URL-like text during knowledge-base update is rejected with `URL ingestion is not supported. Send plain text instead.`
- [x] Callback query is answered on tested callback routes.
- [ ] Webhook secret mismatch is rejected before database access when using Webhook mode.
- [ ] `/cancel` clears pending action and keeps selected agent.
- [ ] Rapid double-submit/session concurrency behavior was observed or documented.

## Observed Results Log

| Test | Result | Evidence / Notes |
| --- | --- | --- |
| Schema import | Pass | Imported into a clean MySQL 8 database. |
| Seed import | Pass | Imported into the same clean database with placeholder IDs. |
| Seed counts | Pass | users 3, agents 4, sessions 3, kb_orphans 0. |
| Cross-user SQL authorization | Pass | User 1 query for a user 2 internal agent returned 0 rows. |
| User 1 ownership SQL query | Pass | Returned only user 1's seeded agents. |
| Main n8n import | Pass | Main workflow imported successfully into a clean n8n workspace. |
| Error n8n import | Pass | Error workflow imported successfully into a clean n8n workspace. |
| Credential reference inspection | Pass | Workflow credential references are placeholders; no raw credential values are present. |
| Telegram bot check | Pass | Bot identity check and chat delivery succeeded with a real test bot. |
| ElevenLabs direct API check | Pass | Real test agents returned HTTP 200 JSON with `conversation_config`. |
| `/start` menu | Pass | User `/start` update was received and main menu with inline buttons was sent successfully. |
| Agent list | Pass | `menu:select_agent` callback was received and answered; the agent list contained only the user's test agents. |
| Agent selection | Pass | Internal agent selection callback was received, answered, authorized, and confirmed. |
| Free-form prompt command | Pass | Workflow includes a parser for commands such as `update my agent to answer Hello world`; valid parsed commands reuse the same selected-agent ownership check before ElevenLabs update nodes. |
| Prompt update | Pass | Telegram text was received; ElevenLabs GET/PATCH returned HTTP 200; follow-up GET confirmed the prompt matched the Telegram text; success message sent. |
| Welcome update | Pass | Telegram text was received; ElevenLabs GET/PATCH returned HTTP 200; follow-up GET confirmed `first_message` matched the Telegram text; success message sent. |
| Knowledge-base update | Pass | Telegram text was received; text document was created, attached with PATCH HTTP 200, and confirmed in `knowledge_base`; success message sent. |
| Edge response delivery | Partial | URL-ingestion rejection and cancel response texts were delivered to Telegram; full stateful edge workflows were not all driven end to end. |
| Cross-user callback | Pass | Database authorization returned zero for an internal agent owned by a different seeded user, and the unauthorized branch has no path to ElevenLabs nodes. |
| Orphan knowledge document | Not observed | No orphan was created during successful knowledge-base testing. |

## Final Submission Reminder

Do not include API keys, bot tokens, passwords, private credential exports, or private customer data in this file.
