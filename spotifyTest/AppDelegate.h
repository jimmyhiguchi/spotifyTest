//
//  AppDelegate.h
//  spotifyTest
//
//  Created by Jimmy Higuchi on 12/31/17.
//  Copyright © 2017 Jimmy Higuchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, SPTAudioStreamingDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

