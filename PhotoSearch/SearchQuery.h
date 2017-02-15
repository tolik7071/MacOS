/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Data model for a photo search query. 
 */

#import <Cocoa/Cocoa.h>

#import "SearchItem.h"

// SearchQuery is made up of a query string that will have individual SearchItems as children.

extern NSString *SearchQueryChildrenDidChangeNotification;

@interface SearchQuery : NSObject <NSMetadataQueryDelegate>

@property (strong) NSString *title;
@property (strong) NSURL *searchURL;

- (instancetype)initWithSearchPredicate:(NSPredicate *)searchPredicate title:(NSString *)title scopeURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

@end
