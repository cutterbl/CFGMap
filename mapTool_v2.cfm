<!--- ===========================================================================
// CLASS/COMPONENT:
// DS2/MapTool/mapTool_v2.cfm
//
// DESCRIPTION:
// Display page for Google Maps V3 API
//
// AUTHOR:
// Steve 'Cutter' Blades (SGB), sbladesATdealerskinsDOTcom
//
// COPYRIGHT:
// Copyright (c) 2010 Dealerskins, Inc. All Rights Reserved.
//
// REVISION HISTORY:
//
// ******************************************************************************
// User: SGB  [Date: 12.02.10]
// Initial Creation
// ******************************************************************************
=========================================================================== --->

<cfparam name="REQUEST.pageWidth" default="#GetPage.PageWidth#" />
<cfparam name="VARIABLES.locList" default="" />
<cfparam name="REQUEST.mapWidth" default="830px" />
<cfparam name="REQUEST.locArr" default="#ArrayNew(1)#" />

<cfscript>
	// Set the pageWidth, and the mapWidth
	if((Right(REQUEST.pageWidth,1) neq "%") and isNumeric(REQUEST.pageWidth)){
		REQUEST.mapWidth = (REQUEST.pageWidth - 170) & "px";
		REQUEST.pageWidth = REQUEST.pageWidth & "px";
	}
	// Get all mapped locations for the site
	REQUEST.locs = CreateObject("component","cfc.MapTool").getGMapLocations(APPLICATION.SiteInfo.ID);
	// Turn the locations query into an array of structs
	for(REQUEST.i = 1;REQUEST.i <= REQUEST.locs.recordCount;REQUEST.i++){
		REQUEST["loc#REQUEST.i#"] = APPLICATION.CFC.CommonFunctions.QueryRowToStruct(REQUEST.locs,REQUEST.i);
		ArrayAppend(REQUEST.locArr,Duplicate(REQUEST["loc#REQUEST.i#"]));
	}
</cfscript>

<cfquery name="REQUEST.states" datasource="#APPLICATION.DSN.DS2#">
	SELECT		Abrv
	FROM		States
	ORDER BY	Abrv
</cfquery>

<cfoutput>
<div id="mapContainer">
	<div id="printLink">
		<cfif REQUEST.locs.recordcount gt 1><!--- For sites with more than one mapped location --->
			<select id="locID" name="locID">
				<cfloop query="REQUEST.locs">
					<option value="#REQUEST.locs.locationID#">#REQUEST.locs.tempsitename#</option>
				</cfloop>
			</select>
		</cfif>
  		<a href="javascript:window.print();">Print <img src="/images/print_icon.png" width="33" height="28" border="0"></a>
	</div>
    <div id="mapTitle">
		<a name="gMaps"></a>
		<b>Get Driving Directions</b>
    	<div id="mapBlurb">
			Use the form below to get direction from your location or select from the list of pre-loaded locations nearby.
        </div>
    </div>
</cfoutput>

<cfscript>
	REQUEST.attr = {};
	REQUEST.attr.width = REQUEST.mapWidth; // The width of the map
	REQUEST.attr.height = "500px"; // The height of the map
	REQUEST.attr.zoom = 12; // The zoom level of the map
	REQUEST.attr.mapDiv = "googlemapstag"; // The Html Element Id of the div for the map
	REQUEST.attr.directionsDiv = "dirDiv"; // The Html Element Id of the div for the map's directions
	REQUEST.attr.locArray = REQUEST.locArr; // The array of location structures
	REQUEST.attr.locArrayName = "_locArr"; // Unique JS var name for the location array
	REQUEST.attr.uniqueMapObj = "_cfGMapObj"; // Unique JS var name for this map instance
	REQUEST.attr.correctionCallback = "correctLocation"; // A JS callback function to correct locations that must be Geocoded
	REQUEST.attr.supportDir = "/Assets/MapTool/"; // Primary directory root for support assets (scripts and stylesheets)
	REQUEST.attr.additionalScript = "dsGMap.js"; // Additional script containing callback functions, custom form binding, etc.
	REQUEST.attr.stylesheet = "gMap.css"; // Associated stylesheet
	REQUEST.attr.printStylesheet = "gMapPrint.css"; // Associated print stylesheet
</cfscript>

<!--- Call for the Custom Tag --->
<cfimport taglib="/DSWebRoot/CustomTags/MapTool" prefix="ui">
<ui:googlemap_v3 attributeCollection="#REQUEST.attr#" />

<!--- Here's the form to get Driving Directions --->
<cfoutput>
	<div id="frmContainer">
		<div id="frmDiv">
			<form id="frmDir" name="frmDir">
				<table border="0">
				<tr>
					<td colspan="2" class="frmLabels">
						Street Address:
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input id="street" name="street" type="text" value="" size="18" />
					</td>
				</tr>
				<tr>
					<td colspan="2" class="frmLabels">
						City:
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<input  id="suburb" name="suburb" type="text" value="" size="18" />
					</td>
				</tr>
				<tr>
					<td width="69" class="frmLabels">
						State:
					</td>
					<td width="115" class="frmLabels">
						Zip:
					</td>
				</tr>
				<tr>
					<td>
						<select id="state" name="state" size="1">
							<cfloop query="REQUEST.states">
								<option<cfif REQUEST.states.Abrv eq APPLICATION.SiteInfo.State> selected="selected"</cfif>>#REQUEST.states.Abrv#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input id="zip" name="zip" type="text" value="" size="5" />
					</td>
				</tr>
				</table>
				<input type="button" id="updForm" name="updForm" value="Get Directions" />
			</form>
		</div>
		<!--- Here's a div for an additional locations list, that can plot directions --->
		<cfif ListLen(VARIABLES.locList)>
			<div id="locList">
				<b>Directions From:</b><br />
				<cfloop list="#VARIABLES.locList#" delimiters=";" index="REQUEST.lstIndex">
					<cfif ListLen(REQUEST.lstIndex,",") gt 1>
						<a href="http://maps.google.com">#REQUEST.lstIndex#</a><br />
					<cfelse>
						<a href="http://maps.google.com">#REQUEST.lstIndex#, #APPLICATION.SiteInfo.State#</a><br />
					</cfif>
				</cfloop>
			</div>
		</cfif>
	</div>
	<br clear="all" />
	<!--- And the Directions container --->
	<div id="dirDiv"></div>
</div>
</cfoutput>