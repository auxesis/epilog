WARNING
=======

THIS IS OLD WEIRD ABANDONED CODE THAT HARMS PUPPIES - FUN TO HAVE A GANDER
AT BUT OH MY GOD DON'T THINK OF USING THIS IN PRODUCTION.

Epilog
======

Epilog is a simple log viewing application written in Ruby on Rails,
and a log aggregator written in Ruby. It uses Ferret, a Ruby port of
the Apache Lucene indexer and search engine, and the acts_as_ferret
Rails plugin to provide fast searching  of rfc3164 formatted log files.

Simply put, Epilog makes viewing near real time logs through a web
interface quick and easy.

Where stuff is
--------------

The rails viewing bits exist under rails/
The aggregator code exists under aggregator/

A symlink of the rails databases.yml is made to the aggregator
directory so database settings are shared.

Requirements
------------

We use a whole bunch of libraries. It's probably a good idea
to have rubygems installed. Gems (probably) required are:

 - ferret (should be frozen in Epilog's rails app)
 - acts_as_ferret (should be frozen in Epilog's rails app)
 - active_record (frozen in Epilog's rails, but required by the aggregator)
 - term/ansicolor
 - fileutils

Usage
-----

For testing and development:

To aggregate and index data locally:
 - make sure aggregator/database.yml is pointing to a usable database
   $ $editor aggregator/database.yml
 - for production usage, set RAILS_ENV to "production"
   $ export RAILS_ENV="production"
 - start the aggregator
   $ ruby aggregator/aggregator-local.rb <logfile>

To start the rails app:
 - start webrick/lighttpd, by running
   $ rails/script/server

To start up the log writing simulator:
 - the logfeeder reads data from an existing logfile, and outputs
   lines to stdout at random intervals. this roughly simulates real
   mailserver logging behaviour.
 - make sure you have some test data to play with (testdata.log for example)
   $ ruby aggregator/tests/scripts/logfeeder.rb testdata.log > <logfile>
   then point the aggregator at the <logfile>

