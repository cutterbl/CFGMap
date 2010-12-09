/*
 * FILE:
 * gMap.js
 * 
 * PURPOSE:
 * Definition of the CFGMapLocation and CFGMap objects, and
 * accompanying and supporting functions
 * 
 * AUTHOR:
 * Stephen G "Cutter" Blades, Jr cutterDOTblATcutterscrossingDOTcom
 * 
 * EXCEPTIONS:
 * trim() and JSONString() functions discovered in the wilds of
 * the internet.
 * 
 * LICENSE:
 * CFGMap and CFGMapLocation scripts fall under the Apache
 * Software Foundation's Apache License, Version 2.0
 * (http://www.apache.org/licenses/LICENSE-2.0)
 */

// Adding a 'trim' method to the JS String object
String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
};

var JSONString = function(obj){
    var s = '[';
    for(var i = 0; i < obj.length; i++){
       s += '{';
       $.each(obj[i], function(k, v){
          s += '"' + k + '":' + v + ',';
       });
       s += '}';
       if (i < (obj.length - 1)){
          s += ',';
       }
    };
    return s.replace(/,}/g, '}') + ']';
};

/*
 * OBJECT: CFGMapLocation
 * 
 * DESCRIPTION: A location object, for locations to be placed on the map
 * 
 * PROPERTIES:
 * locOpts:Object
 * 		locId:int
 * 		dispName:String
 * 		addr1:String
 * 		addr2:String
 * 		city:String
 * 		state:String
 * 		zip:String
 * 		lat:String
 * 		lng:String
 * 		primary:boolean,
 * 		phone:String
 * dirty:boolean
 */

/*
 *	FUNCTION: constructor
 * 
 * 	DESCRIPTION:
 * 	Creates a CFGMapLocation instance, applying default arguments when not present in the options
 *
 * 	ARGUMENTS: 
 * 	options:Object
 * 		locId		int: the location ID
 * 		dispName		string: the Display Name/Title of the location
 * 		addr1		string: first address line
 * 		addr2		string: second address line
 * 		city			string: city
 * 		state		string: state abbreviation
 * 		zip			string: zip code
 * 		lat			double: latitude of the location
 * 		lng			double: longitude of the location
 * 		primary		boolean: is this the primary location (should only be one in the array)
 * 		phone		string: primary phone number
 */
CFGMapLocation = function(options){
	var args = {
	    "locId":0,
	    "dispName":"",
	    "addr1":"",
	    "addr2":"",
	    "city":"",
	    "state":"",
	    "zip":"",
	    "lat":"",
	    "lng":"",
	    "primary":false,
	    "phone":""
	};
	for(var index in args) {
		if(typeof options[index] == "undefined") options[index] = args[index];
	}
	this.locOpts = options;
	this.dirty = false;
};

/*
 * 	FUNCTION: correct():void
 * 
 * 	DESCRIPTION:
 * 	Function to update the lat/lng properties of the object, and mark it 'dirty' for change management
 * 
 * 	ARGUMENTS:
 * 	lat:String
 * 	lng:String
 */
CFGMapLocation.prototype.correct = function(lat,lng){
	this.locOpts.lat = lat;
	this.locOpts.lng = lng;
	this.setDirty(true);
};

/*
 * 	FUNCTION: setDirty():void
 * 
 * 	ARGUMENTS:
 * 	value:boolean
 * 
 * 	DESCRIPTION:
 * 	Sets the 'dirty' property to the value of 'value'
 */
CFGMapLocation.prototype.setDirty = function(value){
	this.dirty = value;
};

/*
 * 	FUNCTION: isDirty():boolean
 * 
 * 	DESCRIPTION:
 * 	Returns the value of the 'dirty' property
 */
CFGMapLocation.prototype.isDirty = function(){
	return this.dirty;
};

/*
 * 	FUNCTION: getLocId():int
 * 
 * 	DESCRIPTION:
 * 	Returns the value of the 'locId' property
 */
CFGMapLocation.prototype.getLocId = function(){
	return this.locOpts.locId;
};

