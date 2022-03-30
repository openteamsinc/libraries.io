
docker-compose  run --rm web rake search:recreate_issues_index
 docker-compose  run --rm web rake search:recreate_projects_index
 docker-compose  run --rm web rake search:recreate_repos_index
 docker-compose  run --rm web rake search:reindex_everything
#docker-compose -f docker-compose-dev.yml run -d --rm web rake search:reindex_projects
