//
//  XSocketTest.m
//  MyFirstApp
//
//  Created by landyu on 9/19/13.
//  Copyright (c) 2013 landyu. All rights reserved.
//

#import "XSocketTest.h"
#import <netinet/in.h>//sockaddr_in
#import <arpa/inet.h>//inet_addr()
#import <unistd.h>
#import <sys/ioctl.h>

@implementation XSocketTest


+(int) myConnect:(int *)pSocketFd pSocketAddr:(const struct sockaddr *)add socketLen:(socklen_t)length blockFlag:(BOOL)flag timeOut:(struct timeval *)pTimeOutVal
{
    BOOL connSucc = NO;
    
    if (-1 == *pSocketFd) {
        return -1;
    }
    
    if (NO == flag)
    {
       // NSLog(@"1111211111");
        int cntlRet = fcntl(*pSocketFd, F_GETFL, 0);
        
        if (cntlRet < 0) {
            NSLog(@"get socket flags fail.\n");
            close(*pSocketFd);
            *pSocketFd = -1;
            return -1;
        }
        
        if (fcntl(*pSocketFd, F_SETFL, cntlRet | O_NONBLOCK) < 0) {
            NSLog(@"set socket O_NONBLOCK fail.\n");
            close(*pSocketFd);
            *pSocketFd = -1;
            return -1;
        }

    }
    
    
    int retConn = connect(*pSocketFd, add, length);

     if (NO == flag)
     {
         if (-1 == retConn)
         {
             //链接失败
             fd_set set;
             FD_ZERO(&set);
             FD_SET(*pSocketFd, &set);
             
             int ret = select(*pSocketFd+1, NULL, &set, NULL, pTimeOutVal);
            
             if (ret > 0 &&  FD_ISSET(*pSocketFd, &set)) {
                 int error = 0;
                 unsigned int sockLen = 4;//SOCKET长度为INT （4）,不能填错，重要！！！
                 getsockopt(*pSocketFd, SOL_SOCKET, SO_ERROR, &error, &sockLen);
                 
                 if (0 == error)
                 {
                     connSucc = YES;
                 }
                 
             }
             else if(ret ==0)
             {
                 NSLog(@"timeout !!!\n");
             }
             
             

         
         }
    
         int cntlRet = fcntl(*pSocketFd, F_GETFL,0);
         cntlRet &= ~O_NONBLOCK;
         fcntl(*pSocketFd,F_SETFL,cntlRet);
         if (NO == connSucc)
            return -1;

     }
    
    return 0;
    
}

+(BOOL) socketIsWriteable:(int *)pSocketFd timeOut:(struct timeval *)pTimeOutVal
{
    //int socketFd = *pSocketFd;
    
    if (-1 == *pSocketFd) {
        return NO;
    }
    
//    int cntlRet = fcntl(*pSocketFd, F_GETFL, 0);
//    
//    if (cntlRet < 0) {
//        NSLog(@"get socket flags fail.\n");
//        close(*pSocketFd);
//        *pSocketFd = -1;
//        return NO;
//    }
//    
//    if (fcntl(*pSocketFd, F_SETFL, cntlRet | O_NONBLOCK) < 0) {
//        NSLog(@"set socket O_NONBLOCK fail.\n");
//        close(*pSocketFd);
//        *pSocketFd = -1;
//        return NO;
//    }
//    
    //int err = errno;
    //const char* strErr = strerror(err);
    
    fd_set set;
    FD_ZERO(&set);
    FD_SET(*pSocketFd, &set);
    
    int ret = select(*pSocketFd+1, NULL, &set, NULL, pTimeOutVal);
    //int err2 = errno;
    if (ret > 0 &&  FD_ISSET(*pSocketFd, &set)) {
        int error = 0;
        unsigned int sockLen = 4;//SOCKET长度为INT （4）,不能填错，重要！！！
        getsockopt(*pSocketFd, SOL_SOCKET, SO_ERROR, &error, &sockLen);
        
        if (0 != error)
        {
            return NO;
        }
        
    }
    else if(ret ==0)
    {
        NSLog(@"timeout !!!\n");
        return  NO;
    }
    
//    cntlRet = fcntl(*pSocketFd, F_GETFL,0);
//    cntlRet &= ~O_NONBLOCK;
//    fcntl(*pSocketFd,F_SETFL,cntlRet);
    
    return YES;


}


@end