/*
 * 	FUNCTION: getLat():String
 * 
 * 	DESCRIPTION:
 * 	Returns the value of the 'lat' property
 */
CFGMapLocation.prototype.getLat = function(){
	return this.locOpts.lat;
};

/*
 * 	FUNCTION: getLng():String
 * 
 * 	DESCRIPTION:
 * 	Returns the value of the 'lng' property
 */
CFGMapLocation.prototype.getLng = function(){
	return this.locOpts.lng;
};

/*
 * 	FUNCTION: getDispName():String
 * 
 * 	DESCRIPTION:
 * 	Returns the value of the 'dispName' property
 */
CFGMapLocation.prototype.getDispName = function(){
	return this.locOpts.dispName;
};

/*
 * 	FUNCTION: isPrimary():boolean
 * 
 * 	DESCRIPTION:
 * 	Returns the value of the 'primary' property
 */
CFGMapLocation.prototype.isPrimary = function(){
	return this.locOpts.primary;
};

/*
 * 	FUNCTION: getCityState():String
 * 
 * 	DESCRIPTION:
 *  Returns a formatted string combining the 'city' and 'state' values
 */
CFGMapLocation.prototype.getCityState = function(){
	var ctySt = "";
	if(this.locOpts.city.length){
		ctySt += this.locOpts.city;
	}
	if(this.locOpts.state.length){
		if(ctySt.length){
			ctySt += ", ";
		}
		ctySt += this.locOpts.state;
	}
	if(this.locOpts.zip.length){
		if(ctySt.length){
			ctySt += " ";
		}
		ctySt += this.locOpts.zip;
	}
	return ctySt;
};

/*
 * 	FUNCTION: getFullAddress():String
 * 
 * 	DESCRIPTION:
 *  Returns a formatted string combining the entire address (for marker placement and directions)
 */
CFGMapLocation.prototype.getFullAddress = function(){
	var loc = "";
	if(this.locOpts.addr1.length){
		loc += this.locOpts.addr1;
	}
	if(this.locOpts.addr2.length){
		if(loc.length){
			loc += " ";
		}
		loc += this.locOpts.addr2;
	}
	if(this.locOpts.city.length){
		if(loc.length){
			loc += ", ";
		}
		loc += this.locOpts.city;
	}
	if(this.locOpts.state.length){
		if(loc.length){
			loc += ", ";
		}
		loc += this.locOpts.state;
	}
	if(this.locOpts.zip.length){
		if(loc.length){
			loc += " ";
		}
		loc += this.locOpts.zip;
	}
	return loc;
};

/*
 * 	FUNCTION: getContent():String
 * 
 * 	DESCRIPTION:
 *  Returns a formatted HTML string fragment of a formatted address (for InfoWindow content)
 */
CFGMapLocation.prototype.getContent = function(){
	var content = '<div class="infoAddr"><address><strong>' + this.getDispName() + '</strong><br />';
	if(this.locOpts.addr1.length){
		content += this.locOpts.addr1 + '<br />';
	}
	if(this.locOpts.addr2.length){
		content += this.locOpts.addr2 + '<br />';
	}
	if(this.locOpts.city.length){
		content += this.locOpts.city;
	}
	if(this.locOpts.state.length){
		if(content.length){
			content += ", ";
		}
		content += this.locOpts.state;
	}
	if(this.locOpts.zip.length){
		if(content.length){
			content += " ";
		}
		content += this.locOpts.zip;
	}
	if(this.locOpts.phone.length){
		if(content.length){
			content += "<br />";
		}
		content += "<phone>" + this.locOpts.phone + "</phone>";
	}
	content += '</address></div>';
	return content;
};

