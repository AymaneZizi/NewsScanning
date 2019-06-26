import os
import re
import json
import pprint as pp
import sqlite3
from pymongo import MongoClient
import datetime
import feedparser
import pandas as pd

import spacy #python -m spacy download en
from spacy import displacy
from tqdm import tqdm
import time
import pickle

'''
focus now on fivefilters stuff; do classification later
import tensorflow_hub as hub
import tensorflow as tf

from sklearn.datasets import fetch_20newsgroups
newsgroups_train = fetch_20newsgroups(subset='train')
#https://scikit-learn.org/0.19/datasets/twenty_newsgroups.html

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import f1_score

from allennlp.predictors.predictor import Predictor
from allennlp.modules.text_field_embedders import TextFieldEmbedder, BasicTextFieldEmbedder
from allennlp.modules.token_embedders import Embedding
from allennlp.modules.seq2seq_encoders import Seq2SeqEncoder, PytorchSeq2SeqWrapper
from allennlp.nn.util import get_text_field_mask, sequence_cross_entropy_with_logits
'''

if not os.path.exists(os.getcwd()+'/data'):
    os.mkdir(os.getcwd()+'/data')

class sql:
    '''//////////////////////////////
    -- articles stored here --
    //////////////////////////////'''
    def save(df):

        conn = sqlite3.connect('data/articles.db')
        df.to_sql('articles', conn, if_exists='append')
        
        conn.execute('VACUUM')
        
        conn.close()

    def query(query='SELECT * FROM articles'):

        conn = sqlite3.connect('data/articles.db')
        df = pd.read_sql_query(query, conn)
        
        conn.close()
        
        return (df)

class mongo:
    '''//////////////////////////////
    -- article meta tags stored here --
    //////////////////////////////'''
    
    def save(df):

        try:
            client = MongoClient('localhost',27017) #Replace mongo db name

        except Exception as e:
            print (e)
        
        db = client.data
        collection = db.articles
        
        records = df.to_dict(orient='records')
        #pp.pprint(records)
        collection.insert_many(records)
        
        print ('Data saved')

    def query(find={}):
        
        try:
            client = MongoClient()
        
        except Exception as e:
            print (e)
            
        db = client.data
        collection = db.articles
        
        df = pd.DataFrame(test.find())
        print (df)

class classify:

    def clean(df):
        # remove punctuation marks
        punctuation = '!"#$%&()*+-/:;<=>?@[\\]^_`{|}~'

        df['clean'] = df['summary'].apply(lambda x: ''.join(ch for ch in x if ch not in set(punctuation)))

        # convert text to lowercase
        df.clean = df.clean.str.lower()

        # remove numbers
        df['clean'] = df.clean.str.replace("[0-9]", " ")

        # remove whitespaces
        df.clean = df.clean.replace('&nbsp;',' ')
        df.clean = df.clean.apply(lambda x:' '.join(x.split()))
        
        return (df)
        
        def lemmatize(text):
        
            #import spaCy's language model
            nlp = spacy.load('en', disable=['parser', 'ner'])
                
            output = []
        
            for i in text:
                s = [token.lemma_ for token in nlp(i)]
                output.append(' '.join(s))

            return (output)
            
        df['clean'] = lemmatize(df['clean'])

        return (df)

    def elmo_vectors(x):
    
        elmo = hub.Module("https://tfhub.dev/google/elmo/2", trainable=True)
        embeddings = elmo(x.tolist(), signature="default", as_dict=True)["elmo"]
        
        with tf.Session() as sess:
            sess.run(tf.global_variables_initializer())
            sess.run(tf.tables_initializer())
            # return average of ELMo features
            return sess.run(tf.reduce_mean(embeddings,1))
    
    def article(text=''):
        os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
        'https://allennlp.org/models'
        
        #following this:
        #https://www.analyticsvidhya.com/blog/2019/03/learn-to-use-elmo-to-extract-features-from-text/
        
        train = classify.clean(sql.query('SELECT * FROM articles LIMIT 400'))
        test = classify.clean(sql.query('SELECT * FROM articles ORDER BY title DESC LIMIT 300'))
                
        print (train.shape)
        print (test.shape)

        train['summary'].value_counts(normalize = True)
        
        list_train = [train[i:i+100] for i in range(0,train.shape[0],100)]
        list_test = [test[i:i+100] for i in range(0,test.shape[0],100)]

        # Extract ELMo embeddings
        elmo_train = [classify.elmo_vectors(x['clean']) for x in list_train]
        elmo_test = [classify.elmo_vectors(x['clean']) for x in list_test]

        elmo_train_new = np.concatenate(elmo_train, axis = 0)
        elmo_test_new = np.concatenate(elmo_test, axis = 0)
        
        # save elmo_train_new
        pickle_out = open("elmo_train_03032019.pickle","wb")
        pickle.dump(elmo_train_new, pickle_out)
        pickle_out.close()

        # save elmo_test_new
        pickle_out = open("elmo_test_03032019.pickle","wb")
        pickle.dump(elmo_test_new, pickle_out)
        pickle_out.close()
        
        # load elmo_train_new
        pickle_in = open("elmo_train_03032019.pickle", "rb")
        elmo_train_new = pickle.load(pickle_in)

        # load elmo_train_new
        pickle_in = open("elmo_test_03032019.pickle", "rb")
        elmo_test_new = pickle.load(pickle_in)
        
        #model building and evaluation
        xtrain, xvalid, ytrain, yvalid = train_test_split(elmo_train_new, 
                                                  train['label'],
                                                  random_state=42,
                                                  test_size=0.2)
                                                  
        lreg = LogisticRegression()
        lreg.fit(xtrain, ytrain)
        preds_valid = lreg.predict(xvalid)
        print (f1_score(yvalid,preds_valid))
          
