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
import requests
import dateutil.parser as parser
from pytz import timezone

date = date.today().isoformat() 
	
def striphtml(data):
    p = re.compile(r'<.*?>')
    return p.sub('', data)

def connect_to_database(database):
	news_articles = []
	BASE_DIR = os.path.dirname(os.path.realpath(__file__))
	DATABASE = os.path.join(BASE_DIR, database)

	conn = sqlite3.connect(DATABASE)
	c = conn.cursor()

	conn.row_factory = sqlite3.Row

	c.execute("SELECT date, Url, title, summary, date, date FROM RSSEntries where date >= date('now', '-1 day');")
	get_all = c.fetchmany(1)

	key = ['date', 'url', 'title', 'summary', 'date2', 'date3']
	
	for row in get_all:
		news_articles.append(dict(zip(key,row)))

	for i in news_articles:
		replacement = datetime.strptime(i['date2'], "%Y-%m-%d %H:%M:%S")
		i['date2'] = replacement.replace(tzinfo=timezone('UTC'))
		i['summary'] = i['summary'].replace('\n', '')
		i['summary'] = striphtml(i['summary'])
		
	return news_articles

    
#def strip_articles(news_articles):

#	stripped_news_articles = []

#	for item in news_articles:
#		article = item['summary']
#		stripped_news_articles.append(striphtml(article))

#	return stripped_news_articles


def classify_articles(news_articles):

	list_of_dicts = []
	api_key = "s4epqberh6t3"
	key_secret = "jaij914veq4e51d"
	endpoint_annotater = "https://text.s4.ontotext.com/v1/news"
	endpoint_classifier = "https://text.s4.ontotext.com/v1/news-classifier"

	client2 = ApiClient(api_key=api_key, key_secret=key_secret, endpoint=endpoint_annotater)
	client3 = ApiClient(api_key=api_key, key_secret=key_secret, endpoint=endpoint_classifier)
	accessor = TextanalyticsApi(client2)
	accessor2 = TextanalyticsApi(client3)

	for i in news_articles:
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
		
		list_of_dicts.append(dict(title=i['title'], date2=i['date2'], feed='Edmonton', date3=i['date3'], url=i['url'], text=item, category=category, keyphrases=keyphrases, locations=locations, career=career, organizations=organizations, people=people, acquisition=acquisition, date=datetime.utcnow()))

	return list_of_dicts

def add_sentiment(list_of_dicts):
	list_of_d = []
	api = 'http://api.meaningcloud.com/sentiment-2.0'
	key = 'b50458e8f10877abc9271edc4f0c6e1a'
	model = 'general_es' # general_es / general_es / general_fr

	for i in list_of_dicts:
		item = i['text']
		parameters = {'key': key,'model': model, 'txt': item, 'src': 'sdk-python-2.0'}
		r = requests.post(api, params=parameters)
		response = r.content.decode('utf-8')
		response_json = json.loads(response)

		try:
		  if len(response_json['sentimented_entity_list']) > 0:
		    entities = response_json['sentimented_entity_list']

		    for item in entities:
		    	if item['form'] in i['people']:
		      	 	i.update(entity=item['form'], sentiment=item['score_tag'])

		    	elif item['form'] in i['career']:
		      		i.update(entity=item['form'], sentiment=item['score_tag'])
		    	else:
		      		pass

		except KeyError:
		  pass

	return list_of_dicts

	
def send_to_database(list_of_dicts):

	client = MongoClient('mongodb://Gareth:funkyk200@ds047095.mongolab.com:47095/newsnet')
	db = client.newsnet
	db.articles.insert(list_of_dicts)

if __name__ == '__main__':
	news_articles = connect_to_database(database='C:/_LOCALData/imap/rss_feeds/Edmonton.sqlite')
	#stripped_news_articles = strip_articles(news_articles=news_articles)
	list_of_dicts = classify_articles(news_articles=news_articles)
	list_of_d = add_sentiment(list_of_dicts=list_of_dicts)
	send_to_database(list_of_dicts=list_of_dicts)