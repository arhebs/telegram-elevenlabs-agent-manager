# API Notes

## ElevenLabs Endpoints

- `GET https://api.elevenlabs.io/v1/convai/agents/{agent_id}`
- `PATCH https://api.elevenlabs.io/v1/convai/agents/{agent_id}`
- `POST https://api.elevenlabs.io/v1/convai/knowledge-base/text`

## OpenRouter Intent Classification

- `POST https://openrouter.ai/api/v1/chat/completions`
- Model: `openai/gpt-5.4-nano`
- Purpose: classify natural-language Telegram messages into one of `update_prompt`, `update_welcome_message`, `update_knowledge_text`, or `none`.
- Output mode: Structured Outputs with a strict JSON schema.

The AI step does not bypass authorization. Its output is validated, then routed through the same MySQL ownership check before any ElevenLabs API call.

## Official Docs Checked

- https://elevenlabs.io/docs/api-reference/agents/get
- https://elevenlabs.io/docs/api-reference/agents/update
- https://elevenlabs.io/docs/api-reference/knowledge-base/create-from-text
- https://elevenlabs.io/docs/conversational-ai/customization/knowledge-base

## Required Headers

- `xi-api-key`
- `Content-Type: application/json`

## PATCH Strategy

Use GET + merge + PATCH unless live testing confirms safe partial nested updates.

The workflow is structured around the conservative strategy:

1. GET the current agent.
2. Merge only the field being updated into `conversation_config`.
3. PATCH the merged `conversation_config` back to the agent.

This avoids assuming that partial nested PATCH operations preserve untouched nested settings.

## Prompt Update Payload

Target field:

```json
{
  "conversation_config": {
    "agent": {
      "prompt": {
        "prompt": "{{update_text}}"
      }
    }
  }
}
```

The workflow builds this from the current GET response and sets `conversation_config.agent.prompt.prompt`.

## Welcome Message Update Payload

Target field:

```json
{
  "conversation_config": {
    "agent": {
      "first_message": "{{update_text}}"
    }
  }
}
```

The workflow builds this from the current GET response and sets `conversation_config.agent.first_message`.

## Knowledge-Base Text Create Payload

```json
{
  "text": "{{update_text}}",
  "name": "{{agent_name}} Telegram KB {{timestamp}}"
}
```

After a successful create call, the workflow GETs the agent, appends `{ "type": "text", "name": document.name, "id": document.id }` to `conversation_config.agent.prompt.knowledge_base`, and PATCHes the merged list.

## Rate Limits

On HTTP 429, the bot responds:

```text
Too many requests. Please wait a moment and try again.
```

The workflow does not clear `pending_action` on HTTP 429.

## Status Mapping

- 2xx: continue to success handling.
- 401/403: send `ElevenLabs authentication failed. Please contact support.` and clear `pending_action`.
- 404: send `That agent is no longer available. Choose another agent.` and clear selected agent plus pending action.
- 422: send `Update failed. Please review the text and try again.` and keep `pending_action`.
- 429: send the rate-limit message and keep `pending_action`.
- Other non-2xx: send `Update failed. Please try again later.` and keep `pending_action`.

## Live Testing Notes

Live API checks on May 14, 2026 confirmed the conservative GET + merge + PATCH strategy against a real test agent:

- `GET /v1/convai/agents/{agent_id}` returned agent JSON with `conversation_config`.
- Prompt and welcome updates succeeded with `PATCH /v1/convai/agents/{agent_id}` using `{ "conversation_config": ... }`.
- `POST /v1/convai/knowledge-base/text` created a text knowledge-base document.
- Appending the created document to `conversation_config.agent.prompt.knowledge_base` and PATCHing the agent succeeded.

Partial nested PATCH was not used or relied on.
