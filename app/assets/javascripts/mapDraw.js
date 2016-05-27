var _init_georeference_google_map;      //DISPLAY/SHOW google map of georeference

_init_georeference_google_map = function init_georeference_google_map()        // initialization function for georeference google map
{
  if ($('#georeference_google_map_canvas').length) {    //preempt omni-listener affecting wrong canvas
    if ($('#feature_collection').length) {
      var newfcdata = $("#feature_collection");
      var fcdata = newfcdata.data('feature-collection');

      initializeMap("georeference_google_map_canvas", fcdata);
    }
  }
}

$(document).ready(_init_georeference_google_map);
$(document).on("page:load", _init_georeference_google_map);


function buildFeatureCollectionFromShape(shape, shape_type) {

  //  var featureCollection = [];
  var feature = [];
  var coordinates = [];
  var coordList = [];
  var geometry = [];
  var overlayType = shape_type[0].toUpperCase() + shape_type.slice(1);
  var radius = undefined;

  switch (overlayType) {
    case 'Polyline':
      overlayType = 'LineString';
      break;
    case 'Marker':
      overlayType = 'Point';
      coordinates.push(shape.position);
      break;
    case 'Circle':
      overlayType = 'Point';

      coordinates.push(shape.center);
      radius = shape.radius;
      break;
  }

  if (coordinates.length == 0) {      // 0 if not a point or circle, coordinates is empty
    coordinates = shape.getPath().getArray();     // so get the array from the path

    for (var i = 0; i < coordinates.length; i++) {      // for LineString or Polygon
      geometry.push([coordinates[i].lng(), coordinates[i].lat()]);
    }

    if (overlayType == 'Polygon') {
      geometry.push([coordinates[0].lng(), coordinates[0].lat()]);
      coordList.push(geometry);
    }
    else {
      coordList = geometry;
    }

  }
  else {          // it is a circle or point
    geometry = [coordinates[0].lng(), coordinates[0].lat()];
    coordList = geometry;
  }

  feature.push({
    "type": "Feature",
    "geometry": {
      "type": overlayType,
      "coordinates": coordList
    },
    "properties": {}
  });

  // if it is a circle, the radius will be defined, so set the property
  if (radius != undefined) {
    feature[0]['properties'] = {"radius": radius};
  }

  return feature
}

function removeItemFromMap(item) {
  item.setMap(null);
}

// widget name is a css selector for an id'ed div, like "#my_widget"
function initializeGoogleMapWithDrawManager(widget_name) {
  var widget = $(widget_name);

  // a legal feature collection and map-center value in the widget is required, or the code fails
  var fcdata = widget.data('feature-collection');

  var map_center = widget.data('map-center');
  var map_canvas = widget.data('map-canvas');
  var map = initializeGoogleMap(map_canvas, fcdata, map_center);
  var drawingManager = initializeDrawingManager(map, widget.data('mapDrawingModes'));

  return [map, drawingManager];
}


