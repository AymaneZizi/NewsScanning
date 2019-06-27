#!/usr/bin/python


from wsgiref.handlers import CGIHandler

import newsApp


CGIHandler().run(newsApp)