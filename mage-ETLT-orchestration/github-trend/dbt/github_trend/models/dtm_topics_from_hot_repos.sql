WITH split_topics AS (
  SELECT
    REGEXP_REPLACE(topic, ' ', '') AS topic, repo_name
     -- UNNEST and SPLIT functions may vary by SQL dialect
  FROM
    `ringed-reach-414622.github_trend.hot_repo_details`, -- Replace with your actual table name
    UNNEST(SPLIT(topics, ',')) AS topic
)

SELECT
  topic,
  repo_name
FROM
  split_topics
WHERE
  topic != ''
ORDER BY
  topic, repo_name