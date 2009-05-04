GTFS-ROR-HELPER
Google Transit Feed Specification - Ruby On Rails
Author: Matteo La Cognata (matteo.lacognata@gmail.com)

GTFS-ROR-HELPER provides with a Bash script (generate.sh) & a Ruby on Rails Module (app/helpers/import_gtfs_helper.rb) + Controller (app/controllers/import_gtfs_controller.rb) which can be used to import a Google Transit Feed into a MySQL/SQLite database.
The database connection details are specified as in any ROR application via config/database.yml. 
GTFS-ROR-HELPER leverages the Model & Active Record approach of Ruby on Rails and no SQL is used in the Ruby script. 
Models of the GTFS are created according to the GTFS specification Rev. March 30, 2009.
Once installed, browse to http://localhost:4004 to initiate the GTFS import.
When the import is finished a basic report is displayed showing the number or records inserted & the time required for the insert, for each table.
To see live progress of the import operation, type in the console at the root application: $ tail -f log/development.log

To install:

1) Copy your zipped (*.tgz) GTFS feed in db/GTFS. 
    Note: GTFS-ROR-HELPER is designed to work with 1 single feed, e.g. a feed from a single agency as there is no namespace support.
    
2) Edit the config/database.yml file to suit. You only need to edit this if you plan on using MySQL.

3) Run ./generate.sh. Run the command with -h option to see usage.


Future extensions:

a) Graphserver support:
    1) Patch the Models for use with Graphserver.
    2) Code the Patch Controller/Module. 