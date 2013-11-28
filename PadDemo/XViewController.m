//
//  XViewController.m
//  PadDemo
//
//  Created by landyu on 11/26/13.
//  Copyright (c) 2013 landyu. All rights reserved.
//

#import <arpa/inet.h>
#import "XViewController.h"
#import "XSocketTest.h"

@interface XViewController ()

@end

@implementation XViewController

- (void)viewDidLoad
{
    struct sockaddr_in address, remoteHost;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    groundLightStatus = LTOFF;
    TVBkLightStatus = 0;
    _tvBkLightVC = nil;
    
    //NSLog(@"server host = %@ port = %@", servHost, servPort);
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    phywidth = size.width;
    phyheight = size.height;
    
    NSLog(@"phywidth = %f  phyheight = %f", phywidth, phyheight);
    //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"homeDemo.png"]];
    //self.view.backgroundColor = background;
    
    UIImage *image = [UIImage imageNamed:@"homeDemo.png"];
    self.view.layer.contents = (id) image.CGImage;
    
    
//    _singleOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleOne:)];
//    _singleOne.numberOfTouchesRequired = 1;    //触摸点个数，另作：[_singleOne setNumberOfTouchesRequired:1];
//    _singleOne.numberOfTapsRequired = 1;    //点击次数，另作：[_singleOne setNumberOfTapsRequired:1];
    
    _buttonGroundLight = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonGroundLight setImage:[UIImage imageNamed:@"darkbulb.png"] forState:UIControlStateNormal];
    [_buttonGroundLight addTarget:self action:@selector(buttonGroundLightClicked:) forControlEvents:UIControlEventTouchUpInside];
  //  [buttonGroundLight setTitle:@"ON" forState:UIControlStateNormal];
    _buttonGroundLight.frame = CGRectMake(400.0, 360.0, 40.0, 40.0);//width and height should be same value
    _buttonGroundLight.clipsToBounds = YES;
    
    _buttonGroundLight.layer.cornerRadius = 20;//half of the width
    _buttonGroundLight.layer.borderColor=[UIColor clearColor].CGColor;
    _buttonGroundLight.layer.borderWidth=2.0f;
    _buttonGroundLight.tag = 0;
    
    _buttonTVBkLight = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonTVBkLight setImage:[UIImage imageNamed:@"darkbulb.png"] forState:UIControlStateNormal];
    [_buttonTVBkLight addTarget:self action:@selector(buttonTVBkLightClicked:) forControlEvents:UIControlEventTouchUpInside];
    //  [buttonGroundLight setTitle:@"ON" forState:UIControlStateNormal];
    _buttonTVBkLight.frame = CGRectMake(540.0, 410.0, 40.0, 40.0);//width and height should be same value
    _buttonTVBkLight.clipsToBounds = YES;
    
    _buttonTVBkLight.layer.cornerRadius = 20;//half of the width
    _buttonTVBkLight.layer.borderColor=[UIColor clearColor].CGColor;
    _buttonTVBkLight.layer.borderWidth=2.0f;
    _buttonTVBkLight.tag = 1;
    
    _lblGroundLight = [[UILabel alloc]initWithFrame:CGRectMake(390, 345, 70, 15)];
    _lblGroundLight.text = @"落地灯";
    _lblGroundLight.textAlignment = NSTextAlignmentCenter;
    _lblGroundLight.textColor = [UIColor blackColor];
    _lblGroundLight.backgroundColor = [UIColor clearColor];
    
    _lblTVBkLight = [[UILabel alloc]initWithFrame:CGRectMake(530, 395, 90, 15)];
    _lblTVBkLight.text = @"电视背景灯";
    _lblTVBkLight.textAlignment = NSTextAlignmentCenter;
    _lblTVBkLight.textColor = [UIColor blackColor];
    _lblTVBkLight.backgroundColor = [UIColor clearColor];

    
    [self.view addSubview:_buttonGroundLight];
    [self.view addSubview:_buttonTVBkLight];
    [self.view addSubview:_lblGroundLight];
    [self.view addSubview:_lblGroundLight];
    [self.view addSubview:_lblTVBkLight];
    
    //[self.view addGestureRecognizer:_singleOne];
    
