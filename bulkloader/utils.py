
from google.appengine.ext import db

class Pi(db.Model):
    pass

class Pw(db.Model):
    pass

class deleter(object):
    def run(self, kind, batch_size=200):
        q = db.GqlQuery("select __key__ from %s" % (kind))
        entities = q.fetch(batch_size)
        while entities:
            db.delete(entities)
            q.with_cursor(q.cursor())
            entities = q.fetch(batch_size)