/*
 * OBJECT: CFGMap
 * 
 * DESCRIPTION: Map object for Google Maps API v3 implementation
 * 
 * PROPERTIES:
 * mapOpts:Object
 * 		geocoder:google.maps.Geocoder
 * 		directions:google.maps.DirectionsService
 * 		renderer:google.maps.DirectionsRenderer
 * 		locs:Array
 * 		currentLoc:CFGMapLocation
 * 		mapEl:HtmlElement
 * 		dirEl:HtmlElement
 * 		zoom:int
 * 		mapTypeId:google.maps.MapTypeId.[ROADMAP|SATELLITE|TERRAIN|HYBRID]
 * 		center:String|google.maps.LatLng
 * 		locCorrect:function
 * map:google.maps.Map
 * corrArr:Array
 * correct:boolean
 * 
 * ARGUMENTS:
 * locs			array: array of CFGMapLocation objects, for locations on the map
 * mapEl		HtmlElement: node that the map should populate
 * dirEl		HtmlElement: node that directions will populate
 * 
 * FUNCTIONS:
 * init():void - Initializes the CFGMap object, placing the initial markers on the map, and
 * 		setting the currentLoc to the primary location
 * setMarker(loc:CFGMapLocation,init:boolean):void - Places a marker on the map for a location. If Google Map
 * 		doesn't yet exist then it will create one, assigning to the global map var. Geocodes locations
 * 		who do not yet have lat/lng values. If init is true (only on first run of marker placements), and
 * 		locations are geocoded, then those values are passed back to the server for record updates.
 * getDirections(fromStr:string):void - Plots directions from the fromStr to the currentLoc
 * attachMarker(marker:google.maps.Marker,loc:CFGMapLocation) - Binds events to markers for display of the InfoWindow
 * resetCenterToLoc(locId:int) - Re-centers the map to a specific location, and resets the currentLoc var
 */

/*
 *	FUNCTION: constructor
 * 
 * 	DESCRIPTION:
 * 	Creates a CFGMap instance, applying default arguments when not present in the options
 *
 * 	ARGUMENTS: 
 * 	options:Object
 * 		geocoder		google.maps.Geocoder: Google geocoding object
 * 		directions		google.maps.DirectionsService: Google's service for getting directions
 * 		renderer		google.maps.DirectionsRenderer: Google's service for rendering directions
 * 		locs			array:An array of locations (CFGMapLocations) to plot on the map
 * 		currentLoc		CFGMapLocations:The current active location (used as the 'to' address when getting directions)
 * 		mapEl			HtmlElement:The node to which the map will display
 * 		dirEl			HtmlElement:The node to which the directions will display
 * 		zoom			int:The map's zoom level
 * 		mapTypeId		google.maps.MapTypeId:The type of map to display
 * 		center			String:google.maps.LatLng:The center of the map
 * 		locCorrect		function:A callback function for updating location info at the server (used on initialization plotting
 * 							locations that are geocoded)
 */
CFGMap = function(options){
	var args = {
		"geocoder": new google.maps.Geocoder(),
		"directions": new google.maps.DirectionsService(),
		"renderer": new google.maps.DirectionsRenderer(),
		"locs": new Array(),
		"currentLoc": undefined,
		"mapEl": undefined,
		"dirEl": undefined,
		"zoom": 12,
		"mapTypeId": google.maps.MapTypeId.ROADMAP,
		"center": undefined,
	    "locCorrect":function(){}
	};
	for(var index in args) {
		if(typeof options[index] == "undefined") options[index] = args[index];
	}
	this.mapOpts = options;
	this.map = undefined;
	this.corrArr = new Array();
	this.correct = false;
	this.init();
};

/*
 * 	FUNCTION: init():void
 * 
 * 	DESCRIPTION:
 *  Creates the Google map, centers it on the primary location, and plots all other locations
 */
CFGMap.prototype.init = function(){
	var locs = this.getLocs();
	var center = this.getCenter();
	var myOptions = {
		zoom: this.getZoom(),
		mapTypeId: this.getMapTypeId()
	};
	if(center !== undefined){
		if (typeof center === "string"){
			this.setCenter(center);
		}
		myOptions.center = this.getCenter();
	}
	this.map = new google.maps.Map(this.getMapEl(), myOptions);
	for(var i = 0;i < locs.length; i++){
		this.setMarker(locs[i],true,(i === (locs.length-1)));
	  	if(locs[i].isPrimary()){
	  		this.setCurrentLoc(locs[i]);
	  	}
	}
};

