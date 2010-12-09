<!--- ===========================================================================
// CLASS/COMPONENT/TEMPLATE:
// cfgmap.cfm
//
// DESCRIPTION:
// Custom Tag for Google Maps JavaScript Maps API V3 (http://code.google.com/apis/
// maps/documentation/javascript/). CFGMap is a fork of Scott Mebberson's Google
// Maps Tag project (http://googlemapstag.riaforge.org/), to support Google's
// latest version of their maps javascript api.
//
// CFGMap requires an array of location structs, even if there is only a single
// location, to properly center the map and place a marker on the location(s).
//
// Supporting JS file (gMap.js) should be located in the [supportDir]\scripts\ directory
//
// DISCLAIMER:
// This Custom Tag is part of the Google Maps Tag v3 open source project on
// RIAForge. This project is licensed under the Apache Foundation's Apache
// License (http://www.apache.org/licenses/LICENSE-2.0)
//
// AUTHOR:
// Steve 'Cutter' Blades (SGB), sbladesATdealerskinsDOTcom
//
// PARAMS:
// supportDir:string		This is the absolute path to the resource directory,
//							within which would be the supporting script, and any
//							accompanying files (scripts, css, images, etc).
// additionalScript:string	This is the last external script loaded, if passed
//							in when the tag is called. This is where a developer
//							would place the callback function to use to clean up
//							geocoded location records, control a form to get
//							directions plotted on a map, and more.
// stylesheet:string		Adds a custom stylesheet to the header, in proper
//							flow with other assets
// printStylesheet:string	Adds a custom print stylesheet to the header, in
//							proper flow with other assets
// locArray:array			This is a ColdFusion Array of location structs.
//							Locations structs should have the following keys:
//							{
//								locationId:int,
//								Name:string,
//								Address1:string,
//								Address2:string,
//								City:string,
//								State:string, // Abbreviation
//								Zip:string,
//								Latitude:string,
//								Longitude:string,
//								primaryMarker:boolean, // identifies which *one*
//									//location is the 'primary' location
//								phone:string
//							}
// locArrayName:string		A (unique) string for the JavaScript var that will
//								house the locations
// uniqueMapObj:string		A (unique) string for the JavaScript var that will
//								house the map instance
// secondaryMapInstance:boolean		This denotes if this custom tag call is for
//										an additional map instance on a page
//										TODO: not fully capable yet
// correctionCallback:string		The name of the callback function to correct
//										db records of geocoded locations
// width:string				The width of the map
// height:string			The height of the map
// zoom:numeric				The zoom level of the map
// mapTypeId:string			The mapTypeId of the map object. Valid values are:
//								[ROADMAP|HYBRID|SATELLITE|TERRAIN]
// mapDiv:string			The name of the div element to which the map should render
// directionsDiv:string		the name of the div element to which directions should render
// bDebug:boolean			TODO: to create alternative conditional logic, in the
//								event of debugging
//
// REVISION HISTORY:
//
// ******************************************************************************
// User: SGB  [Date: 12.02.10]
// Initial Creation
// ******************************************************************************
=========================================================================== --->
<cfsetting enablecfoutputonly="true">

<cfparam name="ATTRIBUTES.supportDir" default="/" type="string" />
<cfparam name="ATTRIBUTES.additionalScript" default="" type="string" />
<cfparam name="ATTRIBUTES.stylesheet" default="" type="string" />
<cfparam name="ATTRIBUTES.printStylesheet" default="" type="string" />
<cfparam name="ATTRIBUTES.locArray" default="ArrayNew(1)" type="array" />
<cfparam name="ATTRIBUTES.locArrayName" default="_locArr" type="string" />
<cfparam name="ATTRIBUTES.uniqueMapObj" default="_cfGMapObj" type="string" />
<cfparam name="ATTRIBUTES.secondaryMapInstance" default="false" type="boolean" />
<cfparam name="ATTRIBUTES.correctionCallback" default="" type="string" />
<cfparam name="ATTRIBUTES.width" default="800px" type="string" />
<cfparam name="ATTRIBUTES.height" default="425px" type="string" />
<cfparam name="ATTRIBUTES.zoom" default="13" type="numeric" />
<cfparam name="ATTRIBUTES.mapTypeId" default="ROADMAP" type="string" />
<cfparam name="ATTRIBUTES.mapDiv" default="googlemapstag" type="string" />
<cfparam name="ATTRIBUTES.directionsDiv" default="googleMapsTag_directions" type="string" />
<cfparam name="ATTRIBUTES.bDebug" default="false" type="boolean" />
<!--- Use the VARIABLES scope here, to keep it in the Custom Tag alone --->
<cfset VARIABLES.LatLng = "" />
<!--- Putting the API piece here, for easy change --->
<!--- TODO: The 'sensor' querystring var here is for delineation between desktop and mobile --->
<cfset VARIABLES.apiStr = "http://maps.google.com/maps/api/js?sensor=false" />

