import io
import pandas as pd
import requests
import json
import os
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """
    
    endpoint = 'https://api.github.com/graphql'
    token = os.getenv('GITHUB_API_TOKEN')  # Replace YOUR_TOKEN_HERE with your actual token

    print(token)
    graphql_query = {
        "query": """
{
  repository(owner: "freeCodeCamp", name: "freeCodeCamp") {
    stargazers (first: 100) {
      pageInfo {
        endCursor
        hasNextPage
      }
      edges {
       starredAt
      }
    }
  }
}
        """
    }

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}',
    }

    response = requests.post(endpoint, headers=headers, json=graphql_query)

    try:
        response_data = response.json()
        print(response_data['data'])
        return response_data['data']
        
    except Exception as error:
        print(error)
        return error






# @test
# def test_output(output, *args) -> None:
#     """
#     Template code for testing the output of the block.
#     """
#     assert output is not None, 'The output is undefined'