""" Continually creates and deletes documents in a CouchDB
database.

This depends on having a running CouchDB. The options module contains
the string COUCHDB_URI which defines the host and port that CouchDB is
running on.
"""

import time

import couchdb

import options
import common

def main():
    # wait for couchdb to start
    time.sleep(2)

    couch = couchdb.Server(options.COUCHDB_URI)
    db = common.get_db(couch, 'app1')

    uuids = common.UUIDsIterator(couch)

    while True:
        # Create docs until there are options.NUM_DOCS docs in the DB
        print 'Create docs'
        common.create_docs(db, options.NUM_DOCS, uuids)
        time.sleep(2)

        # Delete some random docs
        common.delete_random(db, common.random_rows(db, 10), 1)
        time.sleep(2)
