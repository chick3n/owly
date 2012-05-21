//
//  7zIn.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#ifndef myTranspo__zIn_h
#define myTranspo__zIn_h

void SzFolder_Free(CSzFolder *p, ISzAlloc *alloc);
int SzFolder_FindBindPairForOutStream(CSzFolder *p, UInt32 outStreamIndex);

#endif
