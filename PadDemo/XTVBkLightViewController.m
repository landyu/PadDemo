//
//  XTVBkLightViewController.m
//  PadDemo
//
//  Created by landyu on 11/27/13.
//  Copyright (c) 2013 landyu. All rights reserved.
//

#import <arpa/inet.h>
#import "XTVBkLightViewController.h"
#import "XSocketTest.h"

@interface XTVBkLightViewController ()

@end

@implementation XTVBkLightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
     NSLog(@"%@", NSStringFromSelector(_cmd));
    return self;
}
int m_fd = -1;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     NSLog(@"%@", NSStringFromSelector(_cmd));
    //CGRect workSpaceRect = [[UIScreen mainScreen]applicationFrame];
    //CGRect curRect = self.view.frame;
    //NSLog(@"%@", NSStringFromCGRect(workSpaceRect));
    //NSLog(@"%@", NSStringFromCGRect(curRect));
    NSString * servHost = @"192.168.18.10";
    NSString * servPort = @"5088";
    
    m_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == m_fd)
    {
        NSLog(@"Failed to create socket.");
        return ;
    }
    struct sockaddr_in socketParameters;
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

    
    
    _lblTVBkLightVCTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 400, 30)];
    _lblTVBkLightVCTitle.backgroundColor = [UIColor greenColor];
    _lblTVBkLightVCTitle.text = @"电视背景灯";
    _lblTVBkLightVCTitle.textAlignment = NSTextAlignmentCenter;
    _lblTVBkLightVCTitle.textColor = [UIColor whiteColor];
    
    _lblTVBkLightVCSlider = [[UILabel alloc]initWithFrame:CGRectMake(5, 75, 110, 30)];
    _lblTVBkLightVCSlider.text = @"电视背景灯";
    _lblTVBkLightVCSlider.textAlignment = NSTextAlignmentCenter;
    _lblTVBkLightVCSlider.textColor = [UIColor blackColor];
    _lblTVBkLightVCSlider.backgroundColor = [UIColor clearColor];
    

    
    _sldTVBkLight = [[UISlider alloc]initWithFrame:CGRectMake(115, 75, 350-115, 30)];
    [_sldTVBkLight addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [_sldTVBkLight setBackgroundColor:[UIColor clearColor]];
    _sldTVBkLight.minimumValue = 0;
    _sldTVBkLight.maximumValue = 100;
    _sldTVBkLight.continuous = YES;
    _sldTVBkLight.value = (int)(preprogressAsInt*100.0)/255;
    //NSLog(@"preprogressAsInt = %d", preprogressAsInt);
    //_sldTVBkLight.backgroundColor = [UIColor grayColor];
    
    _lblTVBkLightVCSliderValue = [[UILabel alloc]initWithFrame:CGRectMake(350, 75, 50, 30)];
    _lblTVBkLightVCSliderValue.text = [NSString stringWithFormat:@"%d%%",(int)_sldTVBkLight.value+1];
    _lblTVBkLightVCSliderValue.textAlignment = NSTextAlignmentCenter;
    _lblTVBkLightVCSliderValue.textColor = [UIColor blackColor];
    _lblTVBkLightVCSliderValue.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_lblTVBkLightVCTitle];
    [self.view addSubview:_lblTVBkLightVCSlider];
    [self.view addSubview:_lblTVBkLightVCSliderValue];
    [self.view addSubview:_sldTVBkLight];
    
    
    
    
}

- (void)dealloc
{
     NSLog(@"%@", NSStringFromSelector(_cmd));
    close(m_fd);
    m_fd = -1;
    
}
//
//- (void)viewWillDisappear
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}
//
//- (void)viewDidDisappear
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
     NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void) sliderAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    int progressAsInt = (int)roundf(slider.value);
    if (preprogressAsInt == (255.0/100.0)*progressAsInt) {
        return;
    }
    preprogressAsInt =(255.0/100.0)*progressAsInt;
    NSString *lV =  [NSString stringWithFormat:@"%d%%", progressAsInt];
    _lblTVBkLightVCSliderValue.text = lV;
    
    NSString *req_str = [NSString stringWithFormat:@"{\"type\":\"EIBV\",\"addr\":\"0/0/8\",\"value\":%d}", preprogressAsInt];
    NSData* req_data =[[NSData alloc]initWithData:[req_str dataUsingEncoding:NSUTF8StringEncoding]];
    //NSData* req_data =[[[NSData alloc]initWithData:[@"{\"type\":\"EIBS\",\"addr\":\"0/0/0\",\"value\":0}" dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    //NSLog(@"%@  length = %d", req_data, [req_data length]);
    //char jasonHeader[16] = {'\r','\n','\r','\n',0,0,0,0,[req_data length],0,0,0,'\a','\f','\a','\f'};
    NSString *reqDataHeadStr = [NSString stringWithFormat:@"$packagelen=%d$", [req_data length]];
    NSData* reqDataHead = [[NSData alloc]initWithData:[reqDataHeadStr dataUsingEncoding:NSUTF8StringEncoding]];
    //NSMutableData * reqPak = [[[NSMutableData alloc] initWithBytes: jasonHeader length:16]autorelease];
    NSMutableData * reqPak = [[NSMutableData alloc] initWithData:reqDataHead];
    
    [reqPak appendData:req_data];
    //[reqPak appendBytes:req_data length:[req_data length]];
    //int ret = send(m_fd, [req_data bytes], [req_data length], 0);
    int ret = send(m_fd, [reqPak bytes], [reqPak length], 0);
    if (ret < 0)
    {
        NSLog(@"send data error!");
        return;
    }

    
    
}

@end