//    if ( (socketSer = socket(AF_INET, SOCK_STREAM, 0)) < 0)
//    {
//        NSLog(@"can not ceat soket");
//        return;
//    }
//    
//    address.sin_family = AF_INET;
//    address.sin_port = htonl(5080);
//    address.sin_addr.s_addr = INADDR_ANY;
//    
//    if (bind(socketSer, (struct sockaddr *)&address, sizeof(address)) < 0) {
//        NSLog(@"can not bind socket");
//        return;
//    }
//    
//    listen(socketSer, ACCE_SOCKETNUM);



    
    //[background release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)buttonGroundLightClicked:(id)sender
{

    [self playClickSound];
    int m_fd = -1;
    NSString * servHost = @"192.168.18.10";
    NSString * servPort = @"5088";
    struct sockaddr_in socketParameters;
    m_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == m_fd)
    {
        NSLog(@"Failed to create socket.");
        return ;
    }
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr.s_addr = inet_addr([servHost UTF8String]);
    socketParameters.sin_port = htons([servPort intValue]);
    
    
    struct timeval  connTimeout;
    connTimeout.tv_sec = 5;
    connTimeout.tv_usec = 0;
    int ret = [XSocketTest myConnect:&m_fd pSocketAddr:(const struct sockaddr *)&socketParameters socketLen:sizeof(socketParameters) blockFlag:NO timeOut:&connTimeout];
    
    if (-1 == ret)
    {
        NSLog(@"connect failed !!!!!");
        close(m_fd);
        m_fd = -1;
        return;
    }

    
    if (groundLightStatus == LTOFF) {
        [_buttonGroundLight setImage:[UIImage imageNamed:@"lightbulb.png"] forState:UIControlStateNormal];
        groundLightStatus = LTON;
        
        NSData* req_data =[[NSData alloc]initWithData:[@"{\"type\":\"EIBS\",\"addr\":\"0/0/1\",\"value\":1}" dataUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"reqPak len = %lu", (unsigned long)[req_data length]);
        //char jasonHeader[16] = {'\r','\n','\r','\n',0,0,0,0,[req_data length],0,0,0,'\a','\f','\a','\f'};
        //NSMutableData * reqPak = [[[NSMutableData alloc] initWithBytes: jasonHeader length:16]autorelease];
        NSString *reqDataHeadStr = [NSString stringWithFormat:@"$packagelen=%d$", [req_data length]];
        NSData* reqDataHead = [[NSData alloc]initWithData:[reqDataHeadStr dataUsingEncoding:NSUTF8StringEncoding]];
        //NSMutableData * reqPak = [[[NSMutableData alloc] initWithBytes: jasonHeader length:16]autorelease];
        NSMutableData * reqPak = [[NSMutableData alloc] initWithData:reqDataHead];
        
        [reqPak appendData:req_data];
        
        
        
        int ret = send(m_fd, [reqPak bytes], [reqPak length], 0);
        if (ret < 0)
        {
            NSLog(@"send data error!");
            return;
        }

    }
    else if(groundLightStatus == LTON)
    {
        [_buttonGroundLight setImage:[UIImage imageNamed:@"darkbulb.png"] forState:UIControlStateNormal];
        groundLightStatus = LTOFF;
        
        NSData* req_data =[[NSData alloc]initWithData:[@"{\"type\":\"EIBS\",\"addr\":\"0/0/1\",\"value\":0}" dataUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"reqPak len = %lu", (unsigned long)[req_data length]);
        //char jasonHeader[16] = {'\r','\n','\r','\n',0,0,0,0,[req_data length],0,0,0,'\a','\f','\a','\f'};
        //NSMutableData * reqPak = [[[NSMutableData alloc] initWithBytes: jasonHeader length:16]autorelease];
        NSString *reqDataHeadStr = [NSString stringWithFormat:@"$packagelen=%d$", [req_data length]];
        NSData* reqDataHead = [[NSData alloc]initWithData:[reqDataHeadStr dataUsingEncoding:NSUTF8StringEncoding]];
        //NSMutableData * reqPak = [[[NSMutableData alloc] initWithBytes: jasonHeader length:16]autorelease];
        NSMutableData * reqPak = [[NSMutableData alloc] initWithData:reqDataHead];
        
        [reqPak appendData:req_data];
        
        
        
        int ret = send(m_fd, [reqPak bytes], [reqPak length], 0);
        if (ret < 0)
        {
            NSLog(@"send data error!");
            return;
        }

    }
    
    close(m_fd);
    m_fd = -1;
    
}

- (void)buttonTVBkLightClicked:(id)sender
{
    
    [self playClickSound];
    if (_tvBkLightVC == nil)
    {
        _tvBkLightVC = [[XTVBkLightViewController alloc] init];
        _tvBkLightVC.view.frame = CGRectMake(phywidth/2.0 - 150.0/2.0, phyheight/2.0 - 400.0/2.0, 400, 150);
        _tvBkLightVC.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_tvBkLightVC.view];
    }
    
//    if (TVBkLightStatus > 0) {
//        [_buttonTVBkLight setImage:[UIImage imageNamed:@"lightbulb.png"] forState:UIControlStateNormal];
//        //TVBkLightStatus = 1;
//    }
//    else if(TVBkLightStatus == 0)
//    {
//        [_buttonTVBkLight setImage:[UIImage imageNamed:@"darkbulb.png"] forState:UIControlStateNormal];
//        //TVBkLightStatus = 0;
//    }
}