// This references nothing in the DOM!
// TODO: make more forgiving by allowing null fcdata or map_center_parts (stub blank legal values)
// in these cases draw a default map
function initializeGoogleMap(map_canvas, fcdata, map_center) {

  // does this need to be set?  would it alter fcdata if not set?
  var mapData = fcdata;

  //
  // find a bounding box for the map (and a map center?)
  //
  var bounds = {};    //xminp: xmaxp: xminm: xmaxm: ymin: ymax: -90.0, center_long: center_lat: gzoom:

/////////// previously omitted update to maps.js //////////////
// bounds for calculating center point
  var width;
  var height;
  var canvas_ratio = 1.0;     // default value
  var style = document.getElementById(map_canvas).style;

  if (style != null) {      // null short for undefined in js
    if (style.width != undefined && style.height != undefined) {
      width = style.width.toString().split('px')[0];
      height = style.height.toString().split('px')[0];
      canvas_ratio = width / height;
    }
  }
///////////////////////////////////////////////////////////////
  // a map center looks like  'POINT (0.0 0.0 0.0)' as (x, y, z)
  var lat; // y
  var lng; // x
  if (map_center != undefined) {
    var map_center_parts = map_center.split("(");
    var map_center_coords = map_center_parts[1].split(' ');
    lat = map_center_coords[1]; // y
    lng = map_center_coords[0]; // x
  }
  else {
    lat = '0.0';
    lng = '0.0';
  }
  // TODO: what does this actually do, should it be calculateCenter()?  If it is
  // setting a value for bounds then it should be assinging bounds to a function
  // that returns bounds
  getData(mapData, bounds);  // scan var data as feature collection with homebrew traverser, collecting bounds
/////////// previously omitted update to maps.js //////////////
  bounds.canvas_ratio = canvas_ratio;
  bounds.canvas_width = width;
  bounds.canvas_height = height;
///////////////////////////////////////////////////////////////
  var center_lat_long = get_window_center(bounds);      // compute center_lat_long from bounds and compute zoom level as gzoom

  //// override computed center with verbatim center
  //if (bounds.center_lat == 0 && bounds.center_long == 0) {
  //    center_lat_long = new google.maps.LatLng(lat, lng)
  //}
  // override computed center with verbatim center
  if ((lat != undefined && lat != '0.0') && (lng != undefined && lng != '0.0')) {   // if nonzero center supplied
    center_lat_long = new google.maps.LatLng(lat, lng);
    if (bounds.gzoom > 1) {   // this looks like an artifact of previous
      bounds.gzoom -= 1;     // zoom calculations to assure map fits all areas
    }
  }

  var mapOptions = {
    center: center_lat_long,
    zoom: bounds.gzoom
  };

  var map = new google.maps.Map(document.getElementById(map_canvas), mapOptions);

  map.data.setStyle({
    icon: '/assets/map_icons/mm_20_gray.png',
    fillColor: '#222222',
    strokeOpacity: 0.5,
    strokeColor: "black",
    strokeWeight: 1,
    fillOpacity: 0.2
  });

  map.data.addGeoJson(mapData);
  if (document.getElementById("map_coords") != undefined) {
    document.getElementById("map_coords").textContent = 'LAT: ' + center_lat_long['lat']()
      + ' - LNG: ' + center_lat_long['lng']() + ' - ZOOM: ' + bounds.gzoom;
  }
  var sw = bounds.sw;
  var ne = bounds.ne;
  var coordList = [];     // migrated from maps.js 24SEP2015 JRF
  coordList.push([sw['lng'](), sw['lat']()]);
  coordList.push([sw['lng'](), ne['lat']()]);
  if (sw['lng']() > 0 && ne['lng']() < 0) {
    coordList.push([180.0, ne['lat']()])
  }
  coordList.push([ne['lng'](), ne['lat']()]);
  coordList.push([ne['lng'](), sw['lat']()]);
  if (sw['lng']() > 0 && ne['lng']() < 0) {
    coordList.push([-180.0, sw['lat']()])
  }
  coordList.push([sw['lng'](), sw['lat']()]);
  var temparray = [];
  temparray[0] = coordList;
  coordList = temparray;        // this is an expedient kludge to get [[[lng,lat],...]]
  var bounds_box = {
    "type": "Feature",
    "geometry": {
      "type": "multilinestring",
      "coordinates": coordList
    },
    "properties": {}
  };
  map.data.addGeoJson(bounds_box);
  return map;
}


//var map_options = {
//
//  basic: {
//    drawingMode: google.maps.drawing.OverlayType.CIRCLE,
//    drawingControl: true,
//    drawingControlOptions: {
//      position: google.maps.ControlPosition.TOP_CENTER,
//      drawingModes: [
//        google.maps.drawing.OverlayType.MARKER,
//        google.maps.drawing.OverlayType.CIRCLE,
//        google.maps.drawing.OverlayType.POLYGON,
//        google.maps.drawing.OverlayType.POLYLINE//,
//        //   google.maps.drawing.OverlayType.RECTANGLE
//      ]
//    },
//    markerOptions: {
//      icon: '/assets/map_icons/mm_20_red.png',
//      editable: true
//    },
//    circleOptions: {
//      fillColor: '#66cc00',
//      fillOpacity: 0.3,
//      strokeWeight: 1,
//      clickable: false,
//      editable: true,
//      zIndex: 1
//    },
//    polygonOptions: {
//      fillColor: '#880000',
//      fillOpacity: 0.3,
//      editable: true,
//      strokeWeight: 1,
//      strokeColor: 'black'
//    },
//    polylineOptions: {
//      fillColor: '#880000',
//      fillOpacity: 0.3,
//      editable: true,
//      strokeWeight: 1,
//      strokeColor: 'black'
//    }
//
//  };
//
// map_options['picker'] = map_options['basic'].merge(
//    drawingModes: [
//      google.maps.drawing.OverlayType.CIRCLE,
//      google.maps.drawing.OverlayType.POLYGON, /,
//      //   google.maps.drawing.OverlayType.RECTANGLE
//    ]
//};
//
//
//
//myOptions = map_options['basic'].merge(map_options['picker_widget'] )
//
//myDrawingManger = new google.maps.drawing.DrawingManager((myOptions )
//
//
//var drawing_managers = {
//  all: new(google.maps.drawing.DrawingManager({
//
//
//
//  })),
//
//
//
//  picker: new(google... )
//
//}
//
//drawing_managers('picker).setMap(map)

