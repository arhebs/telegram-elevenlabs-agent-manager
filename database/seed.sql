-- Replace 111111111, 222222222, 333333333, and all agent_* values
-- with real Telegram user IDs and real ElevenLabs agent IDs before live testing.
-- Keep user 3 active with no agents so reviewers can test the no-agent path.

INSERT INTO telegram_users (id, telegram_user_id, username, first_name, is_active)
VALUES
  (1, 111111111, 'alice_reviewer', 'Alice', TRUE),
  (2, 222222222, 'bob_reviewer', 'Bob', TRUE),
  (3, 333333333, 'no_agent_reviewer', 'NoAgent', TRUE);

INSERT INTO voice_agents (id, user_id, elevenlabs_agent_id, agent_name)
VALUES
  (1, 1, 'agent_alice_sales', 'Alice Sales Agent'),
  (2, 1, 'agent_alice_support', 'Alice Support Agent'),
  (3, 2, 'agent_bob_reception', 'Bob Reception Agent'),
  (4, 2, 'agent_bob_booking', 'Bob Booking Agent');

INSERT INTO user_sessions (user_id, selected_voice_agent_id, pending_action)
VALUES
  (1, NULL, NULL),
  (2, NULL, NULL),
  (3, NULL, NULL);
