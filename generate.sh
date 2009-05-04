#!/bin/bash
roropt=
mongrelport=4004
dbtype="SQLite3"
WDIR=$(pwd)
while getopts 'm','h','p:' OPTION
do
  case $OPTION in
  p)  mongrelport=$OPTARG
        ;;
  m)  roropt="-d mysql"
        dbtype="MySQL"
        ;;
  h | ?)   printf "Usage: %s [-m] [-p mongrel_port] install_path\n" $(basename $0) 
        echo "-m  : Use MySQL (default is SQLite)."
        echo "-p   : Port used by Mongrel Web Server (default is 4004)."
        echo "Use install_path to specify an install path (default is ../gtfs-ror-helper_app)."
        exit 2
        ;;
  esac
done
shift $(($OPTIND - 1))
RORDIR=${1:-"../gtfs-ror-helper_app"}
printf "Creating %s application structure in %s.\n" $dbtype $RORDIR
rails $RORDIR $roropt
cd $RORDIR
echo "Creating a home index controller."
script/generate controller home index
rm public/index.html
echo "Creating GTFS models."
script/generate model Agency agency_id:string agency_name:string agency_url:string agency_timezone:string agency_lang:string agency_phone:string
script/generate model Stop stop_id:string stop_code:string stop_name:string stop_desc:string stop_lat:float stop_lon:float zone_id:string stop_url:string location_type:integer parent_station:integer route_id:string
script/generate model Route route_id:string agency_id:string route_short_name:string route_long_name:string route_desc:string route_type:integer route_url:string route_color:string route_text_color:string
script/generate model Trip route_id:string service_id:string trip_id:string trip_headsign:string trip_short_name:string direction_id:integer block_id:string shape_id:string
script/generate model Stop_Time trip_id:string arrival_time:string departure_time:string stop_id:string stop_sequence:integer stop_headsign:integer pickup_type:integer drop_off_type:integer shape_dist_traveled:float
script/generate model Calendar service_id:string monday:integer tuesday:integer wednesday:integer thursday:integer friday:integer saturday:integer sunday:integer start_date:string end_date:string
script/generate model Calendar_Date service_id:string date:string exception_type:integer
script/generate model Fare_Attribute fare_id:string price:float currency_type:string payment_method:integer transfers:integer transfer_duration:integer
script/generate model Fare_Rule fare_id:string route_id:string origin_id:string destination_id:string contains_id:string
script/generate model Shape shape_id:string shape_pt_lat:float shape_pt_lon:float shape_pt_sequence:integer shape_dist_traveled:float
script/generate model Frequency trip_id:string start_time:string end_time:string headway_secs:integer
script/generate model Transfer from_stop_id:string to_stop_id:string transfer_type:integer min_transfer_time:integer
echo "Creating GTFS Ruby wrappers."
script/generate controller Import_Gtfs
script/generate controller Patch_Gtfs
echo "Importing GTFS Ruby wrappers."
echo "Controllers."
cp $WDIR/app/controllers/* app/controllers/
echo "Helpers."
cp $WDIR/app/helpers/* app/helpers/
echo "Views."
cp -R $WDIR/app/views/ app/views/
echo "Config."
cp $WDIR/config/routes.rb config/routes.rb
cp $WDIR/config/database.yml config/database.yml
echo "Extracting GTFS feed files in db/GTFS."
mkdir db/GTFS
cp $WDIR/db/GTFS/* db/GTFS/
cd db/GTFS/
for feed in $(ls); do
   printf "Extracting %s\n" $feed
   tar -xvf $feed   
   folder=${feed%.*}
   cp $folder/* ../GTFS/
   rm -R $folder
done
cd ../..
echo "Creating empty database."
rake db:create
echo "Creating database schema from models."
rake db:migrate
echo "Starting application."
script/server -p $mongrelport