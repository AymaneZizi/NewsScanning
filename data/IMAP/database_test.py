from pymongo import MongoClient
from s4sdk.textanalytics_api import TextanalyticsApi
from s4sdk.swagger import ApiClient
from s4sdk.graphdb_api import GraphDBApi
from s4sdk.swagger import ApiClient
import sqlite3
import os
import pprint
from datetime import date, time, datetime
import json
import re

date = date.today().isoformat() 


BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATABASE = os.path.join(BASE_DIR, 'C:/_LOCALData/imap/rss.sqlite')

conn = sqlite3.connect(DATABASE)
c = conn.cursor()

conn.row_factory = sqlite3.Row

c.execute("SELECT date, Url, title, summary, date FROM RSSEntries where date >= date('now', '-1 day');")
get_all = c.fetchmany(5)

key = ['date', 'url', 'title', 'summary', 'date2']
m = []
for row in get_all:
	m.append(dict(zip(key,row)))


list_of_dicts = []
api_key = "s4epqberh6t3"
key_secret = "jaij914veq4e51d"
endpoint_annotater = "https://text.s4.ontotext.com/v1/news"
endpoint_classifier = "https://text.s4.ontotext.com/v1/news-classifier"

client2 = ApiClient(api_key=api_key, key_secret=key_secret, endpoint=endpoint_annotater)
client3 = ApiClient(api_key=api_key, key_secret=key_secret, endpoint=endpoint_classifier)
accessor = TextanalyticsApi(client2)
accessor2 = TextanalyticsApi(client3)

for i in m:
	item = i['summary']
	keyphrases = set()
	locations = set()
	career = set()
	organizations = set()
	people = set()
	acquisition = set()
	org_rel = set()

	payload = {"document": item, "documentType": "text/plain"}
		
	try:
		returned = accessor.process("json", body=payload)
	except:
		print("there was an error processing an article")

	try:
		returned_class = accessor2.process("json", body=payload)
	except:
		print("there was an error processing an article")

	nn = json.loads(returned)
	nm = json.loads(returned_class)

	category = nm['category']

	try:
		for item2 in nn['entities']['Keyphrase']:
			keyphrases.add(item2['string'])
	except:
		pass

	try:
		for item2 in nn['entities']['Location']:
			locations.add(item2['string'])
	except:
		pass

	try:
		for item2 in nn['entities']['RelationPersonCareer']:
			career.add(item2['string'])
	except:
		pass

	try:
		for item2 in nn['entities']['Organization']:
			organizations.add(item2['string'])
	except:
		pass

	try:
		for item2 in nn['entities']['Person']:
			people.add(item2['string'])
	except:
		pass

	try:
		for item2 in nn['entities']['RelationAcquisition']:
			acquisition.add(item2['string'])
	except:
		pass

	try:
		for item2 in nn['entities']['RelationOrganizationOrganization']:
			org_rel.add(item2['string'])
	except:
		pass

	keyphrases = list(keyphrases)
	locations = list(locations)
	career = list(career)
	organizations = list(organizations)
	people = list(people)
	acquisition = list(acquisition)
	org_rel = list(org_rel)

	list_of_dicts.append(dict(title=i['title'], date2=i['date2'],url=i['url'], text=item, category=category, keyphrases=keyphrases, locations=locations, career=career, organizations=organizations, people=people, acquisition=acquisition, date=datetime.utcnow()))

pprint.pprint(list_of_dicts)