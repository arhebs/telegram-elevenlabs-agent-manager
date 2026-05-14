CREATE TABLE telegram_users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  telegram_user_id BIGINT NOT NULL UNIQUE,
  username VARCHAR(255) NULL,
  first_name VARCHAR(255) NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE voice_agents (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  elevenlabs_agent_id VARCHAR(255) NOT NULL,
  agent_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_agent (user_id, elevenlabs_agent_id),
  UNIQUE KEY unique_elevenlabs_agent_id (elevenlabs_agent_id),
  KEY idx_voice_agents_user_id (user_id),
  CONSTRAINT fk_voice_agents_user
    FOREIGN KEY (user_id)
    REFERENCES telegram_users (id)
    ON DELETE CASCADE
);

CREATE TABLE user_sessions (
  user_id BIGINT UNSIGNED PRIMARY KEY,
  selected_voice_agent_id BIGINT UNSIGNED NULL,
  pending_action ENUM(
    'update_prompt',
    'update_welcome_message',
    'update_knowledge_text'
  ) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_user_sessions_selected_voice_agent_id (selected_voice_agent_id),
  CONSTRAINT fk_user_sessions_user
    FOREIGN KEY (user_id)
    REFERENCES telegram_users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_user_sessions_selected_agent
    FOREIGN KEY (selected_voice_agent_id)
    REFERENCES voice_agents (id)
    ON DELETE SET NULL
);

CREATE TABLE kb_orphan_documents (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  voice_agent_id BIGINT UNSIGNED NOT NULL,
  elevenlabs_agent_id VARCHAR(255) NOT NULL,
  elevenlabs_document_id VARCHAR(255) NOT NULL,
  document_name VARCHAR(255) NULL,
  failure_status_code INT NULL,
  failure_response_json JSON NULL,
  resolved_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_kb_orphans_user_id (user_id),
  KEY idx_kb_orphans_voice_agent_id (voice_agent_id),
  KEY idx_kb_orphans_document_id (elevenlabs_document_id),
  CONSTRAINT fk_kb_orphans_user
    FOREIGN KEY (user_id)
    REFERENCES telegram_users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_kb_orphans_voice_agent
    FOREIGN KEY (voice_agent_id)
    REFERENCES voice_agents (id)
    ON DELETE CASCADE
);
