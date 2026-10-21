USE insta_clone;

-- 1. Home feed for user 1: posts from people they follow, newest first
SELECT p.id, u.username, p.caption, p.created_at,
       s.like_count, s.comment_count
FROM follows f
JOIN posts p        ON p.user_id = f.followee_id
JOIN users u        ON u.id = p.user_id
JOIN v_post_stats s ON s.post_id = p.id
WHERE f.follower_id = 1 AND f.status = 'accepted'
ORDER BY p.created_at DESC
LIMIT 20;

-- 2. Profile stats
SELECT * FROM v_user_stats WHERE username = 'alice';

-- 3. A user's posts with their media
SELECT p.id, p.caption, m.media_url, m.media_type, m.position
FROM posts p
JOIN post_media m ON m.post_id = p.id
WHERE p.user_id = 2
ORDER BY p.created_at DESC, m.position;

-- 4. Comments on a post with replies nested under parents
SELECT c.id, c.parent_id, u.username, c.body, c.created_at
FROM comments c
JOIN users u ON u.id = c.user_id
WHERE c.post_id = 1
ORDER BY COALESCE(c.parent_id, c.id), c.parent_id IS NOT NULL, c.created_at;

-- 5. Who liked a post
SELECT u.username, pl.created_at
FROM post_likes pl JOIN users u ON u.id = pl.user_id
WHERE pl.post_id = 2;

-- 6. Posts for a hashtag
SELECT p.id, p.caption
FROM hashtags h
JOIN post_hashtags ph ON ph.hashtag_id = h.id
JOIN posts p          ON p.id = ph.post_id
WHERE h.tag = 'travel';

-- 7. Trending hashtags
SELECT h.tag, COUNT(*) AS uses
FROM post_hashtags ph JOIN hashtags h ON h.id = ph.hashtag_id
GROUP BY h.id ORDER BY uses DESC LIMIT 5;

-- 8. Active stories (not expired) from people user 1 follows
SELECT s.id, u.username, s.media_url, s.expires_at
FROM stories s
JOIN follows f ON f.followee_id = s.user_id AND f.follower_id = 1
JOIN users u   ON u.id = s.user_id
WHERE s.expires_at > NOW();

-- 9. Follow suggestions: friends-of-friends that user 1 does not follow yet
SELECT u.username, COUNT(*) AS mutual_connections
FROM follows f1
JOIN follows f2 ON f2.follower_id = f1.followee_id
JOIN users u    ON u.id = f2.followee_id
WHERE f1.follower_id = 1
  AND f2.followee_id <> 1
  AND f2.followee_id NOT IN (SELECT followee_id FROM follows WHERE follower_id = 1)
GROUP BY u.id
ORDER BY mutual_connections DESC;

-- 10. Conversation between two users
SELECT s.username AS sender, m.body, m.created_at
FROM messages m JOIN users s ON s.id = m.sender_id
WHERE (m.sender_id = 1 AND m.receiver_id = 2)
   OR (m.sender_id = 2 AND m.receiver_id = 1)
ORDER BY m.created_at;

-- 11. Unread message count per user
SELECT receiver_id, COUNT(*) AS unread
FROM messages WHERE is_read = FALSE GROUP BY receiver_id;

-- 12. Delete expired stories (run on a schedule, e.g. MySQL EVENT or cron)
-- DELETE FROM stories WHERE expires_at <= NOW();
