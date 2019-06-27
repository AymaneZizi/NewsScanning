from __future__ import print_function
from pymongo import MongoClient
from bson.son import SON
import pprint
from time import time
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.decomposition import NMF, LatentDirichletAllocation
from sklearn.datasets import fetch_20newsgroups
import os, os.path, codecs
import numpy as np
import sqlite3
from sklearn.externals import joblib
from datetime import date, datetime
import smtplib
import pickle
import re

def striphtml(data):
    p = re.compile(r'<.*?>')
    return p.sub('', data)

n_samples = 2000
n_features = 1000
n_topics = 7
n_top_words = 5

client = MongoClient('mongodb://Gareth:funkyk200@ds047095.mongolab.com:47095/newsnet')
db = client.newsnet


x = list(db.articles.find({'category': 'Economy_Business_Finance'}))

nnnn = []
for i in x:
  i['text'] = i['text'].replace('\n', '')
  i['text'] = striphtml(i['text'])
  nnnn.append(i['text'])

def print_top_words(model, feature_names, n_top_words):
    for topic_idx, topic in enumerate(model.components_):
        print("Topic #%d:" % topic_idx)
        print(" ".join([feature_names[i]
                        for i in topic.argsort()[:-n_top_words - 1:-1]]))
    print()

# Load the 20 newsgroups dataset and vectorize it. We use a few heuristics
# to filter out useless terms early on: the posts are stripped of headers,
# footers and quoted replies, and common English words, words occurring in
# only one document or in at least 95% of the documents are removed.


dir_data = "articles2"
file_paths = [os.path.join(dir_data, fname) for fname in os.listdir(dir_data) if fname.endswith(".txt") ]
documents = [codecs.open(file_path, 'r', encoding="utf8", errors='ignore').read() for file_path in file_paths ]

t0 = time()

print("done in %0.3fs." % (time() - t0))

# Use tf-idf features for NMF.
print("Extracting tf-idf features for NMF...")
tfidf_vectorizer = TfidfVectorizer(max_df=1, min_df=1, #max_features=n_features,
                                   stop_words='english')
t0 = time()
tfidf = tfidf_vectorizer.fit_transform(nnnn)
print("done in %0.3fs." % (time() - t0))

# Use tf (raw term count) features for LDA.
print("Extracting tf features for LDA...")
tf_vectorizer = CountVectorizer(max_df=1, min_df=1, max_features=n_features,
                                stop_words='english')
t0 = time()
tf = tf_vectorizer.fit_transform(nnnn)
print("done in %0.3fs." % (time() - t0))

# Fit the NMF model
print("Fitting the NMF model with tf-idf features,"
      "n_samples=%d and n_features=%d..."
      % (n_samples, n_features))
t0 = time()
nmf = NMF(n_components=n_topics, random_state=1, alpha=.1, l1_ratio=.5).fit(tfidf)

print("done in %0.3fs." % (time() - t0))

print("\nTopics in NMF model:")
tfidf_feature_names = tfidf_vectorizer.get_feature_names()
for x in tfidf_feature_names:
  x.encode('utf-8')
print_top_words(nmf, tfidf_feature_names, n_top_words)

print("Fitting LDA models with tf features, n_samples=%d and n_features=%d..."
      % (n_samples, n_features))
lda = LatentDirichletAllocation(n_topics=n_topics, max_iter=5,
                                learning_method='online', learning_offset=50.,
                                random_state=0)
t0 = time()
lda.fit(tf)
print("done in %0.3fs." % (time() - t0))

print("\nTopics in LDA model:")
tf_feature_names = tf_vectorizer.get_feature_names()
print_top_words(lda, tf_feature_names, n_top_words)

