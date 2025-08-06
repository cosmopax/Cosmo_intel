#!/bin/bash
#
# ===================================================================================
#   Self-Building Project Script: Cosmos Intel - A Unified Signal Intelligence Platform
# ===================================================================================
#
# Instructions for the receiving AI (Jules @ Google):
# This is a self-extracting shell script. To build the 'Cosmos Intel' project's
# foundational codebase, save this entire text block as a single file
# (e.g., `build_project.sh`), make it executable (`chmod +x build_project.sh`),
# and then run it (`./build_project.sh`).
#
# It will create the v1.0 Reddit scraper and a comprehensive README.md file
# that contains the greater vision, architecture, and a concrete roadmap for
# expansion into a cross-domain intelligence platform.
#
# ===================================================================================

echo "--- Initializing Cosmos Intel Project Builder ---"

# --- 1. Create Project Structure ---
echo "[+] Creating project directory: cosmos_intel"
mkdir -p cosmos_intel
cd cosmos_intel

# --- 2. Create requirements.txt ---
echo "[+] Generating requirements.txt for v1.0..."
cat > requirements.txt << "REQ_EOF"
streamlit
pandas
praw
tqdm
spacy
requests
REQ_EOF

# --- 3. Create .gitignore ---
echo "[+] Generating .gitignore..."
cat > .gitignore << "GIT_EOF"
# Configuration files with secrets
config.ini

# Data files
*.csv
*.db

# Python cache
__pycache__/
*.pyc
.DS_Store
GIT_EOF

# --- 4. Create config.ini.template ---
echo "[+] Generating config.ini.template..."
cat > config.ini.template << "CONF_EOF"
[reddit]
client_id = YOUR_REDDIT_CLIENT_ID
client_secret = YOUR_REDDIT_CLIENT_SECRET
user_agent = cosmos_intel/1.0 by YOUR_REDDIT_USERNAME
CONF_EOF

# --- 5. Create the Visionary README.md ---
echo "[+] Generating visionary README.md..."
cat > README.md << "README_EOF"
# Cosmos Intel: A Unified Signal Intelligence Platform

## 1. Vision Statement
**Cosmos Intel** is an intelligence platform designed to move beyond single-source data scraping and into the realm of **cross-domain signal analysis**. Its purpose is to detect, correlate, and visualize the lifecycle of ideas, technologies, and narratives as they emerge and propagate across disparate domains—from academic literature and open-source codebases to mainstream news and public discourse. The ultimate goal is to provide researchers with early, high-fidelity signals of technological disruption, scientific breakthroughs, and shifting market sentiment.

---

## 2. The Core Architecture: A Modular "Fetcher" Design
The platform is built on a modular "fetcher" architecture. The current v1.0 codebase includes a functional fetcher for Reddit, but the system is designed for rapid expansion. Each new data source (GitHub, Google Scholar, etc.) will be a self-contained module, feeding a unified data processing pipeline.

---

## 3. The Greater Vision: Cross-Domain Intelligence

The platform's unique value is its ability to connect the dots between seemingly unrelated events.

### Example Use Case: Tracking a Breakthrough
1.  **Signal (Academia):** A new paper on a novel ML architecture appears on **ArXiv**.
2.  **Correlation (Code):** A new **GitHub** repository implementing the paper is created and rapidly gains stars.
3.  **Correlation (Talent):** Key developers from major tech firms begin contributing to the repo.
4.  **Correlation (Narrative):** Tech **newsletters** and mainstream **news** outlets begin mentioning the paper and its implementation.
5.  **Actionable Intelligence:** This chain of events, detected and correlated by Cosmos Intel, provides a powerful, early signal of a potentially disruptive technology long before it becomes common knowledge.

### High-Value Signals by Domain:
-   **Code (GitHub):** Track technology adoption velocity (star history, commit frequency), developer sentiment (issue analysis), and talent flow between organizations.
-   **Academia (ArXiv, Google Scholar, PubMed):** Track citation velocity, identify key researchers and institutions, and perform trend analysis on keywords within abstracts to see what's on the horizon.
-   **News & Newsletters (NewsAPI, RSS):** Perform narrative analysis to see how ideas are framed as they move from niche to mainstream, and identify authoritative sources that are first to break trends.
-   **Public Discourse (Reddit):** Quantify public perception, identify real-world applications and pain points, and measure sentiment shifts around products, companies, and technologies.

---

## 4. Concrete Development Roadmap

