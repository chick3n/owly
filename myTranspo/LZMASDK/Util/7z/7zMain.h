//
//  7zMain.h
//  myTranspo
//
//  Created by Vincent Mancini on 12-05-21.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#ifndef myTranspo__zMain_h
#define myTranspo__zMain_h

void PrintError(char *sz);
int MY_CDECL unused_main(int numargs, char *args[]);
int do7z_extract_entry(char *archivePath, char *entryName, char *entryPath);

#endif
