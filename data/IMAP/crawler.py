import urlparse
import urllib
import BeautifulSoup
import pprint

url = "http://majorprojects.alberta.ca"

urls = [url] # urls to scrape
visited= [url] # already visited urls

soup = BeautifulSoup.BeautifulSoup(url)
tables = soup.findChildren("table table-sortable table-bordered table-condensed table-striped table-hover table-responsive")
print tables