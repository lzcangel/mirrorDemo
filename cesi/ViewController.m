//
//  ViewController.m
//  cesi
//
//  Created by T.Y on 15-2-24.
//  Copyright (c) 2015年 GL_RunMan. All rights reserved.
//  如有Bug请联系我：QQ2018338874 先锋科技

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>
#import <GL_projection/GL_Video.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession* captureSession;
    AVCaptureConnection *videoConnection;
    CMBufferQueueRef previewBufferQueue;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAndStartCaptureSession];
    //    保持手机与播放器在同一网络，启动后用流媒体播放器（比如vlc），访问屏幕上显示的地址
    [[GL_Video shareInstance] startVideo];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    /*We release some components*/
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    /*We display the result on the custom layer*/
    /*self.customLayer.contents = (id) newImage;*/
    
    /*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly)*/
    UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    /*We relase the CGImageRef*/
    CGImageRelease(newImage);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTheImageView:image];
    });
}

-(void)setTheImageView:(UIImage*)image
{
    [_imageView setImage:image];
}


/////////////////////////////////////////////////////////////////
//
- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL) setupCaptureSession
{
    /* Create capture session */
    captureSession = [[AVCaptureSession alloc] init];
    
    /* Create video connection */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
    
    if ([captureSession canAddInput:videoIn]) {
        [captureSession addInput:videoIn];
    }
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    /* Processing can take longer than real-time on some platforms.
     Clients whose image processing is faster than real-time should consider
     setting AVCaptureVideoDataOutput's alwaysDiscardsLateVideoFrames property
     to NO.
     */
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings: @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
//    dispatch_release(videoCaptureQueue);
    
    if ([captureSession canAddOutput:videoOut]) {
        [captureSession addOutput:videoOut];
    }
    
    videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    return YES;
}


/////////////////////////////////////////////////////////////////
//
- (void) setupAndStartCaptureSession
{
    // Create a shallow queue for buffers going to the display for preview.
    OSStatus err = CMBufferQueueCreate(
                                       kCFAllocatorDefault,
                                       1,
                                       CMBufferQueueGetCallbacksForUnsortedSampleBuffers(),
                                       &previewBufferQueue);
    
    if (err)
    {
        NSLog(@"sorry error");
    }
    
    if (!captureSession) {
        [self setupCaptureSession];
    }
    
    if (!captureSession.isRunning) {
        [captureSession startRunning];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
