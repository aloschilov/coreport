""" Common functionality for all the apps """

import random
import couchdb
from couchdb.design import ViewDefinition


db_views = [
    ViewDefinition('rand', 'rand', 
                   """function(doc) {
      emit(doc.n, doc._rev);
    }""")]

def get_db(server, db_name):
    try:
        db = server[db_name]
    except couchdb.ResourceNotFound:
        db = server.create(db_name)
    ViewDefinition.sync_many(db, db_views, remove_missing=True)
    return db

def create_docs(db, num, uuids):
    docs = []
    for i in range(max(0, num - len(db))):
        doc = {'_id': uuids.next(),
               'n': random.uniform(0, 1)}
        docs.append(doc)

    db.update(docs)

def random_rows(db, num):
    view = db.view('rand/rand', 
                   startkey=random.uniform(0, 1), 
                   limit=num)
    return [[row.id, row.value] for row in view]

def delete_random(db, rows, i):
    for row_id, rev in rows:
        print 'Delete:', i, row_id
        try:
            db.save({'_id': row_id,
                     '_rev': rev,
                     '_deleted': True})
        except couchdb.http.ResourceConflict:
            pass

class UUIDsIterator(object):
    "An iterable that grabs UUIDs from couchdb."
    def __init__(self, server, fetch_size=20):
        self._server = server
        self._fetch_size = fetch_size
        self._uuids = []

    def __iter__(self):
        return self

    def next(self):
        if not self._uuids:
            # replenish uuids
            self._uuids.extend(reversed(self._server.uuids(self._fetch_size)))
            #print 'replenished with', self._uuids

        if self._uuids:
            return self._uuids.pop()
        else:
            # unable to fetch more for some reason
            raise StopIteration()
