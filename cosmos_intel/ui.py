import streamlit as st
import pandas as pd
from cosmoscrape import get_reddit_instance, scrape_data

st.set_page_config(page_title="Cosmos Intel (v1.0)", page_icon="🔭", layout="centered")
st.title("🔭 Cosmos Intel (v1.0 - Reddit Fetcher)")
st.markdown("A tool to scrape data from any public subreddit.")

try:
    reddit = get_reddit_instance()
    st.sidebar.success("Connected to Reddit API.")
except Exception as e:
    st.sidebar.error(f"Failed to connect. Check `config.ini`.\n\n{e}")
    st.stop()

# --- UI Inputs ---
st.sidebar.header("Scrape Settings")
subreddit_name = st.sidebar.text_input("Subreddit Name (e.g., 'investing')", "wallstreetbets")
post_limit = st.sidebar.slider("Number of Posts", 10, 500, 50)
listing_type = st.sidebar.selectbox("Listing Type", ["Hot", "New", "Top"])

if st.sidebar.button("Start Scraping"):
    if not subreddit_name:
        st.error("Please enter a subreddit name.")
    else:
        with st.spinner(f"Scraping {post_limit} '{listing_type}' posts from r/{subreddit_name}..."):
            try:
                posts_df, comments_df = scrape_data(reddit, subreddit_name, post_limit, listing_type.lower())
                st.success("Scraping Complete!")
                st.session_state.posts_df = posts_df
                st.session_state.comments_df = comments_df
            except Exception as e:
                st.error(f"An error occurred: {e}")

if 'posts_df' in st.session_state:
    st.header("Results")
    st.write(f"Found {len(st.session_state.posts_df)} posts and {len(st.session_state.comments_df)} comments.")
    st.dataframe(st.session_state.posts_df)

    col1, col2 = st.columns(2)
    with col1:
        st.download_button( "Download Posts CSV", st.session_state.posts_df.to_csv(index=False).encode('utf-8-sig'), f"{subreddit_name}_posts.csv", "text/csv")
    with col2:
        st.download_button( "Download Comments CSV", st.session_state.comments_df.to_csv(index=False).encode('utf-8-sig'), f"{subreddit_name}_comments.csv", "text/csv")