function makeOverlayType(mode) {
  var drawingMode = undefined;
  switch (mode) {                                       // set default drawingMode if valid
    case 'MARKER':
      drawingMode = google.maps.drawing.OverlayType.MARKER;
      break;
    case 'CIRCLE':
      drawingMode = google.maps.drawing.OverlayType.CIRCLE;
      break;
    case 'POLYGON':
      drawingMode = google.maps.drawing.OverlayType.POLYGON;
      break;
    case 'POLYLINE':
      drawingMode = google.maps.drawing.OverlayType.POLYLINE;
      break;
    case 'RECTANGLE':
      drawingMode = google.maps.drawing.OverlayType.RECTANGLE;
      break;
  }                                                               // default mode set or not, find counterpart item
  return drawingMode;
}


function initializeDrawingManager(map, mapDrawingModes) {
  var drawingMode = undefined;
  var drawingModes = [];
  var i;
  var j = 0;
  if (mapDrawingModes != undefined) {                                            // attempt at defined modes exists
    var modes = mapDrawingModes.split(',');                                     // separate into parts
    modes.forEach(function (item, index) {
      modes[index] = item.toUpperCase().trim()
    });   // and isolate from any spaces
    if (modes[0].indexOf('ACTIVE:') >= 0) {                           // if default mode specified
      var defaultMode = modes[0].split(':');                          // separate key/value
      defaultMode[1] = defaultMode[1].toUpperCase().trim();
      drawingMode = makeOverlayType(defaultMode[1]);                 // set default drawingMode if valid
      modes[0] = drawingMode.toUpperCase();                         // backfill the original vector
      for (i = 1; i < modes.length; i++) {
        if (defaultMode[1] == modes[i]) {                           // look for presence of default in latter list
          drawingModes.push(makeOverlayType(modes[i]));             // if it is, push it as a semaphore
          j = 1;
        }
      }
    }             // end SELECT:
      var thisMode;
    if (drawingMode && drawingModes.length) {            // if >< 0 , there is a counterpart to the SELECT:
      //j = 0;
        drawingModes = [];
      }
      for (i = j; i < modes.length; i++) {
        thisMode = makeOverlayType(modes[i]);
        if (thisMode) {
          drawingModes.push(thisMode)
        }
      }

  }               // end != undefined
  else {                // use default setup
    drawingModes = [
      google.maps.drawing.OverlayType.MARKER,
      google.maps.drawing.OverlayType.CIRCLE,
      google.maps.drawing.OverlayType.POLYGON,
      google.maps.drawing.OverlayType.POLYLINE//,
      //google.maps.drawing.OverlayType.RECTANGLE
    ];
    drawingMode = google.maps.drawing.OverlayType.CIRCLE;
  }

  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingMode: drawingMode,
    drawingControl: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: drawingModes
    },
    markerOptions: {
      icon: '/assets/map_icons/mm_20_red.png',
      editable: true
    },
    circleOptions: {
      fillColor: '#66cc00',
      fillOpacity: 0.3,
      strokeWeight: 1,
      clickable: false,
      editable: true,
      zIndex: 1
    },
    polygonOptions: {
      fillColor: '#880000',
      fillOpacity: 0.3,
      editable: true,
      strokeWeight: 1,
      strokeColor: 'black'
    },
    polylineOptions: {
      fillColor: '#880000',
      fillOpacity: 0.3,
      editable: true,
      strokeWeight: 1,
      strokeColor: 'black'
    }
  });

  drawingManager.setMap(map);
  return drawingManager;
}

function addDrawingListeners(map, event) {
  return true;
}