//- (void) singleOne:(UITapGestureRecognizer *)recognizer
//{
//    //CGPoint location = [recognizer locationInView:self];
//    //if (location.x) {
//   //     <#statements#>
//   // }
//    //NSLog(@"x = %f  y = %f",location.x, location.y);
//    [self playClickSound];
//    NSLog(@"singleOne");
//}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //CGPoint touchPoint = [touch locationInView:[touch view]];//获取坐标相对于当前视图
    CGPoint touchPoint = [touch locationInView:self.view];//获取视图坐标相对于父视图与子视图无关
    //touchPoint.x ，touchPoint.y 就是触点的坐标。
//   NSLog(@"x = %f  y = %f",touchPoint.x, touchPoint.y);
    CGRect curRect = _tvBkLightVC.view.frame;
//    NSLog(@"curRect.origin.x = %f  curRect.origin.y = %f curRect.size.height = %f curRect.size.width = %f",curRect.origin.x, curRect.origin.y, curRect.size.height, curRect.size.width);
  //  curRect.origin.x
    if ([self isInThisRectWithRectOrigX:curRect.origin.x rectOrigY:curRect.origin.y rectSizeH:curRect.size.height rectSizeW:curRect.size.width pointX:touchPoint.x pointY:touchPoint.y])
    {
        //NSLog(@"This point is within area!!");
    }
    else
    {
        if (_tvBkLightVC != nil) {
            [self playClickSound];
            //[self.view rem];
            [_tvBkLightVC.view removeFromSuperview];
            _tvBkLightVC = nil;
            //removeFromSuperview
        }
        //NSLog(@"This point is not within area!!");
    }
    
    //NSLog(@"touchesBegan");
    
}


- (void) playClickSound
{
    CFBundleRef mainbundle=CFBundleGetMainBundle();
    SystemSoundID soundFileObject;
    //获得声音文件URL
    CFURLRef soundfileurl=CFBundleCopyResourceURL(mainbundle,CFSTR("click1"),CFSTR("mp3"),NULL);
    //创建system sound 对象
    AudioServicesCreateSystemSoundID(soundfileurl, &soundFileObject);
    //播放
    AudioServicesPlaySystemSound(soundFileObject);
}

- (BOOL) isInThisRectWithRectOrigX:(float)origX rectOrigY:(float)origY rectSizeH:(float)sizeH rectSizeW:(float)sizeW pointX:(float)ptX pointY:(float)ptY
{
    if ((ptX > origX) && (ptX < (origX + sizeW)) && (ptY > origY) && (ptY < (origY + sizeH))) {
        
        return YES;
    }
    
    return NO;
}


@end
