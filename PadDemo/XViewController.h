//
//  XViewController.h
//  PadDemo
//
//  Created by landyu on 11/26/13.
//  Copyright (c) 2013 landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <netinet/in.h>//sockaddr_in
#import "XTVBkLightViewController.h"

#define LTON YES
#define LTOFF NO

#define ACCE_SOCKETNUM 5

CGFloat phywidth;
CGFloat phyheight;



bool groundLightStatus;
unsigned int TVBkLightStatus;

int socketSer = -1;

@interface XViewController : UIViewController<AVAudioPlayerDelegate>
{
    
}
@property (retain, nonatomic) UILabel *lblGroundLight;
@property (retain, nonatomic) UIButton *buttonGroundLight;
@property (retain, nonatomic) UILabel *lblTVBkLight;
@property (retain, nonatomic) UIButton *buttonTVBkLight;
@property (retain, nonatomic) XTVBkLightViewController *tvBkLightVC;
//@property (retain, nonatomic) UITapGestureRecognizer *singleOne;

@end
