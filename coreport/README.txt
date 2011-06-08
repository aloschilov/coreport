OVERVIEW
This directory contains some simple applications to port to OS X
and/or Windows. They were written and tested on Linux.

The three applications are app1.py, app2.py and app3.py. All three are
Python apps that create a CouchDB database, and then continually add
documents to the database and randomly delete documents. They do not
have any UI and simply write some output to stdout. To ensure that
they are running correctly you can use CouchDB's web interface by
going to http://localhost:5990/_utils/ (where localhost:5990 is the
address of your CouchDB instance) in a browse and looking in the
databases "app1", "app2", and "app3". When you refresh the page with
the appropriate app running, you should see the IDs of the documents
change as documents are created and destroyed.

These apps aren't useful on their own, but the dependencies of these
apps are also used by CORE, so porting and packaging these apps is a
useful exercise.


Files in this directory:

app1.py: Creates and deletes documents in a CouchDB database
   (http://couchdb.apache.org/). I have used CouchDB 1.0.1. Before you
   run this ensure CouchDB is running and that the string
   options.COUCHDB_URI points to your CouchDB instance. This also
   requires the python bindings for CouchDB available here
   (http://pypi.python.org/pypi/CouchDB). The latest version is 0.8,
   but I used version 0.6 when developing app1.py.

app2.py: In addition to requring CouchDB and its python bindings, this
   app also uses eventlet (http://eventlet.net), which is a python
   library for green threads. In this app multiple green threads are
   creating and deleting the docs from the database.

app3.py: Like app1.py and app2.py, this app depends on CouchDB. It
   also uses eventlet like app2.py. It adds ZeroMQ
   (http://www.zeromq.org/), a socket library, to send messages
   between different green threads in the app. ZeroMQ is a C library
   and the app also needs ZeroMQ's python bindings
   (https://github.com/zeromq/pyzmq). I used version 2.0.10 of ZeroMQ
   when developing this app. 

common.py: Some common functions shared by all of the apps.

options.py: Some configuration constants.


GOALS 
   We want to port the existing CORE software to Windows and Mac
   OSX. There are many obstacles to doing this. One big problem is
   properly packaging all of the dependencies into a single
   installer. As a first step to porting CORE, we want to package some
   simple applications that use some of the same dependencies as CORE.

TASK
   Package each of the apps, app1.py, app2.py and app3.py, as a
   separate application for Windows or Mac OSX. Start with app1.py,
   because it has the fewest dependencies. Each app should be a single
   installer file that includes all of the app's dependencies. 

   Once installed, the user should be able to start the app from
   either the Start Menu in Windows or OSX's dock or
   equivalent. Starting the app should also start the CouchDB
   instance. Closing the app should stop the CouchDB instance. The
   user should not be aware that the app consists of multiple
   processes. In these simple apps there are at least two processes:
   the python app itself and the CouchDB process. The full CORE
   software has many more processes, so it is important for the ports
   to manage multiple processes and hide the complexity from the user.

   The final product of this task should not just be the final
   installer file. The most important results are information about
   how to build the installer, what problems were encountered during
   the port, and how the problems were solved. We are espcially
   interested in learning the best way to package the dependencies
   Python, CouchDB, Eventlet, and ZeroMQ.
