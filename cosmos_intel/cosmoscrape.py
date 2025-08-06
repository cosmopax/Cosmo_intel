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