def classy():

    sentence = '''Boeing CEO Dennis Muilenburg will have his work cut out for him at the Paris Air Show this week as he tries to reassure airlines and industry partners over the fate of its flagship 737 MAX plane, indefinitely grounded after two fatal crashes.Aviation regulators meeting last month were unable to determine when the popular jet might again be allowed to fly, causing costly headaches for airlines worldwide."An air show is a good opportunity to connect with customers, suppliers and fellow aerospace manufacturers to strengthen our partnerships and drive industry safety," Muilenburg posted on Twitter over the weekend.He has already apologised and vowed to come up with a fix for the 737 MAX's automated anti-stall system, blamed for an Ethiopian Airlines crash in March and an Indonesian Lion Air crash in October, which together claimed 346 lives.But in comments to journalists later Sunday he acknowledged the work they still had to do."We have work to do to win and regain the trust of the public," said Muilenburg."We come to this salon focussed on safety. We come with a sense of humility and learning, still confident in our market -- but it's a humble confidence."But reports that US safety regulators may have let Boeing engineers self-certify some of the plane's equipment have battered confidence in the company."It's had a very clear impact on Boeing's brand and reputation," said Pascal Fabre at the consulting firm Alix Partners.The crisis has also rattled pilots as well as national aviation regulators who worry about a lack of sufficient oversight at the American heavyweight.And on the financial front, it could provide an opening for archrival Airbus to win over new customers for its own A320 family of single-aisle jets, which constitute by far the biggest share of airlines' fleets.- No quick fix -Alongside the nearly 2,500 firms descending on the Bourget airport north of Paris this week will be nearly 290 official delegations, many of which will probably want a word with Muilenburg.He is facing calls for compensation by airlines who have had to find other planes or cancel flights outright after their 737s were grounded.In late April, Boeing estimated the crisis would cost it $1 billion, but the bill will surely climb the longer the planes stay on the ground.Families of the victims of the Ethiopian Airlines and Lion Air crashes may also sue for damages if Boeing is found to have been negligent.And many of its suppliers are also seething. General Electric, whose CFM unit makes the 737's engines with its French partner Safran, has said the groundings could cost it $200 million to $300 million in the second quarter alone.Alexandre de Juniac, director general of the International Air Transport Association (IATA), has said certification might not come before August.But some airlines aren't taking any chances, with American Airlines cancelling last week all its 737 MAX flights through to September 3.Until now global regulators have relied on a system of mutual reciprocity for certifying planes, but the EU, Canada and Brazil have indicated they will carry out their own inspection of any fix for the 737 MAX."Our hope is that we'll have a broad international alignment with the FAA" on when to resume the flights, Muilenburg said at an investor conference in New York last month, referring to the US Federal Aviation Administration.Boeing now has 140 737 MAXs parked on its tarmac waiting for delivery, and has had to reduce monthly production to 42 planes from 52 previously.'''
    
    sp = spacy.load('en_core_web_md')
    sen = sp(sentence)
    print (sen.ents)
    
    for ent in sen.ents:
        print(ent.text,ent.label_)
      
    # predictor = Predictor.from_path("https://s3-us-west-2.amazonaws.com/allennlp/models/ner-model-2018.12.18.tar.gz")
    # p = predictor.predict(sentence=sentence)
    # t = predictor
    
    # new = list(zip(p['tags'],p['words']))
    
    # for pair in new:
        # print (pair)

