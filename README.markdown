PatrickEPG
==========

A Ruby on Rails application for displaying EPG guide data, usually obtained through Schedules Direct, and providing recording instructions to PatrickPVR.

Note: the script to pull data in from Schedules Direct is not currently included - once permission to distribute it has been obtained from Schedules Direct it will be included here.

Notes
-----

1. You'll need a database for the guide data. Configure that in epg/config/database.yml
2. If you'll be using it with the PVR and want to work on the API for the Encoder queue you'll also need a database for a tvrage cache. This could probably be the same database, but a connection is configured seperately in epg/app/controllers/encoder_controller.rb for it (you'll need to point PatrickPVR-Encoder at the same database). You'll also need to update the paths in that file as well.
3. The app has no authentication at this stage. Keep that in mind if it is internet accessible (especially what that can mean with regards to compliance with the Schedules Direct subscriber agreement)
4. While this is very rough around the edges I have been using it, and the PVR/Encoder tools since April this year, and within the current limitations it works quite well.

Requirements
------------

Tested only on Mac OS X 10.5 and later (currently on 10.6), using the passenger/mod_rails apache module. 

Database code all assumes PostgreSQL, tested against 8.3. Likely to work with other versions, only moderately likely to work with other database engines.

Licence
-------

Copyright (c) 2009 Patrick Quinn-Graham

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Acknowledgements
----------------

TBA