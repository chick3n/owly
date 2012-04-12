//
//  sqlite3_distance.c
//  myTranspoLib
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#include <sqlite3.h>
#include <math.h>

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
	// check that we have four arguments (lat1, lon1, lat2, lon2)
	//assert(argc == 4);
	if(argc != 4) return;
	
	// check that all four arguments are non-null
	if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
		sqlite3_result_null(context);
		return;
	}
	// get the four argument values
	double lat1 = sqlite3_value_double(argv[0]);
	double lon1 = sqlite3_value_double(argv[1]);
	double lat2 = sqlite3_value_double(argv[2]);
	double lon2 = sqlite3_value_double(argv[3]);
    
	// convert lat1 and lat2 into radians now, to avoid doing it twice below
	double stopLat = DEG2RAD(lat1);
	double userLat = DEG2RAD(lat2);
    double stopLon = DEG2RAD(lon1);
    double userLon = DEG2RAD(lon2);
    
    //printf("stop: %f %f user: %f %f\n", stopLat, stopLon, userLat, userLon);
    
	// apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
	// 6378.1 is the approximate radius of the earth in kilometres
	/*sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1);*/
    sqlite3_result_double(context
                          , (3959 *
                             acos( cos( userLat ) *
                             cos( stopLat ) *
                             cos( stopLon - userLon ) +
                             sin( userLat ) *
                             sin( stopLat ) ) )
                          );
}
