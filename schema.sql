-- ============================================================
-- Instagram-like schema for MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS insta_clone;
CREATE DATABASE insta_clone
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE insta_clone;

-- ------------------------------------------------------------
-- users
-- ------------------------------------------------------------
CREATE TABLE users (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(30)  NOT NULL,
  email          VARCHAR(255) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  full_name      VARCHAR(100) NULL,
  bio            VARCHAR(150) NULL,
  avatar_url     VARCHAR(500) NULL,
  is_private     BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                              ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- follows  (follower -> followee)
-- ------------------------------------------------------------
CREATE TABLE follows (
  follower_id  BIGINT UNSIGNED NOT NULL,
  followee_id  BIGINT UNSIGNED NOT NULL,
  status       ENUM('pending','accepted') NOT NULL DEFAULT 'accepted',
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, followee_id),
  KEY idx_follows_followee (followee_id),
  CONSTRAINT fk_follows_follower FOREIGN KEY (follower_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_follows_followee FOREIGN KEY (followee_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT chk_no_self_follow CHECK (follower_id <> followee_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- posts
-- ------------------------------------------------------------
CREATE TABLE posts (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NOT NULL,
  caption     VARCHAR(2200) NULL,
  location    VARCHAR(255)  NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_posts_user_created (user_id, created_at),
  CONSTRAINT fk_posts_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- post_media  (a post can have many images/videos = carousel)
-- ------------------------------------------------------------
CREATE TABLE post_media (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  post_id    BIGINT UNSIGNED NOT NULL,
  media_url  VARCHAR(500) NOT NULL,
  media_type ENUM('image','video') NOT NULL DEFAULT 'image',
  position   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  UNIQUE KEY uq_post_media_position (post_id, position),
  CONSTRAINT fk_post_media_post FOREIGN KEY (post_id)
    REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- comments  (parent_id enables threaded replies)
-- ------------------------------------------------------------
CREATE TABLE comments (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  post_id     BIGINT UNSIGNED NOT NULL,
  user_id     BIGINT UNSIGNED NOT NULL,
  parent_id   BIGINT UNSIGNED NULL,
  body        VARCHAR(2200) NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_comments_post_created (post_id, created_at),
  KEY idx_comments_user (user_id),
  CONSTRAINT fk_comments_post FOREIGN KEY (post_id)
    REFERENCES posts(id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_parent FOREIGN KEY (parent_id)
    REFERENCES comments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- post_likes
-- ------------------------------------------------------------
CREATE TABLE post_likes (
  user_id     BIGINT UNSIGNED NOT NULL,
  post_id     BIGINT UNSIGNED NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  KEY idx_post_likes_post (post_id),
  CONSTRAINT fk_post_likes_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_post_likes_post FOREIGN KEY (post_id)
    REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- comment_likes
-- ------------------------------------------------------------
CREATE TABLE comment_likes (
  user_id     BIGINT UNSIGNED NOT NULL,
  comment_id  BIGINT UNSIGNED NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, comment_id),
  KEY idx_comment_likes_comment (comment_id),
  CONSTRAINT fk_comment_likes_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_comment_likes_comment FOREIGN KEY (comment_id)
    REFERENCES comments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- hashtags + post_hashtags  (many-to-many)
-- ------------------------------------------------------------
CREATE TABLE hashtags (
  id    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tag   VARCHAR(100) NOT NULL,
  UNIQUE KEY uq_hashtags_tag (tag)
) ENGINE=InnoDB;

CREATE TABLE post_hashtags (
  post_id     BIGINT UNSIGNED NOT NULL,
  hashtag_id  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (post_id, hashtag_id),
  KEY idx_post_hashtags_tag (hashtag_id),
  CONSTRAINT fk_post_hashtags_post FOREIGN KEY (post_id)
    REFERENCES posts(id) ON DELETE CASCADE,
  CONSTRAINT fk_post_hashtags_tag FOREIGN KEY (hashtag_id)
    REFERENCES hashtags(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- stories (expire after 24h)
-- ------------------------------------------------------------
CREATE TABLE stories (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NOT NULL,
  media_url   VARCHAR(500) NOT NULL,
  media_type  ENUM('image','video') NOT NULL DEFAULT 'image',
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at  TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL 1 DAY),
  KEY idx_stories_user_expires (user_id, expires_at),
  CONSTRAINT fk_stories_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- saved_posts (bookmarks)
-- ------------------------------------------------------------
CREATE TABLE saved_posts (
  user_id     BIGINT UNSIGNED NOT NULL,
  post_id     BIGINT UNSIGNED NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  CONSTRAINT fk_saved_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_saved_post FOREIGN KEY (post_id)
    REFERENCES posts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- direct messages
-- ------------------------------------------------------------
CREATE TABLE messages (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sender_id    BIGINT UNSIGNED NOT NULL,
  receiver_id  BIGINT UNSIGNED NOT NULL,
  body         TEXT NOT NULL,
  is_read      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_messages_receiver (receiver_id, is_read, created_at),
  KEY idx_messages_pair (sender_id, receiver_id, created_at),
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id)
    REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id)
    REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Views
-- ------------------------------------------------------------
CREATE VIEW v_post_stats AS
SELECT
  p.id AS post_id,
  p.user_id,
  p.created_at,
  (SELECT COUNT(*) FROM post_likes pl WHERE pl.post_id = p.id) AS like_count,
  (SELECT COUNT(*) FROM comments c   WHERE c.post_id  = p.id) AS comment_count
FROM posts p;

CREATE VIEW v_user_stats AS
SELECT
  u.id AS user_id,
  u.username,
  (SELECT COUNT(*) FROM posts   WHERE user_id = u.id)                         AS post_count,
  (SELECT COUNT(*) FROM follows WHERE followee_id = u.id AND status='accepted') AS follower_count,
  (SELECT COUNT(*) FROM follows WHERE follower_id = u.id AND status='accepted') AS following_count
FROM users u;
