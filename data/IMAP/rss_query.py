#!/usr/bin/python

import sqlite3
import os
import pprint
from sklearn.externals import joblib
from datetime import date, time
import smtplib
import pickle
from datetime import datetime
import warnings

warnings.filterwarnings("ignore")

month = datetime.now().strftime("%B")

date = date.today().isoformat() 
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATABASE = os.path.join('/var/www/html/IMAP/rss_' + month + '.sqlite')

conn = sqlite3.connect(DATABASE)
c = conn.cursor()

conn.row_factory = sqlite3.Row

c.execute("SELECT Url, summary FROM RSSEntries where date >= date('now', '-1 day');")
x = c.fetchall()

a = dict(x)

b = list(a.keys())
c = list(a.values())
d = len(b)

clf = joblib.load('/var/www/html/IMAP/classifier/SVCinvestmentclassifier.pk1')

predict = clf.predict(c)

new = dict(zip(b, predict))

investment_urls = []

print "Creating list of articles for today..."

for keys, value in new.iteritems():
    if value == 0:
        investment_urls.append(keys)
    else:
        pass

obj = pickle.load(open('/var/www/html/IMAP/old_links.txt'))
	
ui = list(set(investment_urls) - set(obj))

with open('/var/www/html/IMAP/old_links.txt', 'wb') as f:
        pickle.dump(ui, f)
  
i_urls = """From """ + str(d) + ' articles on ' + date + ', ' + str(len(ui)) + ' were classified as relating to investment and unique to this day:\n\n%s\n' % ',\n'.join(ui)
    
def sendemail(from_addr, to_addr, subject, message, login, password, smtpserver='smtp.gmail.com:587'):
    header = 'From: %s\n' % from_addr
    header += 'To: %s\n' % ','.join(to_addr)
    header += 'Subject: %s\n\n' % subject
    message = header + message
    
    server = smtplib.SMTP(smtpserver)
    server.starttls()
    server.login(login,password)
    problems = server.sendmail(from_addr, to_addr, message)
    server.quit()
    return problems
    
sendemail(from_addr = 'imap.projects@gmail.com', to_addr = ['gareth.higgins@gov.ab.ca','julie.rossignol@gov.ab.ca','kyle.lillie@gov.ab.ca','matthew.sheremeta@gov.ab.ca'], subject = date + ' Capital Projects', message = i_urls, login = 'imap.projects@gmail.com', password = 'Epsilon200')
