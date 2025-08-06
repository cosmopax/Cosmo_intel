from github import Github
import pandas as pd

def get_github_instance():
    # For now, we'll use a placeholder for the access token.
    # In a real application, this should be read from a config file or environment variable.
    access_token = "YOUR_GITHUB_ACCESS_TOKEN"
    if access_token == "YOUR_GITHUB_ACCESS_TOKEN":
        print("Warning: You are using a placeholder GitHub access token. Please replace it with your own.")
        return Github()
    else:
        return Github(access_token)

def scrape_github_data(g, repo_name):
    try:
        repo = g.get_repo(repo_name)
        stargazers = repo.stargazers_count
        forks = repo.forks_count

        commits_list = []
        for commit in repo.get_commits().reversed[:10]: # Get the last 10 commits
            commits_list.append({
                'sha': commit.sha,
                'author': commit.commit.author.name,
                'date': commit.commit.author.date,
                'message': commit.commit.message
            })

        repo_data = {
            'repo_name': repo.full_name,
            'stars': stargazers,
            'forks': forks,
            'description': repo.description,
            'language': repo.language,
            'url': repo.html_url
        }

        return pd.DataFrame([repo_data]), pd.DataFrame(commits_list)
    except Exception as e:
        print(f"An error occurred while scraping GitHub data: {e}")
        return pd.DataFrame(), pd.DataFrame()
