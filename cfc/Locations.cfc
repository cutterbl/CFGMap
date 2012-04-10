<!--- ===========================================================================
// CLASS/COMPONENT:
// Locations.cfc
//
// DESCRIPTION:
// Example component for ajax callback to correct lat/lng location information
// after being Geocoded by Google's JS Map API
//
// AUTHOR:
// Steve 'Cutter' Blades (SGB), cutterDOTblATcutterscrossingDOTcom
//
// REVISION HISTORY:
//
// ******************************************************************************
// User: SGB  [Date: 12.03.10]
// Initial Creation
// None of this works, because no datasource is set
// ******************************************************************************
=========================================================================== --->

<cfcomponent displayname="Locations">
	<cfset VARIABLES.DSN = "" />

	<!---
	 //	FUNCTION: correctLocsLatLng(corrArr:string):struct
	 //
	 //	DESCRIPTION:
	 //	A function taking an array of locations to 'fix' with new lat/lng data.
	 // Takes a JSON object, an array of objects, and converts it to native CF
	 //	datatypes before looping each array item for processing.
	 //
	 //	ARGUMENTS:
	 //	corrArr:string		A JSON object (an array of objects [{locId,lat,lng}])
	 //
	 // RETURN:
	 // LOCAL.ret			{success:boolean,message?:string}
	 --->
	<cffunction name="correctLocsLatLng" access="remote" returntype="struct">
		<cfargument name="corrArr" type="string" required="true" />
		<cfset var LOCAL = StructNew() />
		<cfset LOCAL.ret = StructNew() />
		<cfset LOCAL.ret['success'] = true />
		<cfset LOCAL.set = DeserializeJson(ARGUMENTS.corrArr,true) />
		<cftry>
			<cfloop array="#LOCAL.set#" index="LOCAL.i">
				<cfset LOCAL.try = setGMapLatLng(argumentCollection:LOCAL.i) />
				<cfif not LOCAL.try.success>
					<cfthrow type="Custom_DS" errorcode="LOCAL.i.locId" message="#LOCAL.try.message#" />
				</cfif>
			</cfloop>
			<cfcatch type="any">
				<cfset LOCAL.ret['success'] = false />
				<cfset LOCAL.ret['message'] = CFCATCH.Message />
				<cfreturn LOCAL.ret />
			</cfcatch>
		</cftry>
		<cfreturn LOCAL.ret />
	</cffunction>

	<!---
	//	FUNCTION: setGMapLatLng(locId:numeric,lat:numeric,lng:numeric):struct
	//
	//	DESCRIPT:
	//	Updates the lat/lng info in a record of a specific location
	//
	//	ARGUMENTS:
	//	locId:numeric		Location ID
	//	lat:numeric			Location's Latitude
	//	lng:numeric			Location's Longitude
	//
	//	RETURN:
	//	LOCAL.ret:struct	{success:boolean,message?:string}
	 --->
	<cffunction name="setGMapLatLng" access="remote" returntype="struct">
		<cfargument name="locId" type="numeric" required="true" />
		<cfargument name="lat" type="numeric" required="true" />
		<cfargument name="lng" type="numeric" required="true" />
		<cfset var LOCAL = StructNew() />
		<cfset LOCAL.ret = StructNew() />
		<cfset LOCAL.ret['success'] = true />
		<cftry>
			<cfquery name="setLatLng" datasource="#VARIABLES.DS2#">
				UPDATE	Location
				SET		Latitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.lat#" />,
						Longitude = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARGUMENTS.lng#" />
				WHERE	ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.locId#" />
			</cfquery>
			<cfcatch type="any">
				<cfset LOCAL.ret['success'] = false />
				<cfset LOCAL.ret['message'] = "We were unable to set the LatLng for Location: #ARGUMENTS.locId# at this time." />
				<!--- put Error Handling call here --->
			</cfcatch>
		</cftry>
		<cfreturn LOCAL.ret />
	</cffunction>
</cfcomponent>
