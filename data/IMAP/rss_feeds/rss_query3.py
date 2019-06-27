#!/usr/local/bin/python
import sqlite3
import os
import pprint
from sklearn.externals import joblib
from datetime import date, time
import smtplib
import pickle

date = date.today().isoformat() 
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATABASE_Edmonton = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Edmonton.sqlite')
DATABASE_Calgary = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Calgary.sqlite')
DATABASE_Alberta = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss_feeds/rss/Alberta.sqlite')

databases = [DATABASE_Edmonton,DATABASE_Calgary,DATABASE_Alberta]

for database in databases:

    conn = sqlite3.connect(database)
    c = conn.cursor()

    conn.row_factory = sqlite3.Row

    c.execute("SELECT Url, summary FROM RSSEntries where date >= date('now', '-1 day');")
    x = c.fetchmany(1)

    if database == 'C:/_LOCALData/imap/rss_feeds/rss/Edmonton.sqlite':
        x.append("Edmonton")
    if database == 'C:/_LOCALData/imap/rss_feeds/rss/Calgary.sqlite':
        x.append("Calgary")
    if database == 'C:/_LOCALData/imap/rss_feeds/rss/Alberta.sqlite':
        x.append("Rest of Alberta")
    pprint.pprint(x)