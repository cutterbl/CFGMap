<cfsetting enablecfoutputonly="true" />
<!--- ===========================================================================
// CLASS/COMPONENT:
// index.cfm
//
// DESCRIPTION:
// Example page for Google Maps V3 API, using the CFGMap CustomTag
//
// AUTHOR:
// Steve 'Cutter' Blades (SGB), cutterDOTblATcutterscrossing.comcom
//
// LICENSE:
// Apache Software Foundation's Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
// REVISION HISTORY:
//
// ******************************************************************************
// User: SGB  [Date: 12.03.10]
// Initial Creation
// ******************************************************************************
=========================================================================== --->

<cfscript>
	// We'll setup an array of locations for testing
	REQUEST.locArr = ArrayNew(1);
	REQUEST.loc1 = StructNew();
	REQUEST.loc1.locationID = 1;
	REQUEST.loc1.name = "B.B. Kings Blues Club";
	REQUEST.loc1.address1 = "152 2nd Avenue North";
	REQUEST.loc1.address2 = "";
	REQUEST.loc1.city = "Nashville";
	REQUEST.loc1.state = "TN";
	REQUEST.loc1.zip = "37201-1902";
	REQUEST.loc1.phone = "(615) 256-2727";
	REQUEST.loc1.latitude = "";
	REQUEST.loc1.longitude = "";
	REQUEST.loc1.primaryMarker = true;
	ArrayAppend(REQUEST.locArr,REQUEST.loc1);
	REQUEST.loc2 = StructNew();
	REQUEST.loc2.locationID = 2;
	REQUEST.loc2.name = "Bourbon Street Blues and Boogie Bar";
	REQUEST.loc2.address1 = "220 Printers Alley";
	REQUEST.loc2.address2 = "";
	REQUEST.loc2.city = "Nashville";
	REQUEST.loc2.state = "TN";
	REQUEST.loc2.zip = "37201-1403";
	REQUEST.loc2.phone = "(615) 242-5837";
	REQUEST.loc2.latitude = "";
	REQUEST.loc2.longitude = "";
	REQUEST.loc2.primaryMarker = false;
	ArrayAppend(REQUEST.locArr,REQUEST.loc2);
	REQUEST.loc3 = StructNew();
	REQUEST.loc3.locationID = 3;
	REQUEST.loc3.name = "3rd and Lindsley Bar & Grill";
	REQUEST.loc3.address1 = "818 3rd Ave. S.";
	REQUEST.loc3.address2 = "";
	REQUEST.loc3.city = "Nashville";
	REQUEST.loc3.state = "TN";
	REQUEST.loc3.zip = "37210";
	REQUEST.loc3.primaryMarker = false;
	REQUEST.loc3.phone = "(615) 259-9891";
	REQUEST.loc3.latitude = "";
	REQUEST.loc3.longitude = "";
	ArrayAppend(REQUEST.locArr,REQUEST.loc3);
	REQUEST.loc4 = StructNew();
	REQUEST.loc4.locationID = 4;
	REQUEST.loc4.name = "Mercy Loung";
	REQUEST.loc4.address1 = "One Cannery Row";
	REQUEST.loc4.address2 = "";
	REQUEST.loc4.city = "Nashville";
	REQUEST.loc4.state = "TN";
	REQUEST.loc4.zip = "37203";
	REQUEST.loc4.phone = "(615) 251-3020";
	REQUEST.loc4.latitude = "";
	REQUEST.loc4.longitude = "";
	REQUEST.loc4.primaryMarker = false;
	ArrayAppend(REQUEST.locArr,REQUEST.loc4);
	/*REQUEST.loc5 = StructNew();
	REQUEST.loc5.locationID = 5;
	REQUEST.loc5.name = "";
	REQUEST.loc5.address1 = "";
	REQUEST.loc5.address2 = "";
	REQUEST.loc5.city = "";
	REQUEST.loc5.state = "";
	REQUEST.loc5.zip = "";
	REQUEST.loc5.phone = "";
	REQUEST.loc5.latitude = "";
	REQUEST.loc5.longitude = "";
	REQUEST.loc5.primaryMarker = false;
	ArrayAppend(REQUEST.locArr,REQUEST.loc5);*/

	// You can also use Nathan Dintenfass' QueryRowToStruct() function to
	// convert queries into structs to append to the locArr
	// QueryRowToStruct() can be found at CFLib.org
	// http://cflib.org/index.cfm?event=page.udfbyid&udfid=358

	REQUEST.originState = "TN";
	REQUEST.locList = "Franklin;Brentwood;Gallatin;Mt. Juliet;Clarksville, KY";
