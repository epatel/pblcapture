//
//  AppDelegate.m
//  pbl-capture
//
//  Created by Edward Patel on 2013-07-20.
//  Copyright (c) 2013 Memention AB. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AppDelegate

- (void)startServer
{
	NSError *error;
	if ([self.httpServer start:&error]) {
		DDLogInfo(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
	} else {
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	self.httpServer = [[HTTPServer alloc] init];
	[self.httpServer setConnectionClass:[MyHTTPConnection class]];
	[self.httpServer setPort:9898];
    [self startServer];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    [MyHTTPConnection setUpdateBlock:^(NSDictionary *update) {
        [self.viewController updateReceivedMessage:update];
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.httpServer stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self startServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
