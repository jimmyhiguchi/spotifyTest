//
//  AppDelegate.m
//  spotifyTest
//
//  Created by Jimmy Higuchi on 12/31/17.
//  Copyright © 2017 Jimmy Higuchi. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIViewController *authViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.auth = [SPTAuth defaultInstance];
    self.player = [SPTAudioStreamingController sharedInstance];
    
    // The client ID you got from the developer site
    self.auth.clientID = @"fae64d5e0e044838a3e914b72383c21b";
    // The redirect URL as you entered it at the developer site
    self.auth.redirectURL = [NSURL URLWithString:@"spotifydemo:\\returnAfterLogin"];
    // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
    self.auth.sessionUserDefaultsKey = @"current session";
    // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
    self.auth.requestedScopes = @[SPTAuthStreamingScope];
    
    // Become the streaming controller delegate
    self.player.delegate = self;
    
    // Start up the streaming controller.
    NSError *audioStreamingInitError;
    NSAssert([self.player startWithClientId:self.auth.clientID error:&audioStreamingInitError],
             @"There was a problem starting the Spotify SDK: %@", audioStreamingInitError.description);
    
    // Start authenticating when the app is finished launching
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startAuthenticationFlow];
    });
    
    return YES;
}

- (void)startAuthenticationFlow
{
    // Check if we could use the access token we already have
    if ([self.auth.session isValid]) {
        // Use it to log in
        [self.player loginWithAccessToken:self.auth.session.accessToken];
    } else {
        // Get the URL to the Spotify authorization portal
        NSURL *authURL = [self.auth spotifyWebAuthenticationURL];
        // Present in a SafariViewController
        self.authViewController = [[SFSafariViewController alloc] initWithURL:authURL];
        [self.window.rootViewController presentViewController:self.authViewController animated:YES completion:nil];
    }
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    // If the incoming url is what we expect we handle it
    if ([self.auth canHandleURL:url]) {
        // Close the authentication window
        [self.authViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        self.authViewController = nil;
        // Parse the incoming url to a session object
        [self.auth handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            if (session) {
                // login to the player
                [self.player loginWithAccessToken:self.auth.session.accessToken];
            }
        }];
        return YES;
    }
    return NO;
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming
{
    [self.player playSpotifyURI:@"spotify:track:58s6EuEYJdlb0kO7awm3Vp" startingWithIndex:0 startingWithPosition:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** failed to play: %@", error);
            return;
        }
    }];
}

@end
