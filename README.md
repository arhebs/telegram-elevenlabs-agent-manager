# Telegram ElevenLabs Agent Manager

This repository contains an n8n workflow, MySQL schema, seed data, and reviewer notes for a Telegram bot that lets authorized users manage only their own ElevenLabs voice agents.

## Deliverables

- `workflow/telegram-elevenlabs-agent-manager.json` - main n8n workflow export.
- `workflow/telegram-agent-manager-error-handler.json` - Error Trigger workflow for unexpected failures.
- `database/schema.sql` - MySQL schema for Telegram users, linked voice agents, sessions, and orphaned knowledge-base documents.
- `database/seed.sql` - sample users, agents, and sessions for reviewer testing.
- `docs/setup.md` - setup, import, credentials, entry mode, and runtime notes.
- `docs/api-notes.md` - ElevenLabs API endpoints, payload strategy, and error behavior.
- `docs/test-notes.md` - manual test checklist and result log template.

## Setup Order

1. Create a MySQL database.
2. Run `database/schema.sql`.
3. Replace sample Telegram IDs and ElevenLabs agent IDs in `database/seed.sql`.
4. Run `database/seed.sql`.
5. Import `workflow/telegram-elevenlabs-agent-manager.json` into n8n.
6. Import `workflow/telegram-agent-manager-error-handler.json` and set it as the main workflow's error workflow.
7. Configure Telegram, MySQL, and ElevenLabs credentials in n8n.
8. Activate the Telegram Trigger polling workflow.
9. Test `/start` from each seeded Telegram user.
