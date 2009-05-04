#======================================================#
#
#                          ImportGtfsController
#
# Date:         1st May 2009 
# Author:      matteo.lacognata@gmail.com
# Comments: Adapted from Graphserver's Ruby scripts.
#                   http://www.graphserver.org
#======================================================#
class ImportGtfsController < ApplicationController

  # GET /import_gtfs
  # GET /import_gtfs.xml
  def index
    
    @gtfs_folder = "db/GTFS"
    @progress = ""
    
    @gtfs = ImportGtfsHelper::GoogleTransitFeed.new( @gtfs_folder, :verbose ) 
    
    ImportGtfsHelper::TABLE_NAMES_TO_FILES.each do |table, file|
        @progress << @gtfs.import_file( @gtfs[file.to_s], table.to_s )
        #render :text => @gtfs.import_file( @gtfs[file.to_s], table.to_s )
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @import_gtfs }
    end
  end
  
end