def aylien(url):

    from aylienapiclient import textapi
    
    client = textapi.Client('a8b3a850','c46e7039ff55dd00866b3dc1de4ee9d7')
    '''
    extract = client.Extract({'url': url, 'language':'en'})
    sentiment = client.Sentiment({'text':'sample text', 'language':'en'})
    classifications = client.ClassifyByTaxonomy({'url': url, 'language':'en', 'taxonomy': 'iptc-subjectcode'}) #codes demo: http://show.newscodes.org/index.html?newscodes=subj&lang=en-GB&startTo=Show
    classification = client.Classify({'url': url, 'language':'en'})
    entities = client.Entities({'text': text, 'language':'en'})
    concepts = client.Concepts({'text': text, 'language':'en'})
    summary = client.Summarize({'url': url, 'sentences_number': 3})
    '''
    combined = client.Combined({
      'url': url,
      'language':'en',
      'endpoint': ['extract','sentiment','classify/iptc-subjectcode','classify','entities','concepts']
    })
    
    for result in combined['results']:
        print(result['endpoint'])
        print(result['result'])
  
  
def fetch_articles(MAX_RESULTS=100):

    if MAX_RESULTS > 100:
        MAX_RESULTS = 100;

    today = datetime.datetime.now().strftime('%Y-%m-%d')

    '''//////////////////////////////
    -- list of feeds to scrape --
    //////////////////////////////'''
    
    rss = pd.read_csv('feeds.csv')['url'].tolist()

    feeds = [] # list of feed objects
    posts = []

    for url in rss:
        #fivefilters repo: https://bitbucket.org/fivefilters/full-text-rss/src/master/
        local_fulltext_url = 'http://localhost:8000/makefulltextfeed.php?url={}&max={}&links=0&exc=1&format=json&submit=Create+Feed'.format(url.replace('/','%2F'),MAX_RESULTS)
       
        #feed = feedparser.parse(local_fulltext_url)
        feed = json.loads(pd.read_json(local_fulltext_url).to_json())
        
        publication = feed['rss']['channel']['title'].split(' - ')[0]
        print (publication,end='\r')
        if 'item' in feed['rss']['channel'].keys():

            for post in feed['rss']['channel']['item']:
                
                try:
                    title = post['og_title']
                    link = post['link']
                    date = post['pubDate']#use datetime to format better
                    article = re.sub(r'<[^>]*>','',post['description'])
                    
                except:
                    title, link, date, article = '','','',''
                
                try:
                    summary = post['og_description']
                except:
                    summary = ''
                
                try:
                    type = post['og_type']
                except:
                    type = 'article'
                
                try:
                    author = post['dc_creator']
                except:
                    author = ''

                try:
                    tags = post['category']
                except:
                    tags = []
                
                obj = {
                    'publication':publication,
                    'title':title,
                    'link':link,
                    'type':type,
                    'author':author,
                    'date':date,
                    'summary':summary,
                    'article':article,
                    'tags':tags
                    }

                posts.append(obj)
    
    df = pd.DataFrame(posts) # pass data to init
    
    print (list(df))

    df.article = df.article.str.replace(r'(\.(?!com|org|ca|net|\d| |\n))','. ')
    df.article = df.article.str.replace(r'((?![A-Z])\. (?![a-z]|[A-Z][a-z]))','.')
    df.article = df.article.str.replace(r'(www\. )','www.')
    
    df.article = df.article.apply(lambda x:' '.join(x.split()))
    df.title = df.title.apply(lambda x:' '.join(x.split()))
    
    df.date = pd.to_datetime(df.date)
    
    print (df.head())
    
    #sql.save(df)
    #mongo.save(df)
    #print (sql.query())


#aylien('https://edmontonjournal.com/news/politics/alberta-infrastructure-minister-interviewed-by-rcmp-in-ongoing-investigation')

fetch_articles(3)
#classify.article()
#classy()