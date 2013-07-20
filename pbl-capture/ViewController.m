//
//  ViewController.m
//  pbl-capture
//
//  Created by Edward Patel on 2013-07-20.
//  Copyright (c) 2013 Memention AB. All rights reserved.
//

#import "ViewController.h"
#import <PebbleKit/PebbleKit.h>

@interface ViewController () <PBPebbleCentralDelegate> {
    PBWatch *_targetWatch;
    unsigned char frameBuffer[144*168*4];
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectedLabel.text = @"Connecting...";
    
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
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
                                                kCGImageAlphaNoneSkipLast);
    
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

- (void)setTargetWatch:(PBWatch*)watch
{
    _targetWatch = watch;
    
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            uint8_t bytes[] = { 0xAB, 0xC1, 0x37, 0x4F, 0xA9, 0x4B, 0x4F, 0xBB, 0x95, 0x31, 0x63, 0x47, 0x84, 0x2F, 0xCD, 0xB1 };
            NSData *uuid = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            [watch appMessagesSetUUID:uuid];
            
            self.connectedLabel.text = @"Connected";
            
            [watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
                switch ([update[@(0)] integerValue]) {
                    case 1:
                    {
                        int start = [update[@(1000)] integerValue];
                        if (!start) {
                            for (int i=0; i<sizeof(frameBuffer); i+=4) {
                                frameBuffer[i+0] = 0x00;
                                frameBuffer[i+1] = 0x00;
                                frameBuffer[i+2] = 0x00;
                                frameBuffer[i+3] = 0xff;
                            }
                        }
                        NSData *data = update[@(1001)];
                        unsigned char *bytes = (unsigned char *)data.bytes;
                        int length = data.length;
                        unsigned char *dst = &frameBuffer[start*8*4];
                        if (data) {
                            for (int i=0; i<length; i++) {
                                for (int j=0; j<8; j++) {
                                    if (bytes[i] & 1<<j) {
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
                            if (length < 64) { // TODO: Remove this way to end
                                self.connectedLabel.text = @"Done";
                                self.saveButton.hidden = NO;
                            } else {
                                self.connectedLabel.text = @"Receiving...";
                            }
                        }
                        break;
                    }

                    case 2:
                        // TODO: Use done message sent from watch
                        self.imageView.image = [self frameBufferImage];
                        break;

                    default:
                        break;
                }
                
                return YES;
            }];

        } else {
            
            self.connectedLabel.text = @"Disconnected";
            
        }
    }];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew
{
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch
{
    self.connectedLabel.text = @"Disconnected";
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
    }
}

- (void)image:(UIImage*)image
didFinishSavingWithError:(NSError*)error
  contextInfo:(void*)contextInfo
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved to the Camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (IBAction)save:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

@end
