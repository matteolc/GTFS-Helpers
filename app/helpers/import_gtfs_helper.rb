module ImportGtfsHelper
#======================================================#
# Hashes 
#======================================================#
# GoogleTransitFeed required files
FEED_FILES = [["agency",["agency_id","agency_name","agency_url","agency_timezone","agency_lang","agency_phone"]],
                ["stops", ["stop_id","stop_code","stop_name","stop_desc","stop_lat","stop_lon","zone_id","stop_url","location_type","parent_station"]],
                ["routes",["route_id","agency_id","route_short_name","route_long_name","route_desc","route_type","route_url","route_color","route_text_color"]],
                ["trips", ["route_id","service_id","trip_id","trip_headsign","trip_short_name","direction_id","block_id","shape_id"]],
                ["stop_times",["trip_id","arrival_time","departure_time","stop_id","stop_sequence","stop_headsign","pickup_type","drop_off_type","shape_dist_traveled"]],
                ["calendar",["service_id","monday","tuesday","wednesday","thursday","friday","saturday","sunday","start_date","end_date"]]]

# GoogleTransitFeed optional files
OPTIONAL_FEED_FILES = [["frequencies",["trip_id","start_time","end_time","headway_secs"]],
                ["calendar_dates",["service_id","date","exception_type"]],
                ["fare_attributes",["fare_id","price","currency_type","payment_method","transfers","transfer_duration"]],
                ["fare_rules",["fare_id","route_id","origin_id","destination_id","contains_id"]],
                ["shapes",["shape_id","shape_pt_lat","shape_pt_lon","shape_pt_sequence","shape_dist_traveled"]],
                ["transfers",["from_stop_id","to_stop_id","transfer_type","min_transfer_time"]]] 

TABLE_NAMES_TO_FILES = [["agencies",["agency"]],
				["stops",["stops"]],
				["routes",["routes"]],
				["trips",["trips"]],
				["stop_times",["stop_times"]],
				["frequencies",["frequencies"]],
				["calendar_dates",["calendar_dates"]],
				["fare_attributes",["fare_attributes"]],
				["fare_rules",["fare_rules"]],
				["shapes",["shapes"]],
				["transfers",["transfers"]]]

#======================================================#
# Class GoogleTransitFeed 
#======================================================# 
class GoogleTransitFeed
   
    def initialize directory, verbose=false

      @files = {}         
      FEED_FILES.each do |file, fields|
        @files[file] = GoogleTransitFeedFile.new "#{directory}/#{file}.txt", fields
      end

      OPTIONAL_FEED_FILES.each do |file, fields|
        begin
          @files[file] = GoogleTransitFeedFile.new "#{directory}/#{file}.txt", fields
        rescue
        end
      end
    
    end
 
    def [] file
      @files[file]
    end

  def import_file( gtf_file, table_name )
  
    return nil if not gtf_file or gtf_file.header.empty?
    begin  
    
       start_time = Time.now
       progress = "Import of #{table_name}.txt file started: " + start_time.strftime('%D %T') + '<br>'
       # records counter for reporting purposes
       records=0   
       # process each line of the file
       gtf_file.each_line do |row|  
          # create a new instance of the model
          model = (eval ActiveSupport::Inflector.classify("#{table_name}")).new
          # populate the model with column values 
          gtf_file.format.each do |column|      
             begin
               # update column value
               model.update_attributes(column.to_sym => "\"" + row[gtf_file.header.index(column)] + "\"")
             rescue
               # print "#{column} missing from #{table_name}.txt file\n"
             end
          end      
          # save the model to persistent storage   
          model.save
          
          # give some kind of progress indication
          if (records%1000)==0 and (records>0) then
             progress << "\r#{records} records processed<br>"
          end
          # update record count
          records += 1
       
       end
       # do some reporting
       time_elapsed = (Time.now - start_time).to_i.to_s
       progress << "#{records} record(s) processed for table #{table_name} in " + time_elapsed + " seconds <br>"
    rescue
       progress << "#{table_name} missing from schema.<br>"
    end
    return progress
    
  end

end

#======================================================#
# Class GoogleTransitFeedFile 
#======================================================# 
class GoogleTransitFeedFile
    
	attr_reader :format, :header

    def initialize filename, format
      #Read header and leave file open
      @format = format
      @fp = File.new( filename )
      @header = split_csv_with_quotes( @fp.readline )
      
      #create a map whereby each heading of the @format is mapped to its index in @header, or nil
      @formatmap = []
      @format.each_with_index do |field, i|
        @formatmap << @header.index(field)
      end

    end

    def each_line
      @fp.each_line do |line|
        splitline = split_csv_with_quotes( line )
        reformed = []
        @formatmap.each do |pt|
          if pt.nil? then
            reformed << ""
          else
            reformed << splitline[pt]
          end
        end

        yield reformed
      end
    end

    #Reads a line from file and converts to fields
    def get_row
      line = @f.gets
      #if eof return nil
      if line == nil then return nil end
      #if line has quotes
      if line.match(/&quote/) then
        splitline = split_csv_with_quotes( line )
      else
        splitline = line.split(",").collect do |element| element.strip end
      end

      # Reorder columns according to the formatmap
      reformed = []
      @formatmap.each do |pt|
        if pt.nil? then
          reformed << ""
        else
          reformed << splitline[pt]
        end
      end
      return reformed
    end

    def split_csv_with_quotes string
      quote = Regexp.compile( /&quote/ )
      fields = string.split( "," )

      i = 0
      n = fields.size

      while i < n do
        # if a field has an uneven number of quotes
        # merge it with the next field
        if fields[i].scan( quote ).size%2 != 0 then
          fields[i..i+1] = fields[i] + (fields[i+1] or "")
          n -= 1
        end
        fields[i].strip!
        i += 1
      end

      return fields
      end
    end


  
end	

