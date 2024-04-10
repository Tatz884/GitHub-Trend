-- models/starring_events.sql
{% set yesterday = modules.datetime.datetime.now() - modules.datetime.timedelta(days=1) %}
{% set formatted_yesterday = yesterday.strftime('%Y%m%d') %}


WITH StarredRepos AS (
  SELECT
    repo.name AS owner_name_and_repo_name,
    COUNT(*) AS stars_gained
  FROM
    `githubarchive.day.{{ formatted_yesterday }}`
  WHERE
    type = 'WatchEvent'
  GROUP BY
    owner_name_and_repo_name
)