<!--- only return a result when the ExecutionMode is start --->
<cfif thisTag.ExecutionMode is 'start'>

	<!--- let's output the required javascript --->
	<cfsavecontent variable="VARIABLES.mapHeader">
	<cfoutput><script type='text/javascript' src='#ATTRIBUTES.supportDir#scripts/gMap.js'></script>
	</cfoutput>
	<cfif Len(ATTRIBUTES.additionalScript)><!--- If an additional script is passed in... --->
		<cfoutput><script type='text/javascript' src='#ATTRIBUTES.supportDir#scripts/#ATTRIBUTES.additionalScript#'></script>
		</cfoutput>
	</cfif>
	<cfif Len(ATTRIBUTES.stylesheet)><!--- If a stylesheet is passed in... --->
		<cfoutput><link rel='stylesheet' type='text/css' href='#ATTRIBUTES.supportDir#css/#ATTRIBUTES.stylesheet#' />
		</cfoutput>
	</cfif>
	<cfoutput><style type="text/css">
	    table td {
	    	vertical-align: top;
	    }
		###ATTRIBUTES.mapDiv# {
			width: #ATTRIBUTES.width#;
		 	height: #ATTRIBUTES.height#;
		}
    </style>
	</cfoutput>
	<cfif Len(ATTRIBUTES.printStylesheet)><!--- If a print stylesheet is passed in... --->
		<cfoutput><link rel='stylesheet' type='text/css' media='print' href='#ATTRIBUTES.supportDir#css/#ATTRIBUTES.printStylesheet#' />
		</cfoutput>
	</cfif>
	<cfoutput><script type="text/javascript">
		// The locations array
		var #ATTRIBUTES.locArrayName# = new Array();
		// The CFGMap object instance
		var #ATTRIBUTES.uniqueMapObj#;
		// We'll populate the locations array with CFGMapLocation objects
		</cfoutput>
		<cfloop array="#ATTRIBUTES.locArray#" index="VARIABLES.i"><cfoutput>#ATTRIBUTES.locArrayName#.push(new CFGMapLocation({
			locId: #VARIABLES.i['locationID']#,
			dispName: "#VARIABLES.i['Name']#",
			addr1: "#VARIABLES.i['Address1']#",
			addr2: "#VARIABLES.i['Address2']#",
			city: "#VARIABLES.i['City']#",
			state: "#VARIABLES.i['State']#",
			zip: "#VARIABLES.i['zip']#",
			lat: "#VARIABLES.i['Latitude']#",
			lng: "#VARIABLES.i['Longitude']#",
			primary: #VARIABLES.i['primaryMarker']#,
			phone: "#VARIABLES.i['phone']#"
		}));</cfoutput>
		<cfif VARIABLES.i['primaryMarker'] and (Len(VARIABLES.i['Latitude']) and Len(VARIABLES.i['Latitude']))>
			<cfset VARIABLES.LatLng = VARIABLES.i['Latitude'] & "," & VARIABLES.i['Longitude'] />
		</cfif>
		</cfloop>
	<cfoutput>
		// This is the callback function, once the api is loaded
		function initialize(){
			// Create a new CFGMap object
			#ATTRIBUTES.uniqueMapObj# = new CFGMap({
				locs: #ATTRIBUTES.locArrayName#,
				mapTypeId: google.maps.MapTypeId.#ATTRIBUTES.mapTypeId#,
				mapEl: document.getElementById("#ATTRIBUTES.mapDiv#"),
				dirEl: document.getElementById("#ATTRIBUTES.directionsDiv#"),
				zoom: #ATTRIBUTES.zoom#<cfif Len(VARIABLES.LatLng)>,
				center: "#VARIABLES.LatLng#"</cfif><cfif Len(ATTRIBUTES.correctionCallback)>,
				locCorrect: #ATTRIBUTES.correctionCallback#</cfif>
			});
		}
	</cfoutput>
	<!--- If this is the first map instance then instantiate the Google Maps API --->
	<!---
	 //	TODO: No solid plan yet for implementing multiple maps. Have to figure out how to handle that from
	 //		  the perspective of the initialization callback.
	 --->
	<cfif not ATTRIBUTES.secondaryMapInstance>
		<cfoutput>function loadScript() {
		  var script = document.createElement("script");
		  script.type = "text/javascript";
		  script.src = "#VARIABLES.apiStr#&callback=initialize";
		  document.body.appendChild(script);
		}

		window.onload = loadScript;</cfoutput>
	</cfif>

	<cfoutput></script></cfoutput>
	</cfsavecontent>

	<cfhtmlhead text="#VARIABLES.mapHeader#" />

	<cfoutput><div id="#ATTRIBUTES.mapDiv#"></div></cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false" />