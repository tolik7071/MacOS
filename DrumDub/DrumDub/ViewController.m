//
//  ViewController.m
//  DrumDub
//
//  Created by Anatoliy Goodz on 7/6/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    AVPlayer *player;
    NSTimer *playbackTimer;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *pathToSong = [[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"];
    NSAssert(pathToSong != nil, @"Oops! Where is a song?");
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:pathToSong] options:nil];
    NSAssert(asset != nil, @"Oops! Cannot create an asset!");
    
    for (AVMetadataItem *item in asset.commonMetadata)
    {
        printf("id: %s; type: %s; value: %s\n"
               , [item.identifier UTF8String]       // see AVMetadataIdentifiers.h, ID3Metadata
               , [item.dataType UTF8String]
               , [item.stringValue UTF8String]
            );
    }
    
    for (AVAssetTrack *track in asset.tracks)
    {
        printf("media type: %s\n"
               , [track.mediaType UTF8String]       // see AVMediaFormat.h
            );
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    NSAssert(item != nil, @"Oops! Cannot create an item!");

    // forwards for 10 seconds
    [item seekToTime:CMTimeMake(10, 1.0)];
    
    player = [AVPlayer playerWithPlayerItem:item];
    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"%@ -> %@", keyPath, [change description]);
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
