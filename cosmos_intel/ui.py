import streamlit as st
import pandas as pd
from cosmoscrape import get_reddit_instance, scrape_data
from github_fetcher import get_github_instance, scrape_github_data

st.set_page_config(page_title="Cosmos Intel", page_icon="🔭", layout="centered")
st.title("🔭 Cosmos Intel")
st.markdown("A tool to scrape data from various sources.")

# --- Data Source Selection ---
st.sidebar.header("Data Source")
source = st.sidebar.selectbox("Choose a data source", ["Reddit", "GitHub"])

if source == "Reddit":
    st.sidebar.header("Reddit Scrape Settings")
    try:
        reddit = get_reddit_instance()
        st.sidebar.success("Connected to Reddit API.")
    except Exception as e:
        st.sidebar.error(f"Failed to connect. Check `config.ini`.\n\n{e}")
        st.stop()

    # --- UI Inputs ---
    subreddit_name = st.sidebar.text_input("Subreddit Name (e.g., 'investing')", "wallstreetbets")
    post_limit = st.sidebar.slider("Number of Posts", 10, 500, 50)
    listing_type = st.sidebar.selectbox("Listing Type", ["Hot", "New", "Top"])

    if st.sidebar.button("Start Scraping Reddit"):
        if not subreddit_name:
            st.error("Please enter a subreddit name.")
        else:
            with st.spinner(f"Scraping {post_limit} '{listing_type}' posts from r/{subreddit_name}..."):
                try:
                    posts_df, comments_df = scrape_data(reddit, subreddit_name, post_limit, listing_type.lower())
                    st.success("Scraping Complete!")
                    st.session_state.posts_df = posts_df
                    st.session_state.comments_df = comments_df
                    st.session_state.data_source = "Reddit"
                except Exception as e:
                    st.error(f"An error occurred: {e}")

elif source == "GitHub":
    st.sidebar.header("GitHub Scrape Settings")
    try:
        github = get_github_instance()
        st.sidebar.success("Connected to GitHub API.")
    except Exception as e:
        st.sidebar.error(f"Failed to connect to GitHub API.\n\n{e}")
        st.stop()

    # --- UI Inputs ---
    repo_name = st.sidebar.text_input("Repository Name (e.g., 'owner/repo')", "langchain-ai/langchain")

    if st.sidebar.button("Start Scraping GitHub"):
        if not repo_name:
            st.error("Please enter a repository name.")
        else:
            with st.spinner(f"Scraping data for repository '{repo_name}'..."):
                try:
                    repo_df, commits_df = scrape_github_data(github, repo_name)
                    st.success("Scraping Complete!")
                    st.session_state.repo_df = repo_df
                    st.session_state.commits_df = commits_df
                    st.session_state.data_source = "GitHub"
                except Exception as e:
                    st.error(f"An error occurred: {e}")

# --- Results Display ---
if 'data_source' in st.session_state:
    st.header("Results")
    if st.session_state.data_source == "Reddit":
        if 'posts_df' in st.session_state:
            st.write(f"Found {len(st.session_state.posts_df)} posts and {len(st.session_state.comments_df)} comments.")
            st.dataframe(st.session_state.posts_df)

            col1, col2 = st.columns(2)
            with col1:
                st.download_button( "Download Posts CSV", st.session_state.posts_df.to_csv(index=False).encode('utf-8-sig'), f"{subreddit_name}_posts.csv", "text/csv")
            with col2:
                st.download_button( "Download Comments CSV", st.session_state.comments_df.to_csv(index=False).encode('utf-8-sig'), f"{subreddit_name}_comments.csv", "text/csv")
    elif st.session_state.data_source == "GitHub":
        if 'repo_df' in st.session_state:
            st.write(f"Found data for repository {st.session_state.repo_df['repo_name'].iloc[0]}")
            st.dataframe(st.session_state.repo_df)
            st.write(f"Found {len(st.session_state.commits_df)} recent commits.")
            st.dataframe(st.session_state.commits_df)

            col1, col2 = st.columns(2)
            with col1:
                st.download_button( "Download Repo Info CSV", st.session_state.repo_df.to_csv(index=False).encode('utf-8-sig'), "repo_info.csv", "text/csv")
            with col2:
                st.download_button( "Download Commits CSV", st.session_state.commits_df.to_csv(index=False).encode('utf-8-sig'), "commits.csv", "text/csv")
