WITH split_topics AS (
  SELECT
    REGEXP_REPLACE(topic, ' ', '') AS topic, repo_name

  FROM
    `ringed-reach-414622.github_trend.hot_repo_details`, 
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