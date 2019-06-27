from pymongo import MongoClient
from bson.son import SON
import pprint

client = MongoClient('mongodb://Gareth:funkyk200@ds047095.mongolab.com:47095/newsnet')
db = client.newsnet
pipeline = [
	{"$unwind": "$keyphrases"}, 
	{"$group": {"_id": "$keyphrases", "count": {"$sum": 1}}},
	{"$sort": SON([("count", -1), ("_id", -1)])}
]
x = list(db.articles.aggregate(pipeline))
p = x[0:20]
pprint.pprint(p)