</cfscript>

<cfoutput>
<!doctype html>
<html>
	<head>
		<meta charset="UTF-8" />
		<title>CFGMap Custom Tag - ColdFusion + Google Maps JavaScript API v3</title>
		<meta name="keywords" content="ColdFusion,Google Maps,Javascript,CFGMap" />
		<meta name="description" content="CFGMap is a ColdFusion custom tag for rendering Google Maps via it's v3 JavaScript API." />
		<meta name="author" content="Steve 'Cutter' Blades" />
		<meta name="copyright" content="(c)2010 - 2012 Stephen Blades" />
		<script type='text/javascript' src='/scripts/jquery-1.4.4.min.js'></script>
		<link rel="shortcut icon" href="/favicon_32x32.ico" />
	</head>
	<body>
		<div id="content">
		<p class="intro">
		<img src="/images/cfgmap-banner-535x160.png" alt="CFQueryReader Logo" style="width:535px;height:160px;border:0;" /><br /><br />
		<a href="https://github.com/cutterbl/CFGMap" target="_blank">CFGMap</a> is a ColdFusion Custom Tag, designed for implementing the <a href="http://cutterscrossing.com/index.cfm/cfgmap" target="_blank">Google Maps Javascript API</a> for map display. With only a few attributes (oulined in the comments of the custom tag), a developer can quickly and easily render multiple locations with Google Maps. With a little scripting, a developer can also perform basic functions, like asking for directions or showing quick routes from various locations. There is even the ability to define a callback method, once all locations are geocoded, to pass the location data back to your server for archive. The below example (inluded in the <a href="" target="_blank">download</a>) shows you CFGMap in action.</p>
		<div id="mapContainer">
			<div id="printLink">
				<cfif ArrayLen(REQUEST.locArr) gt 1><!--- For sites with more than one mapped location --->
					<select id="locID" name="locID">
						<cfloop array="#REQUEST.locArr#" index="REQUEST.i">
							<option value="#REQUEST.i.locationID#">#REQUEST.i.name#</option>
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
	REQUEST.attr.width = "85%"; // The width of the map
	REQUEST.attr.height = "500px"; // The height of the map
	REQUEST.attr.zoom = 14; // The zoom level of the map
	REQUEST.attr.mapDiv = "googlemapstag"; // The Html Element Id of the div for the map
	REQUEST.attr.directionsDiv = "dirDiv"; // The Html Element Id of the div for the map's directions
	REQUEST.attr.locArray = REQUEST.locArr; // The array of location structures
	REQUEST.attr.locArrayName = "_locArr"; // Unique JS var name for the location array
	REQUEST.attr.uniqueMapObj = "_cfGMapObj"; // Unique JS var name for this map instance
	REQUEST.attr.correctionCallback = "correctLocation"; // A JS callback function to correct locations that must be Geocoded
	REQUEST.attr.supportDir = "/"; // Primary directory root for support assets (scripts and stylesheets)
	REQUEST.attr.additionalScript = "testmap.js"; // Additional script containing callback functions, custom form binding, etc.
	REQUEST.attr.stylesheet = "gMap.css"; // Associated stylesheet
	REQUEST.attr.printStylesheet = "gMapPrint.css"; // Associated print stylesheet
</cfscript>

<!--- Call for the Custom Tag --->
<cfimport taglib="/CustomTags" prefix="ui">
<ui:cfgmap attributeCollection="#REQUEST.attr#" />

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
									<option selected="selected" value="TN">TN</option>
									<!--- Normally you'd populate this with a query --->
									<!---<cfloop query="REQUEST.states">
										<option<cfif REQUEST.states.Abrv eq APPLICATION.SiteInfo.State> selected="selected"</cfif>>#REQUEST.states.Abrv#</option>
									</cfloop>--->
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
				<cfif ListLen(REQUEST.locList)>
					<div id="locList">
						<b>Directions From:</b><br />
						<cfloop list="#REQUEST.locList#" delimiters=";" index="REQUEST.lstIndex">
							<cfif ListLen(REQUEST.lstIndex,",") gt 1>
								<a href="http://maps.google.com">#REQUEST.lstIndex#</a><br />
							<cfelse>
								<a href="http://maps.google.com">#REQUEST.lstIndex#, #REQUEST.originState#</a><br />
							</cfif>
						</cfloop>
					</div>
				</cfif>
			</div>
			<br clear="all" />
			<!--- And the Directions container --->
			<div id="dirDiv"></div>
		</div>
		</div>
	</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false" />