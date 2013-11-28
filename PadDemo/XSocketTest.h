//
//  XSocketTest.h
//  MyFirstApp
//
//  Created by landyu on 9/19/13.
//  Copyright (c) 2013 landyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
@interface XSocketTest : NSObject

+(int) myConnect:(int *)pSocketFd pSocketAddr:(const struct sockaddr *)add socketLen:(socklen_t)length blockFlag:(BOOL)flag timeOut:(struct timeval *)pTimeOutVal;
+(BOOL) socketIsWriteable:(int *)pSocketFd timeOut:(struct timeval *)pTimeOutVal;
@end
