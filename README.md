# GitHub Trend

Visualization of technology trend, updating regularly.

## What questions does this dashboard address?

- What repositories are popular in GitHub now? 
- What languages are used in popular repositories? 
- What topics are common across popular repositories?

## Dashboard

[The link to running dashboard](https://lookerstudio.google.com/s/gtrvrMCNeI0)

[![Dashboard Image](./assets/dashboard.png)](https://lookerstudio.google.com/s/gtrvrMCNeI0)

## Data Pipeline

This is the batch data pipeline. The data update is scheduled everyday until the creator's free GCP credit runs out.

<img src="./assets/architecture.png" walt="Architecture Image" />

### The flow of data pipeline:

#### Top repos
1. Obtain the list of the repositories that have the top 100 highest number of stars from GitHub using GraphQL API
2. On BigQuery, join the obtained data with GitHub Archive public data, that regularly retrieve the number of events (including star events) everyday
3. Display the data on Looker Studio dashboard

#### Hot repos
1. On BigQuery, get all the starring events yesterday from GitHub Archive public data, then make the list of repositories that obtained >100 stars yesterday
2. Using that list, obtain information that is not in the public data (e.g. image icon, the current number of stars etc) from GitHub API
3. Join all the data in BigQuery
4. Display the data on Looker Studio dashboard

## Contribution

