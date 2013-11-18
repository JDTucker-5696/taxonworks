# INIT tasks for RGeo, PostGIS, shape files (GADM and TDWG)

namespace :tw do
  namespace :init do

    desc 'Generate PostgreSQL/PostGIS records for shapefiles.'
    task :build_geographic_areas => :environment do

      place    = ENV['place']
      # build csv file list from 'place'

      # GenTable: set to true to generate the GeographicAreaType table here
      GenTable = true
      # DoShape: set to true to include the reading og the shapes into the GeographicItem table;
      #          Otherwise, only the CSV files are used to populate the GeographicArea table
      DoShape  = false
      # BaseDir: where to find the tables to be used
      BaseDir  = '../shapes/'

      if place.nil?
        base_dir = BaseDir
      else
        base_dir = place
      end

      if GenTable
        build_gat_table
        # since we are going to have to skip XXX_adm0, we need to build a master records for North America,
        # the USA by hand
        mr = GeographicArea.new(name:                 'United States',
                                country_id:           240,
                                parent_id:            0,
                                geographic_area_type: GeographicAreaType.where(name: 'Country')[0])
        mr.save
        if DoShape
          Dir.glob(base_dir + '**/*.shp').each { |filename|
            read_shape(filename)
          }
        else
          Dir.glob(base_dir + '**/*.csv').each { |filename|
            read_csv(filename)
          }
        end
      end
    end
  end
end

def read_shape(filename)

  RGeo::Shapefile::Reader.open(filename) { |file|

    count = file.num_records
    ess   = (count == 1) ? '' : 's'
    puts "#{filename} contains #{count} item#{ess}."

    record    = GeographicArea.new
    area_type = GeographicAreaType.new

    file.each { |item|
      case filename
        when /0/
          record    = GeorgaphicArea.new(parent_id:  0,
                                         name:       item[:NAME_ENGLISH],
                                         country_id: item[:PID])
          area_type = GeographicAreaType.where(name: 'Country')[0]
          if area_type.nil?
            at = GeographicAreaType.new(name: 'Country')
            at.save
            area_type = at
          end
        when /1/
          record    = GeographicArea.new(parent_id:  item[:ID_0],
                                         name:       item[:NAME_1],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0])
          area_type = GeographicAreaType.where(name: item[:TYPE_1])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_1])
            at.save
            area_type = at
          end
        when /2/
          record    = GeographicArea.new(parent_id:  item[:ID_1],
                                         name:       item[:NAME_2],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0],
                                         county_id:  item[:ID_2])
          area_type = GeographicAreaType.where(name: item[:TYPE_2])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_2])
            at.save
            area_type = at
          end
        else

      end
      record.geographic_area_type          = area_type[0]
      record.geographic_item               = GeographicItem.new
      record.geographic_item.multi_polygon = item.geometry
      record.save

      case filename
        when /0/
          # when country, find parent continent
          # parent_record = GeographicArea.where({parent_id: 0, country_id: 0})[0]
          parent_record =  GeographicArea.new(name: 'North America',
                                              geographic_area_type: GeographicAreaType.where(name: 'Continent')[0])
        when /1/
          # when state, find parent country
          parent_record = GeographicArea.where({state_id: nil, country_id: record.country_id})[0]
        when /2/
          # when county, find parent state
          parent_record = GeographicArea.where({state_id: record.parent_id})[0]
        else

      end
      count = record.geographic_item.multi_polygon.num_geometries
      ess   = (count == 1) ? '' : 's'
      puts "#{'% 5d' % (item.index + 1)}:  #{record.geographic_area_type.name} of #{record.name} in the #{parent_record.geographic_area_type.name} of #{parent_record.name} => #{count} polygon#{ess}."
    }
  } if !(filename =~ /[0]/)

end

def read_csv(file)

  # data = CSV.open(file)

  data = CSV.read(file, options = {headers: true})

  record    = GeographicArea.new
  area_type = GeographicAreaType.new
  data.each { |row|

    puts row

    case file
      when /0/
        record    = GeographicArea.new(parent_id:  0,
                                       name:       row.field('NAME_ENGLISH'),
                                       country_id: row.field('PID'))
        area_type = GeographicAreaType.where(name: 'Country')[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: 'Country')
          at.save
          area_type = at
        end
      when /1/
        record    = GeographicArea.new(parent_id:  row.field('ID_0'),
                                       name:       row.field('NAME_1'),
                                       state_id:   row.field('ID_1'),
                                       country_id: row.field('ID_0'))
        area_type = GeographicAreaType.where(name: row.field('TYPE_1'))[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: row.field('TYPE_1'))
          at.save
          area_type = at
        end
      when /2/
        record    = GeographicArea.new(parent_id:  row.field('ID_1'),
                                       name:       row.field('NAME_2'),
                                       state_id:   row.field('ID_1'),
                                       country_id: row.field('ID_0'),
                                       county_id:  row.field('ID_2'))
        area_type = GeographicAreaType.where(name: row.field('TYPE_2'))[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: row.field('TYPE_2'))
          at.save
          area_type = at
        end
      else

    end
    record.geographic_area_type = area_type
    record.save
  }
end

def build_gat_table
  ['Continent',
   'Country',
   'State',
   'Federal District',
   'County',
   'Borough',
   'Census Area',
   'Municipality',
   'City And Borough',
   'City And County',
   'District',
   'Water body',
   'Parish',
   'Independent City',
   'Province',
   'Ward',
   'Prefecture'].each { |item|

    area_type = GeographicAreaType.where(name: item)[0]
    if area_type.nil?
      at = GeographicAreaType.new(name: item)
      at.save
    end
  }
end
