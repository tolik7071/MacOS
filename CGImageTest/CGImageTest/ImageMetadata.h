//
//  ImageMetadata.h
//  CGImageTest
//
//  Created by Anatoliy Goodz on 7/15/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <CoreServices/CoreServices.h>

/*
   EXAMPLE:
   xmlns='http://ns.tolik.com/description/1.0/'
   prefix='custom-shape'
   path='custom-shape:my-shape'
   value='<square frame='0 0 300 300'>This is a description<square/>'
 */

@interface ImageMetadata : NSObject

- (instancetype)initWithXmlns:(NSString *)xmlns andPrefix:(NSString *)prefix;

- (BOOL)setMetadataForImageFile:(NSString *)fileName
   tagName:(NSString *)tagName
   path:(NSString *)path


@end