/*
 * 	FUNCTION: getMap():google.maps.Map
 * 
 * 	DESCRIPTION:
 *  Returns the 'map' property
 */
CFGMap.prototype.getMap = function(){
	return this.map;
};

/*
 * 	FUNCTION: getGeocoder():google.maps.Geocoder
 * 
 * 	DESCRIPTION:
 *  Returns the 'geocoder' property
 */
CFGMap.prototype.getGeocoder = function(){
	return this.mapOpts.geocoder;
};

/*
 * 	FUNCTION: getDirectionsObj():google.maps.DirectionsService
 * 
 * 	DESCRIPTION:
 *  Returns the 'directions' property
 */
CFGMap.prototype.getDirectionsObj = function(){
	return this.mapOpts.directions;
};

/*
 * 	FUNCTION: getRenderer():google.maps.DirectionsRenderer
 * 
 * 	DESCRIPTION:
 *  Returns the 'renderer' property
 */
CFGMap.prototype.getRenderer = function(){
	return this.mapOpts.renderer;
};

/*
 * 	FUNCTION: getLocs():array
 * 
 * 	DESCRIPTION:
 *  Returns the 'locs' property
 */
CFGMap.prototype.getLocs = function(){
	return this.mapOpts.locs;
};

CFGMap.prototype.getCurrentLoc = function(){
	return this.mapOpts.currentLoc;
};

/*
 * 	FUNCTION: setCurrentLoc(loc:CFGMapLocation):void
 * 
 * 	DESCRIPTION:
 *  Sets the 'currentLoc' property
 *  
 *  ARGUMENTS:
 *  loc:CFGMapLocation
 */
CFGMap.prototype.setCurrentLoc = function(loc){
	this.mapOpts.currentLoc = loc;
};

/*
 * 	FUNCTION: getMapEl():HtmlElement
 * 
 * 	DESCRIPTION:
 *  Returns the 'mapEl' property
 */
CFGMap.prototype.getMapEl = function(){
	return this.mapOpts.mapEl;
};

/*
 * 	FUNCTION: getDirEl():HtmlElement
 * 
 * 	DESCRIPTION:
 *  Returns the 'dirEl' property
 */
CFGMap.prototype.getDirEl = function(){
	return this.mapOpts.dirEl;
};

/*
 * 	FUNCTION: getZoom():int
 * 
 * 	DESCRIPTION:
 *  Returns the 'zoom' property
 */
CFGMap.prototype.getZoom = function(){
	return this.mapOpts.zoom;
};

/*
 * 	FUNCTION: getMapTypeId():google.maps.MapTypeId
 * 
 * 	DESCRIPTION:
 *  Returns the 'mapTypeId' property
 */
CFGMap.prototype.getMapTypeId = function(){
	return this.mapOpts.mapTypeId;
};

/*
 * 	FUNCTION: getCenter():String|google.maps.LatLng
 * 
 * 	DESCRIPTION:
 *  Returns the 'center' property
 */
CFGMap.prototype.getCenter = function(){
	return this.mapOpts.center;
};

/*
 * 	FUNCTION: setCenter(center:String):void
 * 
 * 	DESCRIPTION:
 *  Sets the value of 'center', converting a string to the google.maps.LatLng object type
 */
CFGMap.prototype.setCenter = function(center){
	this.mapOpts.center = new google.maps.LatLng(center);
};

/*
 * 	FUNCTION: setMarker(loc:CFGMapLocation,init:boolean,final:boolean):void
 * 
 * 	DESCRIPTION:
 *  Takes a location, geocodes it if necessary, and calls creatMarker()
 */
CFGMap.prototype.setMarker = function(loc,init,final){
	var LatLng = undefined;
	var el = this;
	if(loc.getLat() === "" || loc.getLng() === ""){
		el.getGeocoder().geocode( { 'address': loc.getFullAddress()}, function(results, status) {
		  if (status == google.maps.GeocoderStatus.OK) {
	        loc.correct(results[0].geometry.location.lat(),results[0].geometry.location.lng());
	        el.corrArr.push({locId:loc.getLocId(),lat:loc.getLat(),lng:loc.getLng()});
	  		el.correct = true;
	        el.createMarker(loc,el,init,final);
	      } else {
	        alert("Geocoding of this location was not successful\nfor the following reason: " + status);
	      }
	   }); 
	} else {
		el.createMarker(loc,el,init,final);
	}
};

