#!/usr/local/bin/python
#!/usr/local/bin/python

import sqlite3
import os
import threading
#!/usr/local/bin/python

import time
import Queue
from time import strftime
import feedparser     
import csv
import itertools
 
THREAD_LIMIT = 20
jobs = Queue.Queue(0)
rss_to_process = Queue.Queue(THREAD_LIMIT)
 
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATABASE_Edmonton = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Edmonton_may.sqlite')
DATABASE_Calgary = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Calgary_may.sqlite')
DATABASE_Alberta = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Alberta_may.sqlite')
DATABASE_Vancouver = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Vancouver_may.sqlite')
DATABASE_Ontario = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Ontario_may.sqlite')
DATABASE_World = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/World_may.sqlite')


databases = [DATABASE_Edmonton, DATABASE_Calgary, DATABASE_Alberta, DATABASE_Vancouver, DATABASE_Ontario, DATABASE_World]

#with open('rss/edmonton_rss.csv', 'rb') as f:
#   reader = csv.reader(f)
#   RSS_URLS_1 = list(reader)
#RSS_URLS = itertools.chain(*RSS_URLS_1)     
     
#insert initial values into feed database
#c.execute('CREATE TABLE IF NOT EXISTS RSSFeeds (id INTEGER PRIMARY KEY AUTOINCREMENT, url VARCHAR(1000));')
#c.execute('CREATE TABLE IF NOT EXISTS RSSEntries (entry_id INTEGER PRIMARY KEY AUTOINCREMENT, id, feed, url, title, summary, date);')
#for item in RSS_URLS:
#    c.execute("INSERT INTO RSSFeeds(url) VALUES(?)", (item,))

def store_feed_items(id, items):
    """ Takes a feed_id and a list of items and stores them in the DB """
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
     
for database in databases:
    try:
        conn = sqlite3.connect(database, timeout = 50)
    except:
        time.sleep(300)
        conn = sqlite3.connect(database, timeout = 50)

    conn.row_factory = sqlite3.Row
    c = conn.cursor()

    feeds = c.execute('SELECT id, url FROM RSSFeeds').fetchall()
    articles = c.execute('SELECT id, url FROM RSSEntries').fetchall()
    count1 = len(articles)
    print "There are " + str(count1) + " articles in the " + database + " database"
    
    for info in feeds: 
        jobs.put([info['id'], info['url']])
     
    for n in xrange(THREAD_LIMIT):
        t = threading.Thread(target=thread)
        t.start()
     
    while threading.activeCount() > 1 or not rss_to_process.empty():
        
        try:
            id, entries = rss_to_process.get(False, 1) 
        except Queue.Empty:
            continue
   
        store_feed_items(id, entries)

    count2 = len(c.execute('SELECT * from RSSEntries').fetchall())

    added = count2 - count1

    print "There were " + str(added) + " articles added to the " + database + " database"
 
    conn.commit()