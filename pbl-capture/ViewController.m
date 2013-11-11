//
//  ViewController.m
//  pbl-capture
//
//  Created by Edward Patel on 2013-07-20.
//  Copyright (c) 2013 Memention AB. All rights reserved.
//

#import "ViewController.h"

#include "status-bar.h"

@interface ViewController () {
    unsigned char frameBuffer[144*168*4];
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#define WIDTH 144
#define HEIGHT 168

- (UIImage*)frameBufferImage
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bitmap = CGBitmapContextCreate(frameBuffer,
                                                WIDTH,
                                                HEIGHT,
                                                8,
                                                WIDTH*4,
                                                rgbColorSpace,
                                                (kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast));
    
    UIGraphicsBeginImageContext(CGSizeMake(WIDTH, 168));
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmap);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, HEIGHT);
    CGContextSaveGState(context);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, CGRectMake(0, 0, WIDTH, HEIGHT), imageRef);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGColorSpaceRelease(rgbColorSpace);
    
    return image;
}

- (void)updateReceivedMessage:(NSDictionary*)update
{
    NSArray *data = update[@"1396920900"]; // 'SCRD'
    if (data) {
        int start = [update[@"1396920915"] integerValue]; // 'SCRS'
        if (!start || start == 16*18) {
            for (int i=0; i<sizeof(frameBuffer); i+=4) {
                frameBuffer[i+0] = 0x00;
                frameBuffer[i+1] = 0x00;
                frameBuffer[i+2] = 0x00;
                frameBuffer[i+3] = 0xff;
            }
            if (start) {
                for (int y=0; y<16; y++) {
                    for (int x=0; x<144; x++) {
                        frameBuffer[4*(144*y+x)+0] = STATUS_BAR_pixel_data[3*(144*y+x)];
                        frameBuffer[4*(144*y+x)+1] = STATUS_BAR_pixel_data[3*(144*y+x)];
                        frameBuffer[4*(144*y+x)+2] = STATUS_BAR_pixel_data[3*(144*y+x)];
                    }
                }
            }
        }
        int length = data.count;
        unsigned char *dst = &frameBuffer[start*8*4];
        for (int i=0; i<length; i++) {
            unsigned char byte = [data[i] integerValue];
            for (int j=0; j<8; j++) {
                if (byte & 1<<j) {
                    *dst++ = 0xff;
                    *dst++ = 0xff;
                    *dst++ = 0xff;
                    *dst++ = 0xff;
                } else {
                    *dst++ = 0x00;
                    *dst++ = 0x00;
                    *dst++ = 0x00;
                    *dst++ = 0xff;
                }
            }
        }
        self.imageView.image = [self frameBufferImage];
    }
}

- (void)image:(UIImage*)image
didFinishSavingWithError:(NSError*)error
  contextInfo:(void*)contextInfo
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved to the Camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    self.imageView.image = nil;
}

- (IBAction)save:(id)sender
{
    if (self.imageView.image) {
        [[[UIAlertView alloc] initWithTitle:@"Save" message:@"Save screenshot to camera roll?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    }
}

@end
