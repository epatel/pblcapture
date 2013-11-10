//
//  ViewController.h
//  pbl-capture
//
//  Created by Edward Patel on 2013-07-20.
//  Copyright (c) 2013 Memention AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (void)updateReceivedMessage:(NSDictionary*)update;
- (IBAction)save:(id)sender;

@end
