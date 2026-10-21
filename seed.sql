USE insta_clone;

-- NOTE: password hashes are placeholders, not real bcrypt hashes.
INSERT INTO users (username, email, password_hash, full_name, bio, is_private) VALUES
  ('alice',  'alice@example.com',  'hash_alice',  'Alice Johnson', 'Coffee, code and cats',   FALSE),
  ('bob',    'bob@example.com',    'hash_bob',    'Bob Smith',     'Travel photographer',     FALSE),
  ('carol',  'carol@example.com',  'hash_carol',  'Carol Lee',     'Foodie | Runner',         FALSE),
  ('dave',   'dave@example.com',   'hash_dave',   'Dave Brown',    'Just here for the memes', TRUE),
  ('eve',    'eve@example.com',    'hash_eve',    'Eve Adams',     'Designer',                FALSE);

INSERT INTO follows (follower_id, followee_id, status) VALUES
  (1, 2, 'accepted'), (1, 3, 'accepted'), (2, 1, 'accepted'),
  (3, 1, 'accepted'), (3, 2, 'accepted'), (5, 1, 'accepted'),
  (5, 4, 'pending'),  (2, 3, 'accepted');

INSERT INTO posts (user_id, caption, location) VALUES
  (1, 'Morning coffee vibes #coffee #morning',           'Cairo, Egypt'),
  (2, 'Sunset over the dunes #travel #sunset',           'Siwa Oasis'),
  (2, 'Street life #travel #streetphotography',          'Alexandria'),
  (3, 'Best pasta I have ever made #food #homemade',     NULL),
  (1, 'New project launch! #code #launch',               NULL),
  (4, 'Meme of the day #memes',                          NULL);

INSERT INTO post_media (post_id, media_url, media_type, position) VALUES
  (1, 'https://cdn.example.com/p1_1.jpg', 'image', 0),
  (2, 'https://cdn.example.com/p2_1.jpg', 'image', 0),
  (2, 'https://cdn.example.com/p2_2.jpg', 'image', 1),
  (3, 'https://cdn.example.com/p3_1.jpg', 'image', 0),
  (4, 'https://cdn.example.com/p4_1.mp4', 'video', 0),
  (5, 'https://cdn.example.com/p5_1.jpg', 'image', 0),
  (6, 'https://cdn.example.com/p6_1.jpg', 'image', 0);

INSERT INTO hashtags (tag) VALUES
  ('coffee'), ('morning'), ('travel'), ('sunset'), ('streetphotography'),
  ('food'), ('homemade'), ('code'), ('launch'), ('memes');

INSERT INTO post_hashtags (post_id, hashtag_id) VALUES
  (1,1),(1,2),(2,3),(2,4),(3,3),(3,5),(4,6),(4,7),(5,8),(5,9),(6,10);

INSERT INTO post_likes (user_id, post_id) VALUES
  (2,1),(3,1),(5,1),(1,2),(3,2),(5,2),(1,3),(1,4),(2,4),(3,5),(2,5),(1,6);

INSERT INTO comments (post_id, user_id, parent_id, body) VALUES
  (1, 2, NULL, 'Looks delicious!'),
  (1, 1, 1,    'Thanks Bob!'),
  (2, 1, NULL, 'Stunning shot'),
  (2, 3, NULL, 'Adding Siwa to my bucket list'),
  (4, 1, NULL, 'Recipe please!'),
  (5, 2, NULL, 'Congrats!');

INSERT INTO comment_likes (user_id, comment_id) VALUES
  (1,1),(3,1),(2,2),(2,3);

INSERT INTO stories (user_id, media_url) VALUES
  (1, 'https://cdn.example.com/s1.jpg'),
  (2, 'https://cdn.example.com/s2.jpg');

INSERT INTO saved_posts (user_id, post_id) VALUES (1,2),(3,2),(1,4);

INSERT INTO messages (sender_id, receiver_id, body, is_read) VALUES
  (1, 2, 'Hey Bob, loved your Siwa photos!', TRUE),
  (2, 1, 'Thanks Alice! Want to go together next time?', FALSE),
  (3, 1, 'Can you share the pasta recipe?', FALSE);
