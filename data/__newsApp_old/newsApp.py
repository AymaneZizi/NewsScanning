import json
import bottle
from bottle import route, run, request, abort, Bottle, SimpleTemplate, template, static_file, url
from pymongo import MongoClient
from datetime import datetime, timedelta
from bson.son import SON
from bson.json_util import dumps
 
client = MongoClient('mongodb://Gareth:funkyk200@ds047095.mongolab.com:47095/newsnet')
db = client.newsnet

app = Bottle()

end = datetime(2014, 5,25)
start = end - timedelta(days=7)

keyword_list = []
company_list = []
concept_list = []

keyword_filter = ["upper right corner", "time", "cent", "comment box", "personal attacks", "FAQ page", "province", "civil forum", "Monday", "Alberta", "people", "company", "changes", "report", "Premier Rachel Notley", "Minister Joe Ceci", "blog posts", "government", "information","comments","chamges","city", "facebook","Mayor Don Iveson","Changes","Thursday"] 
company_filter = ["Facebook","CBC","TSX","Twitter","CBC News","FACEBOOK","Whitecourt Press", "Postmedia News", "Nova Scotia", "dot Alberta", "Bloomberg", "Associated Press", "Cochrane Eagle", "Premier Notley","Medicine Hat"]
concept_filter = ["United States", "Police","Alberta", "Calgary", "Canada", "Edmonton", "English-language films", "news", "News", "Government","Comment","Provinces and territories of Canada","British Columbia"]

@app.route('/static/<filename>', name='static')
def server_static(filename):
   return static_file(filename, root='/static')

@app.route('/', method='GET')
def main():

    flare = {  
   "name":"EcDev",
   "children":[  
      {  
         "name":"business and industrial",
         "children":[  
            {  
               "name":"advertising and marketing"
            },
            {  
               "name":"aerospace and defense"
            },
            {  
               "name":"agriculture and forestry"
            },
            {  
               "name":"automation"
            },
            {  
               "name":"biomedical"
            },
            {  
               "name":"business operations"
            },
            {  
               "name":"chemicals industry"
            },
            {  
               "name":"company"
            },
            {  
               "name":"construction"
            },
            {  
               "name":"energy",
               "children":[  
                  {  
                     "name":"coal"
                  },
                  {  
                     "name":"electricity"
                  },
                  {  
                     "name":"natural gas"
                  },
                  {  
                     "name":"nuclear power"
                  },
                  {  
                     "name":"oil"
                  },
                  {  
                     "name":"renewable energy"
                  }
               ]
            },
            {  
               "name":"logistics"
            },
            {  
               "name":"manufacturing"
            }
         ]
      },
      {  
         "name":"careers"
      },
      {  
         "name":"finance"
      },
      {  
         "name":"law, govt and politics",
         "children":[  
                  {  
                     "name":"government"
                  },
                  {  
                     "name":"immigration"
                  },
                  {  
                     "name":"politics"
                  }
               ]
      },
      {  
         "name":"real estate"
      },
      {  
         "name":"science"
      },
      {  
         "name":"society",
         "children":[  
            {  
               "name":"work"
            }
         ]
      }
     
   ]
}

    flare = dumps(flare)


    pipeline = [
    {"$match":{"date2": {'$gte': start, '$lt': end}}},
    {"$unwind": '$entities'}, 
    {"$match":{"entities.type":"Person"}},
    {"$group": {"_id": '$entities.entities_text', "count": {"$sum": 1}}},
    {"$sort": SON([("count", -1), ("_id", -1)])},
    {"$limit": 10},


    ]

    print(flare)

    try:
        entity2 = list(db.news.aggregate(pipeline))
        response3 = dumps(entity2)
        
    except:
        response3 = []

    pipeline2 = [
    {"$match":{"date2": {'$gte': start, '$lt': end}}},
    {"$unwind": '$entities'}, 
    {"$match":{"entities.type":"Company"}},
    {"$group": {"_id": '$entities.entities_text', "count": {"$sum": 1}, "avg": {"$avg": "$entities.sentiment.score"}}},
    {"$sort": SON([("count", -1), ("_id", -1)])},
    {"$limit": 50}
    ]

    try:
        entity3 = list(db.news.aggregate(pipeline2))
        for item in entity3:
            if item['_id'] not in company_filter:
               company_list.append(item)
      
        response4 = dumps(company_list[:10])
        
    except:
        response4 = []

    pipeline3 = [
    {"$match":{"date2": {'$gte': start, '$lt': end}}},
    {"$unwind": '$keywords'}, 
    {"$group": {"_id": '$keywords.keywords_text', "count": {"$sum": 1}}},
    {"$sort": SON([("count", -1), ("_id", -1)])},
    {"$limit": 50}
    ]
   
    try:
        entity4 = list(db.news.aggregate(pipeline3))
        for item in entity4:
            if item['_id'] not in keyword_filter:
               keyword_list.append(item)
      
        response5 = dumps(keyword_list[:10])
        
    except:
        response5 = []

    pipeline4 = [
    {"$match":{"date2": {'$gte': start, '$lt': end}}},
    {"$unwind": '$concepts'}, 
    {"$group": {"_id": '$concepts.concepts_text', "count": {"$sum": 1}}},
    {"$sort": SON([("count", -1), ("_id", -1)])},
    {"$limit": 50}
    ]

    try:
        entity5 = list(db.news.aggregate(pipeline4))
        for item in entity5:
            if item['_id'] not in concept_filter:
               concept_list.append(item)
        response6 = dumps(concept_list[:10])
        
    except:
        response6 = []

    headlines = dumps(list(db.news.find({}, {"source":1,"title.title":1, "date":1, "title.url":1}).limit(200).sort("_id",-1)))
    
    return template('template89', flare=flare, response3=response3, response4=response4, response5=response5, response6=response6, headlines=headlines)

@app.route("/query", method=["GET"])
def query():

    category = request.query.get('name')

    if category == "EcDev":
      entity2 = list(db.news.find())
    else:
      entity2 = list(db.news.find({"taxonomy.label":{"$elemMatch":{"$in":[category]}} }))
    
    entity3 = dumps(entity2)
    return entity3

@app.route("/tagentity", method=["GET"])
def query():

    entity = request.query.get('name')

    entity2 = list(db.news.find({"entities.entities_text": entity }))
    entity3 = dumps(entity2)
    return entity3

@app.route("/tagkeyword", method=["GET"])
def query():

    keyword = request.query.get('name')

    entity2 = list(db.news.find({"keywords.keywords_text": keyword }))
    entity3 = dumps(entity2)
    return entity3

@app.route("/tagconcept", method=["GET"])
def query():

    concept = request.query.get('name')

    entity2 = list(db.news.find({"concepts.concepts_text": concept }))
    entity3 = dumps(entity2)
    return entity3

if __name__ == '__main__':
	run(app, host=''0.0.0.0', port=8883, reloader=True)