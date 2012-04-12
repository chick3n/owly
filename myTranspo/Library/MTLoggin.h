//
//  MTLoggin.h
//  myTranspoOC
//
//  Created by Vincent Mancini on 12-03-10.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#ifndef myTranspoOC_MTLoggin_h
#define myTranspoOC_MTLoggin_h

#ifndef MTDEBUG_LOGGING
#define MTLog(format, args...) NSLog(format, ## args)
#else
#define MTLog(format, args...) NSLog(format, ## args)
#endif

#endif
