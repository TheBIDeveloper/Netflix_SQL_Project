USE NetflixAnalytics;
GO

--------------------------------------------------
-- 1. Total watch duration per show
--------------------------------------------------
SELECT s.show_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN shows s ON v.show_id = s.show_id
GROUP BY s.show_name
ORDER BY total_watch_minutes DESC;

--------------------------------------------------
-- 2. Total watch duration per genre
--------------------------------------------------
SELECT g.genre_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN shows s ON v.show_id = s.show_id
JOIN genres g ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_watch_minutes DESC;

--------------------------------------------------
-- 3. Total watch duration per user
--------------------------------------------------
SELECT u.user_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
GROUP BY u.user_name
ORDER BY total_watch_minutes DESC;

--------------------------------------------------
-- 4. Top 5 most-watched shows
--------------------------------------------------
SELECT TOP 5 s.show_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN shows s ON v.show_id = s.show_id
GROUP BY s.show_name
ORDER BY total_watch_minutes DESC;

--------------------------------------------------
-- 5. Average watch duration per session
--------------------------------------------------
SELECT AVG(watch_duration_minutes) AS avg_watch_duration
FROM viewing_sessions;

--------------------------------------------------
-- 6. Total sessions per user
--------------------------------------------------
SELECT u.user_name,
       COUNT(v.session_id) AS total_sessions
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
GROUP BY u.user_name
ORDER BY total_sessions DESC;

--------------------------------------------------
-- 7. Watch duration per country
--------------------------------------------------
SELECT u.country,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
GROUP BY u.country
ORDER BY total_watch_minutes DESC;

--------------------------------------------------
-- 8. Shows watched per country
--------------------------------------------------
SELECT u.country,
       s.show_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
JOIN shows s ON v.show_id = s.show_id
GROUP BY u.country, s.show_name
ORDER BY u.country, total_watch_minutes DESC;

--------------------------------------------------
-- 9. Watch duration per release year
--------------------------------------------------
SELECT s.release_year,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN shows s ON v.show_id = s.show_id
GROUP BY s.release_year
ORDER BY s.release_year;

--------------------------------------------------
-- 10. Most-watched genre per user
--------------------------------------------------
WITH user_genre AS (
    SELECT u.user_name,
           g.genre_name,
           SUM(v.watch_duration_minutes) AS total_minutes
    FROM viewing_sessions v
    JOIN users u ON v.user_id = u.user_id
    JOIN shows s ON v.show_id = s.show_id
    JOIN genres g ON s.genre_id = g.genre_id
    GROUP BY u.user_name, g.genre_name
)
SELECT user_name, genre_name, total_minutes
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY user_name ORDER BY total_minutes DESC) AS rn
    FROM user_genre
) AS t
WHERE rn = 1;

--------------------------------------------------
-- 11. Top active users
--------------------------------------------------
SELECT TOP 5 u.user_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
GROUP BY u.user_name
ORDER BY total_watch_minutes DESC;

--------------------------------------------------
-- 12. Total watch duration per month
--------------------------------------------------
SELECT FORMAT(v.watch_date,'yyyy-MM') AS month,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
GROUP BY FORMAT(v.watch_date,'yyyy-MM')
ORDER BY month;

--------------------------------------------------
-- 13. Shows never watched
--------------------------------------------------
SELECT s.show_name
FROM shows s
LEFT JOIN viewing_sessions v ON s.show_id = v.show_id
WHERE v.show_id IS NULL;

--------------------------------------------------
-- 14. Users who watched all genres
--------------------------------------------------
SELECT u.user_name
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM genres g
    WHERE NOT EXISTS (
        SELECT 1
        FROM viewing_sessions v
        JOIN shows s ON v.show_id = s.show_id
        WHERE v.user_id = u.user_id AND s.genre_id = g.genre_id
    )
);

--------------------------------------------------
-- 15. Average watch duration per genre
--------------------------------------------------
SELECT g.genre_name,
       AVG(v.watch_duration_minutes) AS avg_watch_duration
FROM viewing_sessions v
JOIN shows s ON v.show_id = s.show_id
JOIN genres g ON s.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY avg_watch_duration DESC;

--------------------------------------------------
-- 16. Top 3 shows per country
--------------------------------------------------
WITH ranked_shows AS (
    SELECT u.country,
           s.show_name,
           SUM(v.watch_duration_minutes) AS total_minutes,
           RANK() OVER(PARTITION BY u.country ORDER BY SUM(v.watch_duration_minutes) DESC) AS rnk
    FROM viewing_sessions v
    JOIN users u ON v.user_id = u.user_id
    JOIN shows s ON v.show_id = s.show_id
    GROUP BY u.country, s.show_name
)
SELECT country, show_name, total_minutes
FROM ranked_shows
WHERE rnk <= 3
ORDER BY country, rnk;

--------------------------------------------------
-- 17. Top genres per country
--------------------------------------------------
WITH ranked_genres AS (
    SELECT u.country,
           g.genre_name,
           SUM(v.watch_duration_minutes) AS total_minutes,
           RANK() OVER(PARTITION BY u.country ORDER BY SUM(v.watch_duration_minutes) DESC) AS rnk
    FROM viewing_sessions v
    JOIN users u ON v.user_id = u.user_id
    JOIN shows s ON v.show_id = s.show_id
    JOIN genres g ON s.genre_id = g.genre_id
    GROUP BY u.country, g.genre_name
)
SELECT country, genre_name, total_minutes
FROM ranked_genres
WHERE rnk = 1
ORDER BY country;

--------------------------------------------------
-- 18. Watch sessions per release year
--------------------------------------------------
SELECT s.release_year,
       COUNT(v.session_id) AS total_sessions
FROM viewing_sessions v
JOIN shows s ON v.show_id = s.show_id
GROUP BY s.release_year
ORDER BY s.release_year;

--------------------------------------------------
-- 19. Average watch duration per user
--------------------------------------------------
SELECT u.user_name,
       AVG(v.watch_duration_minutes) AS avg_watch_duration
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
GROUP BY u.user_name
ORDER BY avg_watch_duration DESC;

--------------------------------------------------
-- 20. Users with total watch duration above average
--------------------------------------------------
WITH avg_watch AS (
    SELECT AVG(watch_duration_minutes) AS avg_duration
    FROM viewing_sessions
)
SELECT u.user_name,
       SUM(v.watch_duration_minutes) AS total_watch_minutes
FROM viewing_sessions v
JOIN users u ON v.user_id = u.user_id
GROUP BY u.user_name
HAVING SUM(v.watch_duration_minutes) > (SELECT avg_duration FROM avg_watch)
ORDER BY total_watch_minutes DESC;