### Phase 1: Multi-Source Ingestion & Unified Data Model (The Foundation)
1.  **Build New Fetchers:** Develop and integrate the core data fetchers for:
    -   `github_fetcher.py` (using PyGithub)
    -   `scholar_fetcher.py` (for academic journals via Semantic Scholar/Google Scholar APIs)
    -   `news_fetcher.py` (using NewsAPI)
2.  **Unified Database Schema:** Architect a **PostgreSQL** database to store data from these disparate sources in a linked, relational model. Key tables will include `publications`, `repositories`, `authors`, `commits`, `articles`, and a central `entities` table to link them all.
3.  **Historical Data Backfill:** Integrate the Pushshift.io API to ingest historical Reddit data, providing a rich dataset for trend back-testing.

### Phase 2: The Correlation Engine (The Intelligence Layer)
1.  **Cross-Domain NER:** Implement a state-of-the-art Named Entity Recognition (NER) model to find and disambiguate the *same entities* (e.g., "Project Gemini," "$NVDA," "CRISPR-Cas9") across all data sources. This is the lynchpin of the platform.
2.  **Event Detection:** Develop logic to automatically detect and flag significant events, such as "New High-Impact Repository Created," "Paper Citation Velocity Spike," or "Sudden Shift in News Sentiment."
3.  **Graph Analysis:** Model the data as a graph (e.g., using Neo4j or networkx) to discover non-obvious paths and relationships between events, authors, and technologies.

### Phase 3: The Intelligence Dashboard (The Interface)
1.  **Timeline Visualization:** Create a UI that visualizes the lifecycle of an idea as an interactive timeline, showing its first mention on ArXiv, the first implementation on GitHub, and its first mention in the news.
2.  **Thematic Dashboards:** Build dashboards focused on specific user-defined topics (e.g., "AI Hardware," "Longevity Biotech") that aggregate and visualize correlated signals from all sources.
3.  **Scoring & Alerting System:** Develop a "significance score" for events and chains of events. Build a user-facing system to create custom alerts based on these scores and other triggers.
README_EOF

# --- 6. Create the Python Application Files (v1.0 Reddit Scraper) ---
echo "[+] Generating Python source files for v1.0..."
cat > cosmoscrape.py << "APP_LOGIC_EOF"
import praw
import pandas as pd
import datetime
from tqdm import tqdm
import configparser

def get_reddit_instance(config_file='config.ini'):
    config = configparser.ConfigParser()
    if not config.read(config_file) or 'reddit' not in config:
        raise FileNotFoundError(f"Error: Make sure 'config.ini' is created from the template and filled out.")
    try:
        reddit_config = config['reddit']
        return praw.Reddit(
            client_id=reddit_config['client_id'],
            client_secret=reddit_config['client_secret'],
            user_agent=reddit_config['user_agent']
        )
    except KeyError:
        raise ValueError("Error: Config file must contain client_id, client_secret, and user_agent.")

def scrape_data(reddit, subreddit_name, post_limit=50, listing='hot'):
    subreddit = reddit.subreddit( subreddit_name )
    posts_list, comments_list = [], []

    if listing == 'hot': post_iterator = subreddit.hot(limit=post_limit)
    elif listing == 'new': post_iterator = subreddit.new(limit=post_limit)
    else: post_iterator = subreddit.top(limit=post_limit)

    for post in tqdm(post_iterator, total=post_limit, desc=f"Scraping r/{subreddit_name}"):
        posts_list.append({'post_id':post.id, 'title':post.title, 'score':post.score, 'num_comments':post.num_comments, 'created_utc':datetime.datetime.fromtimestamp(post.created_utc), 'url':post.url, 'body':post.selftext, 'author':post.author.name if post.author else '[deleted]'})
        post.comments.replace_more(limit=0)
        for comment in post.comments.list():
            comments_list.append({'comment_id':comment.id, 'post_id':post.id, 'author':comment.author.name if comment.author else '[deleted]', 'body':comment.body, 'score':comment.score})

    return pd.DataFrame(posts_list), pd.DataFrame(comments_list)
APP_LOGIC_EOF

cat > ui.py << "APP_UI_EOF"
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
APP_UI_EOF

# --- 7. Final Instructions ---
echo
echo "✅✅✅ Cosmos Intel Project Builder Finished ✅✅✅"
echo
echo "Project 'cosmos_intel' has been created."
echo "Next Steps for Jules:"
echo "1. Create a Conda environment and install dependencies from 'requirements.txt'."
echo "2. Copy 'config.ini.template' to 'config.ini' and add your Reddit API credentials."
echo "3. Run the application with: streamlit run ui.py"
echo "4. Review the generated README.md for the full project vision and roadmap."
echo
EOF
