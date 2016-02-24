# General purpose Geo related methods
# rubocop:disable Style/AsciiComments
module Utilities::Geo
=begin
To add a new (discovered) symbol:
  1) To find the Unicode string for any character, use Utilities::Geo.uni_string('c') (remove the first '\').
  2) Add the Unicode string (i.e, "\uNNNN") to SPECIAL_LATLONG_SYMBOLS (below), selecting either degrees
      (starting with 'do*'), or tickmarks (starting at "'").
  3) Add the Unicode to the proper section in the regexp in the corresponding section (degrees, minutes, or seconds).
      NB: all the minutes symbols are duplicated in the seconds section because sometimes two successive tickmarks
          (for minutes) are used for seconds.
=end
  # degree symbols, in addition to 'd', 'o', and '*'
  # \u00b0  "°"  \u00ba  "º"  \u02da  "˚"  \u030a  "?"  \u221e "∞"  \u222b "∫"
  #
  # tick symbols, in addition to "'" ("\u0027""), and '"' ("\u0022")
  # \u00a5  "¥"  \u00b4  "´"
  # \u02B9  "ʹ"  \u02BA  "ʺ"  \u02BB  "ʻ"  \u02BC  "ʼ"  \u02CA "ˊ"
  # \u02EE  "ˮ"  \u2032  "′"  \u2033  "″"
  #

  SPECIAL_LATLONG_SYMBOLS = "do*\u00b0\u00ba\u02DA\u030a\u221e\u222b\u0027\u00b4\u02B9\u02BA\u02BB\u02BC\u02CA\u02EE\u2032\u2033\u0022".freeze

  LAT_LON_REGEXP = Regexp.new(/(?<lon>-?\d+\.?\d*),?\s*(?<lat>-?\d+\.?\d*)/)

  # DMS_REGEX = "(?<degrees>-*\d+)[do*\u00b0\u00ba\u02DA\u030a\u221e\u222b]\s*(?<minutes>\d+\.*\d*)
  # [\u0027\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032]*\s*((?<seconds>\d+\.*\d*)
  # [\u0027\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\u0022]+)*"

  # http://en.wikiversity.org/wiki/Geographic_coordinate_conversion
  # http://stackoverflow.com/questions/1774985/converting-degree-minutes-seconds-to-decimal-degrees
  # http://stackoverflow.com/questions/1774781/how-do-i-convert-coordinates-to-google-friendly-coordinates

  # POINT_ONE_DIAGONAL = 15690.343288662 # 15690.343288662  # Not used?
  # TEN_WEST           = 1113194.90779206  # Not used?
  # TEN_NORTH          = 1105854.83323573  # Not used?

  # EARTH_RADIUS       = 6371000 # km, 3959 miles (mean Earth radius) # Not used?
  # RADIANS_PER_DEGREE = ::Math::PI/180.0
  # DEGREES_PER_RADIAN = 180.0/::Math::PI

  ONE_WEST       = 111_319.490779206 # meters/degree
  # ONE_WEST  = 111_319.444444444 # meters/degree (calculated mean)
  ONE_NORTH      = 110_574.38855796 # meters/degree

  #
  class ConvertToDecimalDegrees
    attr_reader(:dd, :dms)

    def initialize(coordinate)
      @dms = coordinate
      @dd  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(coordinate)
    end
  end

  # 12345       (presume meters)
  # 123.45
  # 123 ft > 123 ft. > 123 feet > 1 foot > 123 f > 123 f.
  # 123 m > 123 meters > 123 m.
  # 123 km > 123 km. > 123 kilometers
  #
  def self.elevation_in_meters(elev_in)
    elev_in = '0.0 meters' if elev_in.blank?
    elev_in.strip.downcase!
    pieces = elev_in.split(' ')

    /(?<ft>f[oe]*[t]*\.*)|(?<m>[^k]m(eters)*[\.]*)|(?<km>kilometer(s)*|k[m]*[\.]*)/ =~ pieces[1]
    # scale = $&

    scale = 1.0
    scale = 0.3048 unless ft.blank?
    scale = 1000.0 unless km.blank?

    elev = pieces[0].to_f * scale

    elev
  end

  # 42∞5'18.1"S88∞11'43.3"W
  # S42∞5'18.1"W88∞11'43.3"
  # S42∞5.18'W88∞11.43'
  # 42∞5.18'S88∞11.43'W
  # S42.18∞W88.34∞
  # 42.18∞S88.43∞W
  # -12.263, 49.398
  #
  # 42:5:18.1N
  # 88:11:43.3W
  #
  # no limit test, unless there is a letter included
  def self.degrees_minutes_seconds_to_decimal_degrees(dms_in)
    match_string = nil
    # no_point     = false
    degrees      = 0.0
    minutes      = 0.0
    seconds      = 0.0

    # make SURE it is a string! Watch out for dms_in == -10
    dms_in       = dms_in.to_s
    dms          = dms_in.dup.upcase
    dms =~ /[NSEW]/i
    cardinal = $LAST_MATCH_INFO.to_s
    # return "#{dms}: Too many letters (#{cardinal})" if cardinal.length > 1
    # return nil if cardinal.length > 1
    dms      = dms.gsub!(cardinal, '').strip.downcase

    if dms.include? '.'
      no_point = false
      if dms.include? ':' # might be '42:5.1'
        /(?<degrees>-*\d+):(?<minutes>\d+\.*\d*)(:(?<seconds>\d+\.*\d*))*/ =~ dms
        match_string = $&
      else
        # this will get over-ridden if the next regex matches
        /(?<degrees>-*\d+\.\d+)/ =~ dms
        match_string = $&
      end
    else
      no_point = true
    end

    # >40°26′46″< >40°26′46″<
    dms.each_char { |c|
      if SPECIAL_LATLONG_SYMBOLS.include?(c)
        /^(?<degrees>-*\d{0,3}(\.\d+)*) # + or - three-digit number with optional '.' and additional decimal digits
            [do*\u00b0\u00ba\u02DA\u030a\u221e\u222b\uc2ba]*\s* # optional special degrees symbol, optional space
          (?<minutes>\d+\.*\d*)* # optional number, integer or floating-point
            ['\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032\uc2ba]*\s* # optional special minutes symbol, optional space
          ((?<seconds>\d+\.*\d*) # optional number, integer or floating-point
            ['\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\uc2ba"]+)* # optional special seconds symbol, optional space
        /x =~ dms # 'x' modifier permits inline comments for regexp
        match_string = $&
        break # bail on the first character match
      end
    }
    degrees = dms.to_f if match_string.nil? && no_point

    # @match_string = $&
    degrees = degrees.to_f
    case cardinal
      when 'W', 'S'
        sign = -1.0
      else
        sign = 1.0
    end
    if degrees < 0
      sign    *= -1
      degrees *= -1.0
    end
    frac = ((minutes.to_f * 60.0) + seconds.to_f) / 3600.0
    dd   = (degrees + frac) * sign
    case cardinal
      when 'N', 'S'
        limit = 90.0
      else
        limit = 180.0
    end
    # return "#{dms}: Out of range (#{dd})" if dd.abs > limit
    return nil if dd.abs > limit || dd == 0.0
    dd.round(6).to_s
  end

  def uni_string(char)
    format('\\u%04X', char.ord)
    # "\\#{sprintf('u%04X', char.ord)}"
    # '\\u%04X' % [char.ord]
  end

  def self.nearby_from_params(params)
    nearby_distance = params['nearby_distance'].to_i
    nearby_distance = CollectingEvent::NEARBY_DISTANCE if nearby_distance == 0

    decade = case nearby_distance.to_s.length
               when 1..2
                 10
               when 3
                 100
               when 4
                 1_000
               when 5
                 10_000
               when 6
                 100_000
               when 7
                 1_000_000
               when 8
                 10_000_000
               else
                 10
             end
    digit  = (nearby_distance.to_f / decade.to_f).round

    case digit
      when 0..1
        digit = 1
      when 2
        digit = 2
      when 3..5
        digit = 5
      when 6..10
        decade *= 10
        digit  = 1
    end

    params['digit1'] = digit.to_s
    params['digit2'] = decade.to_s
    digit * decade
  end

  # confirm that this says that the error radius is one degree or smaller
  def self.point_keystone_error_box(geo_object, error_radius)
    p0      = geo_object
    delta_x = (error_radius / ONE_WEST) / ::Math.cos(p0.y)
    delta_y = error_radius / ONE_NORTH

    Gis::FACTORY.polygon(
      Gis::FACTORY.line_string(
        [
          Gis::FACTORY.point(p0.x - delta_x, p0.y + delta_y), # northwest
          Gis::FACTORY.point(p0.x + delta_x, p0.y + delta_y), # northeast
          Gis::FACTORY.point(p0.x + delta_x, p0.y - delta_y), # southeast
          Gis::FACTORY.point(p0.x - delta_x, p0.y - delta_y) # southwest
        ]
      )
    )
  end

  # make a diamond 2 * radius tall and 2 * radius wide, with the reference point as center
  # NOT TESTED/USED
  def diamond_error_box
    p0      = geo_object
    delta_x = (error_radius / ONE_WEST) / ::Math.cos(p0.y)
    delta_y = error_radius / ONE_NORTH

    retval = Gis::FACTORY.polygon(Gis::FACTORY.line_string(
      [Gis::FACTORY.point(p0.x, p0.y + delta_y), # north
       Gis::FACTORY.point(p0.x + delta_x, p0.y), # east
       Gis::FACTORY.point(p0.x, p0.y - delta_y), # south
       Gis::FACTORY.point(p0.x - delta_x, p0.y) # west
      ]))
    box    = RGeo::Cartesian::BoundingBox.new(Gis::FACTORY)
    box.add(retval)
    box.to_geometry
  end
end
