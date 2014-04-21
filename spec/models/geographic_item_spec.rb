require 'spec_helper'
require_relative '../support/geo'

describe GeographicItem do
  before(:all) {
    generate_test_objects
    # TODO: Remove this line, it's not needed, right?:  gen_wkt_files (code is now in support/geo
  }

  after(:all) {
    GeographicItem.destroy_all
  }

  #let(:FFI_FACTORY) { ::RGeo::Geographic.FFI_FACTORY(:srid => 4326)}
  #let(:FFI_FACTORY) { ::RGeo::Geos.factory(:srid             => 4326,
  #                                        :has_z_coordinate => true,
  #                                        :has_m_coordinate => false) }
  let(:geographic_item) { FactoryGirl.build(:geographic_item) }
  let(:geographic_item_with_point_a) { FactoryGirl.build(:geographic_item_with_point_a) }
  let(:geographic_item_with_point_b) { FactoryGirl.build(:geographic_item_with_point_b) }
  let(:geographic_item_with_point_c) { FactoryGirl.build(:geographic_item_with_point_c) }
  let(:geographic_item_with_line_string) { FactoryGirl.build(:geographic_item_with_line_string) }
  let(:geographic_item_with_polygon) { FactoryGirl.build(:geographic_item_with_polygon) }

=begin
  context 'database functions' do

    specify 'ST_Geometry_Same' do
      pending
      #expect(GeographicItem.same(geographic_item_with_line_string.geo_object,
      #                           geographic_item_with_line_string.geo_object)).to be_true
      #expect(GeographicItem.same(geographic_item_with_line_string.geo_object,
      #                           geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Area' do
      pending
      #expect(GeographicItem.area(geographic_item_with_polygon.geo_object)).to eq 0.123
    end

    specify 'ST_Azimuth' do
      pending
      #expect(GeographicItem.azimuth(geographic_item_with_point_a.geo_object,
      #                              geographic_item_with_point_b.geo_object)).to eq 44.5
      #expect(GeographicItem.azimuth(geographic_item_with_point_b.geo_object,
      #                              geographic_item_with_point_a.geo_object)).to eq 44.5
      #expect(GeographicItem.azimuth(geographic_item_with_point_a.geo_object,
      #                              geographic_item_with_point_a.geo_object)).to eq 44.5
    end

    specify 'ST_Centroid' do
      pending
      #expect(GeographicItem.centroid(geographic_item_with_polygon.polygon)).to eq geographic_item_with_point_c
    end

    specify 'ST_Contains' do
      pending
      #expect(GeographicItem.contains(geographic_item_with_polygon.geo_object,
      #                               geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.contains(geographic_item_with_point_c.geo_object,
      #                               geographic_item_with_polygon.geo_object)).to be_false
      #expect(GeographicItem.contains(geographic_item_with_polygon.geo_object,
      #                               geographic_item_with_polygon.geo_object)).to be_true
    end

    specify 'self.find_contains ' do
      pending 'building a City of Champaign shape, and a point inside it'
    end

    specify 'ST_ContainsProperly ' do
      pending
      #expect(GeographicItem.contains_properly(geographic_item_with_polygon.geo_object,
      #                                        geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.contains_properly(geographic_item_with_point_c.geo_object,
      #                                        geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Covers' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_CoveredBy' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Crosses' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_LineCrossingDirection' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Disjoint' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

    specify 'ST_Distance' do
      pending
      #expect(GeographicItem.covers(raphic_item_with_polygon.geo_object,
      #                             geographic_item_with_point_c.geo_object)).to be_true
      #expect(GeographicItem.covers(geographic_item_with_point_c.geo_object,
      #                             geographic_item_with_polygon.geo_object)).to be_false
    end

  end
