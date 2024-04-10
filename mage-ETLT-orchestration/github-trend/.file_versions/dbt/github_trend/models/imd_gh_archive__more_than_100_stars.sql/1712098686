SELECT
  owner_name_and_repo_name,
  stars_gained
FROM
  {{ ref('stg_gh_archive__starred_repos') }}
WHERE
  stars_gained >= 100