/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Data model for a search result item. 
 */

#import <Cocoa/Cocoa.h>

extern NSString *SearchItemDidChangeNotification;

@interface SearchItem : NSObject

- (instancetype)initWithItem:(NSMetadataItem *)item NS_DESIGNATED_INITIALIZER;

@property (readonly) NSMetadataItem *item;
@property (assign) NSInteger state;

@property (copy) NSString *title;

@property (readonly, strong) NSMetadataItem *metadataItem;

@property (readonly) NSSize imageSize;

@property (readonly, copy) NSURL *filePathURL;

@property (readonly, copy) NSDate *modifiedDate;
@property (readonly, copy) NSString *cameraModel;

// the thumbnail image may return nil if it isn't loaded. The first access of it will request it to load
@property (readonly, copy) NSImage *thumbnailImage;

@end