/*
 * 	FUNCTION: createMarker(loc:CFGMapLocation,mapObj:CFGMap,init:boolean,final:boolean):void
 * 
 * 	DESCRIPTION:
 *  Takes a location and puts a marker on the map. Re-centers the map to the primary location.
 *  If 'final' is true, and corrections need to be made to server-side data for the locations,
 *  then it will call the callback method if one is defined in the properties
 */
CFGMap.prototype.createMarker = function(loc,mapObj,init,final){
	var LatLng = new google.maps.LatLng(loc.getLat(), loc.getLng())
	var map = mapObj.getMap();
	var marker = new google.maps.Marker({
		map: map,
		position: LatLng,
        title: loc.getDispName()
	});
	mapObj.attachMarker(marker,loc);
	if(init && loc.isPrimary()){
      	map.setCenter(LatLng);
    }
	if(final && mapObj.correct){
		mapObj.callCorrections();
	}
};

/*
 * 	FUNCTION: getDirections(fromStr:String):void
 * 
 * 	DESCRIPTION:
 * 	Plots directions on the map from the currentLoc to the 'fromStr'
 */
CFGMap.prototype.getDirections = function(fromStr){
	var el = this;
	el.getDirectionsObj().route({
		origin: fromStr,
		destination: el.getCurrentLoc().getFullAddress(),
		travelMode: google.maps.DirectionsTravelMode.DRIVING}, 
		function(results,status){
			if(status === "OK"){
				el.getRenderer().setOptions({
					directions: results,
					map: el.getMap(),
					panel: el.getDirEl()
				});
			} else {
				alert("There was an error retrieving proper routing directions.");
			}
		});
};

/*
 * 	FUNCTION: resetCenterToLoc(locId:int):void
 * 
 * 	DESCRIPTION:
 * 	Re-centers the map to the location in the 'locs' array with the corresponding location id
 */
CFGMap.prototype.resetCenterToLoc = function(locId){
	var locs = this.getLocs();
	for(var i = 0;i < locs.length;i++){
		if(locs[i].getLocId() === parseInt(locId)){
			this.setCurrentLoc(locs[i]);
			break;
		}
	}
	var LatLng = new google.maps.LatLng(this.getCurrentLoc().getLat(), this.getCurrentLoc().getLng());
	this.getMap().setCenter(LatLng);
};

/*
 * 	FUNCTION: attachMarker(marker:google.maps.Marker,loc:CFGMapLocation):void
 * 
 * 	DESCRIPTION:
 * 	A bind function to show/hide an InfoWindow associated with the marker's location
 */
CFGMap.prototype.attachMarker = function(marker,loc){
	var infoWindow = new google.maps.InfoWindow({
		content: loc.getContent()
	});
	google.maps.event.addListener(marker, 'mouseover', function() {
	    infoWindow.open(this.getMap(),marker);
	});
	google.maps.event.addListener(marker, 'mouseout', function() {
	    infoWindow.close();
	});
};

/*
 * 	FUNCTION: callCorrections():void
 * 
 * 	DESCRIPTION:
 * 	Calls the callback function identified in the 'locCorrect' option. Passes an array of
 * 	locations whose lat/lng have be reset by geocoding. Callback function would pass array
 * 	to server via ajax to correct database records of the locations.
 */
CFGMap.prototype.callCorrections = function(){
	this.mapOpts.locCorrect(this.corrArr);
};

/*
 * 	FUNCTION: clearDirtyLocs():void
 * 
 * 	DESCRIPTION:
 * 	Called by success function of the callCorrections ajax post of corrected locations, to
 * 	clear the 'dirty' flag of the locations.
 */
CFGMap.prototype.clearDirtyLocs = function(){
	var locs = this.getLocs();
	for(var i = 0;i < locs.length;i++){
		locs[i].setDirty(false);
	}
};