""" Continually creates and deletes documents in a CouchDB
database. Uses multiple eventlet greenthreads, and also multiple
native threads. Communicates between the native threads using ZeroMQ
inprocess sockets.

This depends on having a running CouchDB. The options module contains
the string COUCHDB_URI which defines the host and port that CouchDB is
running on.

This also uses the eventlet library.

Also this uses ZeroMQ.

"""

import threading
import time
import random
import json

import couchdb

import options
import common

import eventlet
from eventlet import pools
from eventlet.green import zmq
couchdb = eventlet.import_patched('couchdb')



def worker(ctx, i):
    print 'worker', i

    skt = ctx.socket(zmq.XREQ)
    skt.connect("inproc://#1")

    server_pool = pools.Pool(create=lambda: couchdb.Server(options.COUCHDB_URI), max_size=15)


    with server_pool.item() as server:
        while True:
            db = common.get_db(server, 'app3')
            uuids = common.UUIDsIterator(server)

            print 'worker', i, 'create'
            common.create_docs(db, options.NUM_DOCS, uuids)
            eventlet.sleep(random.uniform(0.1, 3))

            # Delete some random docs
            rows = common.random_rows(db, 10)
            for row in rows:
                skt.send_multipart(['', json.dumps(row)])

            eventlet.sleep(random.uniform(0.1, 3))

def split_multipart(parts):
    index = next((i for i in xrange(len(parts)) if (parts[i] == '')), None)
    if index is None:
        return [[], parts]
    else:
        return [parts[0:index], parts[index+1:]]


def main():
    # wait for couchdb to start
    time.sleep(2)

    server_pool = pools.Pool(create=lambda: couchdb.Server(options.COUCHDB_URI), max_size=15)

    print 'create db'
    with server_pool.item() as server:
        db = common.get_db(server, 'app3')

        ctx = zmq.Context()

        skt = ctx.socket(zmq.XREP)
        skt.bind("inproc://#1")

        for i in range(10):
            eventlet.spawn_n(worker, ctx, i)

        while True:
            msg = skt.recv_multipart()
            addrs, bodies = split_multipart(msg)
            rows = map(json.loads, bodies)
            common.delete_random(db, rows, 0)
