#!/usr/bin/python

import sqlite3
import os
import threading
import time
import Queue
from time import strftime
import feedparser     
import csv
import itertools
from datetime import datetime
import calendar
 
month = datetime.now().strftime("%B")

THREAD_LIMIT = 20
jobs = Queue.Queue(0)
rss_to_process = Queue.Queue(THREAD_LIMIT)
 
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATABASE = os.path.join('/var/www/html/IMAP/rss_' + month + '.sqlite')

print "Getting articles from the internet..."

if os.path.isfile(DATABASE) != True:
  
    conn = sqlite3.connect(DATABASE, timeout = 50)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()

    # grab RSS feeds
    with open('/var/www/html/IMAP/rss_feeds.csv', 'rb') as f:
        reader = csv.reader(f)
        RSS_URLS_1 = list(reader)
    RSS_URLS = itertools.chain(*RSS_URLS_1)     
     
    #insert initial values into feed database
    c.execute('CREATE TABLE IF NOT EXISTS RSSFeeds (id INTEGER PRIMARY KEY AUTOINCREMENT, url VARCHAR(1000));')
    c.execute('CREATE TABLE IF NOT EXISTS RSSEntries (entry_id INTEGER PRIMARY KEY AUTOINCREMENT, id, url, title, summary, date);')
    for item in RSS_URLS:
        c.execute("INSERT INTO RSSFeeds(url) VALUES(?)", (item,))
 
else:
    conn = sqlite3.connect(DATABASE, timeout = 50)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()

feeds = c.execute('SELECT id, url FROM RSSFeeds').fetchall()
 
def store_feed_items(id, items):
    """ Takes a feed_id and a list of items and stores them in the DB """
	
    print "storing feeds into the database"
	
    try:
        for entry in items:
            c.execute('SELECT entry_id from RSSEntries WHERE url=?', (entry.link,))
            if len(c.fetchall()) == 0:
                c.execute('INSERT INTO RSSEntries (id, url, title, summary, date) VALUES (?,?,?,?,?)', (id, entry.link, entry.title, entry.summary, strftime("%Y-%m-%d %H:%M:%S",entry.updated_parsed)))
    except:
        pass
        
def thread():
    while True:
        try:
            id, feed_url = jobs.get(False) # False = Don't wait
        except Queue.Empty:
            return
 
        entries = feedparser.parse(feed_url).entries
        rss_to_process.put((id, entries), True) # This will block if full
     
 
for info in feeds: # Queue them up
    jobs.put([info['id'], info['url']])
 
for n in xrange(THREAD_LIMIT):
    t = threading.Thread(target=thread)
    t.start()
 
while threading.activeCount() > 1 or not rss_to_process.empty():
    # That condition means we want to do this loop if there are threads
    # running OR there's stuff to process
    try:
        id, entries = rss_to_process.get(False, 1) # Wait for up to a second
    except Queue.Empty:
        continue
 
    store_feed_items(id, entries)

conn.commit()