from __future__ import print_function
from sklearn.datasets import load_files
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.linear_model import SGDClassifier
from sklearn import metrics
from sklearn.grid_search import GridSearchCV
from pprint import pprint
from time import time
from sklearn.externals import joblib
import pickle
import logging
import numpy as np

test_case = load_files('articles')

X_train, X_test, y_train, y_test = cross_validation.train_test_split(test_case.data, test_case.target, test_size=0.4, random_state=0)

count_vect = CountVectorizer(decode_error='ignore',strip_accents='unicode')
X_train_counts = count_vect.fit_transform(X_test.data)
X_train_counts.shape

tfidf_transformer = TfidfTransformer()
X_train_tfidf = tfidf_transformer.fit_transform(X_train_counts)
X_train_tfidf.shape

clf = MultinomialNB().fit(X_train_tfidf, test_case.target)
docs_new = ['I like bees', 'emily won the gold medal in the shotput']
X_new_counts = count_vect.transform(docs_new)
X_new_tfidf = tfidf_transformer.transform(X_new_counts)

predicted = clf.predict(X_new_tfidf)

for doc, category in zip(docs_new, predicted):
    print('%r => %s' % (doc, test_case.target_names[category]))

text_clf = Pipeline([
    ('vect', CountVectorizer(decode_error='ignore',max_df=0.75,ngram_range=(1, 1))),
    ('tfidf', TfidfTransformer(use_idf=false,tfidf_norm='l1')),
    ('clf', SGDClassifier(alpha=1e-05,n_iter=80,penalty='elasticnet')),
])

parameters = {
    'vect__max_df': (0.75),
    'vect__max_features': (None),
    'vect__ngram_range': (1, 2),  # unigrams or bigrams
    'tfidf__use_idf': (False),
    'tfidf__norm': ('l2'),
    'clf__alpha': (1e-05),
    'clf__penalty': ('l2'),
    'clf__n_iter': (50),
}

_ = text_clf.fit(test_case.data, test_case.target)

real_test = load_files('test_articles')
docs_test = real_test.data
predicted = text_clf.predict(docs_test)
verified = np.mean(predicted == real_test.target)
print(verified)
print(metrics.classification_report(real_test.target, predicted, target_names=real_test.target_names))

#joblib.dump(text_clf, 'investclass.pk2')


