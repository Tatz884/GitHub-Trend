SELECT
  {{ dbt_date.from_unixtimestamp("LAST_MODIFIED_TIME", format="milliseconds") }} AS time_updated

FROM
  `ringed-reach-414622.github_trend.__TABLES__`
WHERE
  table_id = 'dtm_topics_from_hot_repos'