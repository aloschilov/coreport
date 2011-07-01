""" Continually creates and deletes documents in a CouchDB
database. Works from multiple eventlet greenthreads.

This depends on having a running CouchDB. The options module contains
the string COUCHDB_URI which defines the host and port that CouchDB is
running on.

This also uses the eventlet library.
"""

import time
import random

import couchdb

import options
import common

import eventlet
from eventlet import pools
couchdb = eventlet.import_patched('couchdb')

def worker(i):
    print 'worker', i

    server_pool = pools.Pool(create=lambda: couchdb.Server(options.COUCHDB_URI), max_size=15)

    with server_pool.item() as server:
        while True:
            db = common.get_db(server, 'app2')
            uuids = common.UUIDsIterator(server)

            print 'worker', i, 'create'
            common.create_docs(db, options.NUM_DOCS, uuids)
            eventlet.sleep(random.uniform(0.1, 3))

            # Delete some random docs
            common.delete_random(db, common.random_rows(db, 10), i)
            eventlet.sleep(random.uniform(0.1, 3))

def main():
    # wait for couchdb to start
    time.sleep(2)

    server_pool = pools.Pool(create=lambda: couchdb.Server(options.COUCHDB_URI), max_size=15)

    print 'create db'
    with server_pool.item() as server:
        db = common.get_db(server, 'app2')

    for i in range(10):
        eventlet.spawn_n(worker, i)
    worker(0)
