/**
 *	===========================================================================
 *	CLASS/COMPONENT:
 *	Locations.cfc
 *
 *	DESCRIPTION:
 *	Example component for ajax callback to correct lat/lng location information
 *	after being Geocoded by Google's JS Map API
 *
 *	AUTHOR:
 *	Steve 'Cutter' Blades (SGB), cutterDOTblATcutterscrossingDOTcom
 *
 *	REVISION HISTORY:
 *	***************************************************************************
 *	C [04.11.2012]
 *	Refactor as a scripted component
 *	***************************************************************************
 *	SGB  [12.03.10]
 *	Initial Creation
 *	None of this works, because no datasource is set
 *	===========================================================================
 *
 *	@name Entries
 *	@displayName Blog Entries
 *	@output false
 */
component {

	VARIABLES.dsn = "";

	/**
	 *	FUNCTION correctLocsLatLng
	 *	A function to get paging query of blog entries for layout in jqGrid
	 *	A function taking an array of locations to 'fix' with new lat/lng data.
	 *	Takes a JSON object, an array of objects, and converts it to native CF
	 *	datatypes before looping each array item for processing.
	 *
	 *	@access remote
	 *	@returnType struct
	 *	@output false
	 */
	function correctLocsLatLng(required string corrArr) {
		LOCAL.retVal = {'success' = true, 'message' = ''};
		if(IsJSON(ARGUMENTS.corrArr)) {
			LOCAL.set = DeserializeJSON(ARGUMENTS.corrArr);
		} else {
			LOCAL.retVal = {'success' = false, 'message' = 'The argument passed is not valid JSON.'};
		}
		try {
			for(LOCAL.i = 1; LOCAL.i <= ArrayLen(LOCAL.set); LOCAL.i++) {
				LOCAL.try = setGMapLatLng(argumentCollection:LOCAL.set[LOCAL.i]);
				if(!LOCAL.try.success) {
					throw(type = "custom_map_error", errorcode = "cme_01", detail = SerializeJSON({'location' = LOCAL.set[LOCAL.i]}), message = LOCAL.try.message);
				}
			}
		} catch(any err) {
			LOCAL.retVal = {'success' = false, 'message' = err.message, 'detail' = DeserializeJSON(err.detail), 'errorcode' = err.errorcode};
			// Add any error logging and admin notifications
		}
		return LOCAL.retVal;
	}

	/**
	 *	FUNCTION setGMapLatLng
	 *	Updates the lat/lng info in a record of a specific location
	 *
	 *	@access private
	 *	@returnType struct
	 *	@output false
	 */
	function setGMapLatLng(required numeric locId, required numeric lat, required numeric lng) {
		LOCAL.retVal = {'success' = true, 'message' = ''};
		// Main data query
		LOCAL.sql = "UPDATE	Location
					SET Latitude = :lat,
					 	Longitude = :lng
					 WHERE	ID = :locId";
		LOCAL.q = new Query(sql = LOCAL.sql, datasource = VARIABLES.dsn);
		LOCAL.q.addParam(name = "locId", value = ARGUMENTS.locId, cfsqltype = "cf_sql_integer");
		LOCAL.q.addParam(name = "lat", value = ARGUMENTS.lat, cfsqltype = "cf_sql_integer");
		LOCAL.q.addParam(name = "lng", value = ARGUMENTS.lng, cfsqltype = "cf_sql_integer");
		try {
			LOCAL.q.execute();
		} catch(any err) {
			LOCAL.retVal = {'success' = false, 'message' = 'We were unable to set the LatLng for Location: #ARGUMENTS.locId# at this time.'};
			// Add any error logging and admin notifications
		}
		return LOCAL.retVal;
	}

}