=end

  context 'validation' do
    before(:each) {
      geographic_item.valid?
    }

    specify 'some data must be provided' do
      expect(geographic_item.errors.keys).to include(:point)
    end

    specify 'invalid data for point is invalid' do
      geographic_item.point = 'Some string'
      expect(geographic_item.valid?).to be_false
    end

    specify 'a valid point is valid' do
      expect(geographic_item_with_point_a.valid?).to be_true
    end

    specify 'A good point that didn\'t change.' do
      expect(geographic_item_with_point_a.point.x).to eq -88.241413
    end

    specify 'One and only one of point, line_string, etc. is set.' do
      geographic_item_with_point_a.polygon = geographic_item_with_point_a.point.buffer(10)
      expect(geographic_item_with_point_a.valid?).to be_false
    end
  end

  context 'geo_object interactions (Geographical attribute of GeographicItem)' do
    specify 'Certain line_string shapes cannot be polygons, others can.' do
      @k.reload # can't make a polygon out of a line_string which crosses itself
      @d.reload # can make a (closed) polygon out of a line_string which is either closed, or open

      expect(RSPEC_GEO_FACTORY.polygon(@k.geo_object)).to be_nil
      expect(RSPEC_GEO_FACTORY.polygon(@d.geo_object).to_s).not_to be_nil
    end

    specify 'That one object contains another, or not.' do
      expect(@k.contains?(@p1)).to be_true
      expect(@k.contains?(@p17)).to be_false

      expect(@p1.within?(@k)).to be_true
      expect(@p17.within?(@k)).to be_false
    end

    specify 'Two polygons may have various intersections.' do

      @e.reload
      e0      = @e.geo_object # a collection of polygons
      shapeE1 = e0.geometry_n(0)
      shapeE2 = e0.geometry_n(1)
      shapeE3 = e0.geometry_n(2)
      shapeE4 = e0.geometry_n(3)
      shapeE5 = e0.geometry_n(4)

      expect(shapeE1.intersects?(shapeE2)).to be_true
      expect(shapeE1.intersects?(shapeE3)).to be_false

      expect(shapeE1.overlaps?(shapeE2)).to be_true
      expect(shapeE1.overlaps?(shapeE3)).to be_false

      expect(shapeE1.intersection(shapeE2)).to eq(E1_AND_E2)
      expect(shapeE1.intersection(shapeE4)).to eq(E1_AND_E4)

      expect(shapeE1.union(shapeE2)).to eq(E1_OR_E2)
      expect(shapeE1.union(shapeE5)).to eq(E1_OR_E5)
    end

    specify 'Two polygons may have various adjacencies.' do
      e0      = @e.geo_object # a collection of polygons
      shapeE1 = e0.geometry_n(0)
      shapeE2 = e0.geometry_n(1)
      shapeE3 = e0.geometry_n(2)
      shapeE4 = e0.geometry_n(3)
      shapeE5 = e0.geometry_n(4)

      expect(shapeE1.touches?(shapeE5)).to be_false
      expect(shapeE2.touches?(shapeE3)).to be_true
      expect(shapeE2.touches?(shapeE5)).to be_false

      expect(shapeE1.disjoint?(shapeE5)).to be_true
      expect(shapeE2.disjoint?(shapeE5)).to be_true
      expect(shapeE2.disjoint?(shapeE4)).to be_false
    end

    specify 'Two different object types have various intersections.' do
      a   = @a.geo_object
      k   = @k.geo_object
      l   = @l.geo_object
      e   = @e.geo_object
      f   = @f.geo_object
      f1  = f.geometry_n(0)
      f2  = f.geometry_n(1)
      p16 = @p16.geo_object

      expect(a.intersection(p16)).to eq(P16_ON_A)

      # f1crosses2 = RSPEC_FACTORY.parse_wkt("POINT (-23.6 -4.0 0.0)")

      expect(l.intersects?(k)).to be_true
      expect(l.intersects?(e)).to be_false

      expect(f1.intersection(f2)).to be_true
    end

    specify 'Objects can be related by distance' do
      p1  = @p1.geo_object
      p10 = @p10.geo_object
      p17 = @p17.geo_object

      k = @k.geo_object

      expect(p17.distance(k)).to be < p10.distance(k)

      expect(@k.near(@p1, 0)).to be_true
      expect(@k.near(@p17, 2)).to be_true
      expect(@k.near(@p10, 5)).to be_false

      expect(@k.far(@p1, 0)).to be_false
      expect(@k.far(@p17, 1)).to be_true
      expect(@k.far(@p10, 5)).to be_true
    end

    specify 'Outer Limits' do
      everything = @all_items.geo_object
      expect(everything.convex_hull()).to eq(CONVEX_HULL)
    end
  end

  context 'That GeographicItems provide certain methods.' do
    specify 'self.geo_object returns stored data' do
      geographic_item.point = ROOM2024
      expect(geographic_item.save).to be_true
      # also 'respond_to'
      # after the save, the default factory type of geographic_item is
      # #<RGeo::Geographic::Factory> and the
      # factory for p1 is #<RGeo::Geos::ZMFactory>, so the two points do not match.
      # See the model for a method to change the default factory for a given
      # column (in our case, all).
      geo_id = geographic_item.id
      expect(geographic_item.geo_object).to eq ROOM2024
      geographic_item.reload
      expect(GeographicItem.find(geo_id).geo_object).to eq geographic_item.geo_object
    end
  end

  context 'instance methods' do
    specify '#geo_object' do
      expect(geographic_item).to respond_to(:geo_object)
    end

    specify '#contains? - to see if one object is contained by another.' do
      expect(geographic_item).to respond_to(:contains?)
    end

    specify '#within? -  to see if one object is within another.' do
      expect(geographic_item).to respond_to(:within?)
    end

    specify '#distance? - to see how far one object is from another.' do
      expect(geographic_item).to respond_to(:distance?)
    end

    specify '#near' do
      expect(geographic_item).to respond_to(:near)
    end
    specify '#far' do
      expect(geographic_item).to respond_to(:far)
    end

    specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
      expect(@k.contains?(@p1)).to be_true
      expect(@e1.contains?(@p10)).to be_false
    end


    context 'that each type of item knows how to emits its own array' do
      specify 'that represents a point' do
        expect(@r2024.to_a).to eq [-88.241413, 40.091655]
      end

      specify 'that represents a line_string' do
        expect(@a.to_a).to eq [[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]]
      end

      specify 'that represents a polygon' do
        expect(@k.to_a).to eq [[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0], [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]
      end

      specify 'that represents a multi_point' do
        expect(@rooms.to_a).to eq [[-88.241421, 40.091565], [-88.241417, 40.09161], [-88.241413, 40.091655]]
      end

      specify 'that represents a multi_line_string' do
        expect(@c.to_a).to eq [[[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]], [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]], [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]]]
      end

      specify 'that represents a multi_polygon' do
        expect(@g.to_a).to eq [[[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]]]
      end
    end

    context 'that each type of item knows how to emits its own hash' do
      specify 'for a point' do
        expect(@r2024.rendering_hash).to eq(points: [[-88.241413, 40.091655]])
      end

      specify 'for a line_string' do
        expect(@a.rendering_hash).to eq(lines: [[[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]]])
      end

      specify 'for a polygon' do
        expect(@k.rendering_hash).to eq(polygons: [[[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0], [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]])
      end

      specify 'for a multi_point' do
        expect(@rooms.rendering_hash).to eq(points: [[-88.241421, 40.091565], [-88.241417, 40.09161], [-88.241413, 40.091655]])
      end

      specify 'for a multi_line_string' do
        expect(@c.rendering_hash).to eq(lines: [[[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]], [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]], [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]]])
      end

      specify 'for a multi_polygon' do
        expect(@g.rendering_hash).to eq(polygons: [[[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]]])
      end

      specify 'for a geometry_collection' do
        expect(@all_items.rendering_hash[:points]).to eq [
                                                           [3.0, -14.0],
                                                           [6.0, -12.9],
                                                           [5.0, -16.0],
                                                           [4.0, -17.9],
                                                           [7.0, -17.9],
                                                           [3.0, -14.0],
                                                           [6.0, -12.9],
                                                           [5.0, -16.0],
                                                           [4.0, -17.9],
                                                           [7.0, -17.9],
                                                           [-88.241421, 40.091565],
                                                           [-88.241417, 40.09161],
                                                           [-88.241413, 40.091655],
                                                           [0.0, 0.0],
                                                           [-29.0, -16.0],
                                                           [-25.0, -18.0],
                                                           [-28.0, -21.0],
                                                           [-19.0, -18.0],
                                                           [3.0, -14.0],
                                                           [6.0, -12.9],
                                                           [5.0, -16.0],
                                                           [4.0, -17.9],
                                                           [7.0, -17.9],
                                                           [32.2, 22.0],
                                                           [-17.0, 7.0],
                                                           [-9.8, 5.0],
                                                           [-10.7, 0.0],
                                                           [-30.0, 21.0],
                                                           [-25.0, 18.3],
                                                           [-23.0, 18.0],
                                                           [-19.6, -13.0],
                                                           [-7.6, 14.2],
                                                           [-4.6, 11.9],
                                                           [-8.0, -4.0],
                                                           [-4.0, -3.0],
                                                           [-10.0, -6.0]
                                                         ]

        expect(@all_items.rendering_hash[:lines]).to eq [
                                                          [
                                                            [-32.0, 21.0],
                                                            [-25.0, 21.0],
                                                            [-25.0, 16.0],
                                                            [-21.0, 20.0]
                                                          ],
                                                          [
                                                            [23.0, 21.0],
                                                            [16.0, 21.0],
                                                            [16.0, 16.0],
                                                            [11.0, 20.0]
                                                          ],
                                                          [
                                                            [4.0, 12.6],
                                                            [16.0, 12.6],
                                                            [16.0, 7.6]
                                                          ],
                                                          [
                                                            [21.0, 12.6],
                                                            [26.0, 12.6],
                                                            [22.0, 17.6]
                                                          ],
                                                          [
                                                            [-33.0, 11.0],
                                                            [-24.0, 4.0],
                                                            [-26.0, 13.0],
                                                            [-31.0, 4.0],
                                                            [-33.0, 11.0]
                                                          ],
                                                          [
                                                            [-20.0, -1.0],
                                                            [-26.0, -6.0]
                                                          ],
                                                          [
                                                            [-21.0, -4.0],
                                                            [-31.0, -4.0]
                                                          ],
                                                          [
                                                            [27.0, -14.0],
                                                            [18.0, -21.0],
                                                            [20.0, -12.0],
                                                            [25.0, -23.0]
                                                          ],
                                                          [
                                                            [27.0, -14.0],
                                                            [18.0, -21.0],
                                                            [20.0, -12.0],
                                                            [25.0, -23.0]
                                                          ],
                                                          [
                                                            [-16.0, -15.5],
                                                            [-22.0, -20.5]
                                                          ]
                                                        ]

        expect(@all_items.rendering_hash[:polygons]).to eq [
                                                             [
                                                               [-14.0, 23.0],
                                                               [-14.0, 11.0],
                                                               [-2.0, 11.0],
                                                               [-2.0, 23.0],
                                                               [-8.0, 21.0],
                                                               [-14.0, 23.0]
                                                             ],
                                                             [
                                                               [-19.0, 9.0],
                                                               [-9.0, 9.0],
                                                               [-9.0, 2.0],
                                                               [-19.0, 2.0],
                                                               [-19.0, 9.0]
                                                             ],
                                                             [
                                                               [5.0, -1.0],
                                                               [-14.0, -1.0],
                                                               [-14.0, 6.0],
                                                               [5.0, 6.0],
                                                               [5.0, -1.0]
                                                             ],
                                                             [
                                                               [-11.0, -1.0],
                                                               [-11.0, -5.0],
                                                               [-7.0, -5.0],
                                                               [-7.0, -1.0],
                                                               [-11.0, -1.0]
                                                             ],
                                                             [
                                                               [-3.0, -9.0],
                                                               [-3.0, -1.0],
                                                               [-7.0, -1.0],
                                                               [-7.0, -9.0],
                                                               [-3.0, -9.0]
                                                             ],
                                                             [
                                                               [-7.0, -9.0],
                                                               [-7.0, -5.0],
                                                               [-11.0, -5.0],
                                                               [-11.0, -9.0],
                                                               [-7.0, -9.0]
                                                             ],
                                                             [
                                                               [28.0, 2.3],
                                                               [23.0, -1.7],
                                                               [26.0, -4.8],
                                                               [28.0, 2.3]
                                                             ],
                                                             [
                                                               [22.0, -6.8],
                                                               [22.0, -9.8],
                                                               [16.0, -6.8],
                                                               [22.0, -6.8]
                                                             ],
                                                             [
                                                               [16.0, 2.3],
                                                               [14.0, -2.8],
                                                               [18.0, -2.8],
                                                               [16.0, 2.3]
                                                             ],
                                                             [
                                                               [28.0, 2.3],
                                                               [23.0, -1.7],
                                                               [26.0, -4.8],
                                                               [28.0, 2.3]
                                                             ],
                                                             [
                                                               [22.0, -6.8],
                                                               [22.0, -9.8],
                                                               [16.0, -6.8],
                                                               [22.0, -6.8]],
                                                             [
                                                               [16.0, 2.3],
                                                               [14.0, -2.8],
                                                               [18.0, -2.8],
                                                               [16.0, 2.3]
                                                             ],
                                                             [
                                                               [-33.0, -11.0],
                                                               [-33.0, -23.0],
                                                               [-21.0, -23.0],
                                                               [-21.0, -11.0],
                                                               [-27.0, -13.0],
                                                               [-33.0, -11.0]
                                                             ]
                                                           ]

        expect(@all_items.rendering_hash).to eq ({lines: [[[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]], [[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]], [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]], [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]], [[-33.0, 11.0], [-24.0, 4.0], [-26.0, 13.0], [-31.0, 4.0], [-33.0, 11.0]], [[-20.0, -1.0], [-26.0, -6.0]], [[-21.0, -4.0], [-31.0, -4.0]], [[27.0, -14.0], [18.0, -21.0], [20.0, -12.0], [25.0, -23.0]], [[27.0, -14.0], [18.0, -21.0], [20.0, -12.0], [25.0, -23.0]], [[-16.0, -15.5], [-22.0, -20.5]]], points: [[3.0, -14.0], [6.0, -12.9], [5.0, -16.0], [4.0, -17.9], [7.0, -17.9], [3.0, -14.0], [6.0, -12.9], [5.0, -16.0], [4.0, -17.9], [7.0, -17.9], [-88.241421, 40.091565], [-88.241417, 40.09161], [-88.241413, 40.091655], [0.0, 0.0], [-29.0, -16.0], [-25.0, -18.0], [-28.0, -21.0], [-19.0, -18.0], [3.0, -14.0], [6.0, -12.9], [5.0, -16.0], [4.0, -17.9], [7.0, -17.9], [32.2, 22.0], [-17.0, 7.0], [-9.8, 5.0], [-10.7, 0.0], [-30.0, 21.0], [-25.0, 18.3], [-23.0, 18.0], [-19.6, -13.0], [-7.6, 14.2], [-4.6, 11.9], [-8.0, -4.0], [-4.0, -3.0], [-10.0, -6.0]], polygons: [[[-14.0, 23.0], [-14.0, 11.0], [-2.0, 11.0], [-2.0, 23.0], [-8.0, 21.0], [-14.0, 23.0]], [[-19.0, 9.0], [-9.0, 9.0], [-9.0, 2.0], [-19.0, 2.0], [-19.0, 9.0]], [[5.0, -1.0], [-14.0, -1.0], [-14.0, 6.0], [5.0, 6.0], [5.0, -1.0]], [[-11.0, -1.0], [-11.0, -5.0], [-7.0, -5.0], [-7.0, -1.0], [-11.0, -1.0]], [[-3.0, -9.0], [-3.0, -1.0], [-7.0, -1.0], [-7.0, -9.0], [-3.0, -9.0]], [[-7.0, -9.0], [-7.0, -5.0], [-11.0, -5.0], [-11.0, -9.0], [-7.0, -9.0]], [[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]], [[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]], [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]], [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]], [[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0], [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]]})
      end
    end
  end

  context 'class methods' do

    # TODO: Move 'clean' code completely into a Rake task
    specify 'class method to discover orphan records.' do
      expect(GeographicItem).to respond_to(:clean?)
    end

    specify 'class method to delete orphan records.' do
      expect(GeographicItem).to respond_to(:clean!)
    end


    specify 'class method to see if one object contains another.' do
      expect(GeographicItem).to respond_to(:contains?)
    end

    specify '.ordered_by_shortest_distance_from to specify ordering of found objects.' do
      expect(GeographicItem).to respond_to(:ordered_by_shortest_distance_from)
    end

    specify '.ordered_by_longest_distance_from' do
      expect(GeographicItem).to respond_to(:ordered_by_longest_distance_from)
    end

    specify '.disjoint_from to find all objects which are disjoint from an \'and\' list of objects.' do
      expect(GeographicItem).to respond_to(:disjoint_from)
    end

    specify '.within_radius_of to find all objects which are within a specific distance of an object.' do
      expect(GeographicItem).to respond_to(:within_radius_of)
    end

    specify '.intersecting method to intersecting an \'or\' list of objects.' do
      expect(GeographicItem).to respond_to(:intersecting)
    end


    specify '.containing_sql' do
      expect(GeographicItem.containing_sql('polygon', @p1)).to eq('ST_Contains(polygon::geometry, GeomFromEWKT(\'srid=4326;POINT (-29.0 -16.0 0.0)\'))')
      expect(GeographicItem.containing_sql('polygon', @p2)).not_to eq('ST_Contains(polygon::geometry, GeomFromEWKT(\'srid=4326;POINT (-29.0 -16.0 0.0)\'))')
    end

    context 'scopes (GeographicItems can be found by searching with) ' do
      specify '.containing - returns objects which contain another objects.' do

        expect(GeographicItem.containing('not_a_column_name', @p1).to_a).to eq([])
        expect(GeographicItem.containing('point', 'Some devious SQL string').to_a).to eq([])

        # one thing inside k
        expect(GeographicItem.containing('polygon', @p1).to_a).to eq([@k])
        # three things inside k
        expect(GeographicItem.containing('polygon', [@p1, @p2, @p3]).to_a).to eq [@k]
        # one thing outside k
        expect(GeographicItem.containing('polygon', @p4).to_a).to eq([])
        # one thing inside two things (overlapping)
        expect(GeographicItem.containing('polygon', @p12).to_a).to have(2).things
        expect(GeographicItem.containing('polygon', @p12).to_a.sort).to eq([@e1, @e2].sort)
        expect(GeographicItem.containing('polygon', @p12).to_a.sort).to eq([@e2, @e1].sort)
        # three things inside and one thing outside k
        expect(GeographicItem.containing('polygon', [@p1, @p2, @p3, @p11]).to_a).to eq([@e1, @k])
        # one thing inside one thing, and another thing inside another thing
        expect(GeographicItem.containing('polygon', [@p1, @p11]).to_a).to eq([@e1, @k])
        # two things inside one thing, and
        expect(GeographicItem.containing('polygon', @p18).to_a).to eq([@b1, @b2])
        expect(GeographicItem.containing('polygon', @p19).to_a).to eq([@b1, @b])
      end

      specify '#excluding([]) drop selves from any list of objects' do
        # @p2 would have been in the list, except for the exclude
        expect(GeographicItem.excluding([@p2]).ordered_by_shortest_distance_from('point', @p3).limit(3).to_a).to eq([@p1, @p4, @p17])
        # @p2 would *not* have been in the list anyway
        expect(GeographicItem.excluding([@p2]).ordered_by_longest_distance_from('point', @p3).limit(3).to_a).to eq([@r2024, @r2022, @r2020])
        # @r2022 would  have been in the list, except for the exclude
        expect(GeographicItem.excluding([@r2022]).ordered_by_longest_distance_from('point', @p3).limit(3).to_a).to eq([@r2024, @r2020, @p10])
      end

      specify '#ordered_by_shortest_distance_from orders objects by distance from passed object' do
        expect(GeographicItem.ordered_by_shortest_distance_from('point', @p3).limit(3).to_a).to eq([@p2, @p1, @p4])
        expect(GeographicItem.ordered_by_shortest_distance_from('line_string', @p3).limit(3).to_a).to eq([@outer_limits, @l, @f1])
        expect(GeographicItem.ordered_by_shortest_distance_from('polygon', @p3).limit(3).to_a).to eq([@e5, @e3, @e4])
        expect(GeographicItem.ordered_by_shortest_distance_from('multi_point', @p3).limit(3).to_a).to eq([@h, @rooms])
        expect(GeographicItem.ordered_by_shortest_distance_from('multi_line_string', @p3).limit(3).to_a).to eq([@f, @c])
        expect(GeographicItem.ordered_by_shortest_distance_from('multi_polygon', @p3).limit(3).to_a).to eq([@g])
        expect(GeographicItem.ordered_by_shortest_distance_from('geometry_collection', @p3).limit(3).to_a).to eq([@e, @j])
      end

      specify '#ordered_by_longest_distance_from orders objects by distance from passed object' do
        expect(GeographicItem.ordered_by_longest_distance_from('point', @p3).limit(3).to_a).to eq([@r2024, @r2022, @r2020])
        expect(GeographicItem.ordered_by_longest_distance_from('line_string', @p3).limit(3).to_a).to eq([@c3, @c1, @c2])
        expect(GeographicItem.ordered_by_longest_distance_from('polygon', @p3).limit(4).to_a).to eq([@g1, @g2, @g3, @b2])
        expect(GeographicItem.ordered_by_longest_distance_from('multi_point', @p3).limit(3).to_a).to eq([@rooms, @h])
        expect(GeographicItem.ordered_by_longest_distance_from('multi_line_string', @p3).limit(3).to_a).to eq([@c, @f])
        expect(GeographicItem.ordered_by_longest_distance_from('multi_polygon', @p3).limit(3).to_a).to eq([@g])
        expect(GeographicItem.ordered_by_longest_distance_from('geometry_collection', @p3).limit(3).to_a).to eq([@j, @e])
      end

      #TODOone: Is this test right?  What about @k, @d?
      #   @k is too far away for a limit of 4, and #d in not a polygon, it is a line_string
      specify "#disjoint_from list of objects (uses 'and')." do
        expect(GeographicItem.disjoint_from('polygon', [@e1, @e2, @e3, @e4, @e5]).limit(4).to_a).to eq([@b1, @b2, @b, @g1])
      end

      specify '#within_radius of returns objects within a specific distance of an object.' do
        expect(GeographicItem.within_radius_of('polygon', @p0, 1000000)).to eq([@e2, @e3, @e4, @e5, @area_a, @area_b, @area_c, @area_d])
      end

      specify "#intersecting list of objects (uses 'or')" do
        expect(GeographicItem.intersecting('polygon', [@l])).to eq([@k])
        expect(GeographicItem.intersecting('polygon', [@f1])).to eq([]) # Is this right?
      end

      specify '#select_distance_with_geo_object provides an extra column called \'distance\' to the output objects' do
        result = GeographicItem.select_distance_with_geo_object('point', @r2020).limit(3).order('distance').where_distance_greater_than_zero('point', @r2020).to_a
        # get back these three points
        expect(result).to eq([@r2022, @r2024, @p14])
        # 5 meters
        expect(result.first.distance).to be_within(0.1).of(5.008268179)
        # 10 meters
        expect(result[1].distance).to be_within(0.1).of(10.016536381)
        # 5,862 km (3,642 miles)
        expect(result[2].distance).to be_within(0.1).of(5862006.0029975)
      end

    end
  end


end
