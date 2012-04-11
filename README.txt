CFGMap is a ColdFusion custom tag implementation of Google's Maps v3 JavaScript API. 
Demo requires ColdFusion 8 or higher. Demo requires that this directoy (CFGMap) be 
the root directory of the site. If you choose to do otherwise, please update all 
pathing accordingly.

The Locations.cfc comes in two flavors: scripted and unscripted. The default (scripted)
version is for ColdFusion 9. Currently all calls will ultimately fail, as there is no
datasource. This component is for example only, of how a developer can use the geocoding
callback to database the Lat/Lng results for locations.

Further information can be found by reading the comments in the code, and through the 
blog entries:

http://www.cutterscrossing.com/index.cfm/CFGMap