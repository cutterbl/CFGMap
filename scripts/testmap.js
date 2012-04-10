/*
 * TEMPLATE:
 * /scripts/testmap.js
 * 
 * DESCRIPTION:
 * For added functionality, enhancing CFGMap example. Here we apply
 * event listeners to the "Get Directions" form on the page to map
 * out directions from the map's current location (either the only
 * location passed in, or the one selected in the drop down). There's
 * also a sample callback function to show the basics of sending 
 * lat/lng info back to the server after a location has been geocoded 
 * by address. This is so one can store that info, returned
 * in the location array on next page request so that geolocation
 * doesn't occur on every page request. We're using JQuery 1.4.4 in
 * these examples.
 * 
 * AUTHOR:
 * Stephen G 'Cutter' Blades, Jr cutterDOTblATcutterscrossingDOTcom
 */

// This is our callback function to correct lat/lng for locations that didn't have the info in the db
var correctLocation = function(corrArr){
	/*
	 * Uncomment this ajax call to send geocoded lat lng info back to the server for processing
	$.ajax({
		data: {
			corrArr: JSONString(corrArr),
			method: 'correctLocsLatLng',
			returnFormat: 'json'
		},
		url:"/cfc/Locations.cfc",
		error: function(req,status,error){
			//console.log("error: ",arguments);
		},
		success: function(data,status,request){
			var ret = eval("ret = " + data.trim()); // trim function in gMap.js
			if(ret.success){
				_cfGMapObj.clearDirtyLocs();
			} else {
				var message = (ret.message !== undefined)?ret.message:"There was an issue updating the locations on the server";
				alert(message);
			}
		}
	});*/
};

// Get Directions from a point to the currentLoc
var GetDirections = function(fromStr){
	$('#dirDiv').addClass('clsDir');
	_cfGMapObj.getDirections(fromStr);
};

// Gets directions from point in the location list
var ChangeMap = function(fromStr){
	GetDirections(fromStr);
};

$(document).ready(function() {
	// Bind click event to the Get Directions button
	$('#updForm').click(function(){
		// reference to the directions form
		var frm = $('form#frmDir');
		// create a single string of address info to route from
		var fromStr = "";
		if($('input#street',frm).val().length){
			fromStr += $('input#street',frm).val();
		}
		if($('input#suburb',frm).val().length){
			if(fromStr.length){
				fromStr += ', ';
			}
			fromStr += $('input#suburb',frm).val();
		}
		if($('select#state',frm).val().length){
			if(fromStr.length){
				fromStr += ', ';
			}
			fromStr += $('select#state',frm).val();
		} 
		if($('input#zip',frm).val().length){
			if(fromStr.length){
				fromStr += ' ';
			}
			fromStr += $('input#zip',frm).val();
		}
		// call to get directions
		GetDirections(fromStr);
		// can we jump to this anchor on directions load?
		// anchor tag is already in place on index.cfm
		location.href = '#dirDiv';
	});
	
	// When the location drop down is changed, reset the center of the map
	$('#locID','#printLink').change(function(){
		_cfGMapObj.resetCenterToLoc($('#locID','#printLink').val());
	});
	
	// When a location list anchor is selected, update the directions from that location to the currentLoc
	$('a','#locList').click(function(){
		ChangeMap($(this).text());
		return false;
	});
});