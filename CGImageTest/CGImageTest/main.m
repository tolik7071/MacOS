//
//  main.m
//  CGImageTest
//
//  Created by Anatoliy Goodz on 7/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString * imagePath = @"/Users/tolik/Desktop/Lion.jpg";
        NSURL *imageUrl = [[NSURL alloc] initFileURLWithPath:imagePath];
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
        if (NULL != imageSource)
        {
            CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
            
            CGImageMetadataEnumerateTagsUsingBlock(
                metadata,
                NULL,
                (__bridge CFDictionaryRef)@{(NSString *)kCGImageMetadataEnumerateRecursively : @(YES)},
                ^bool(CFStringRef _Nonnull path, CGImageMetadataTagRef _Nonnull tag)
            {
                NSLog(@"%@ (%@)", (__bridge NSString *)path, (id)CFBridgingRelease(CGImageMetadataTagCopyValue(tag)));
                return true;
            });
            
            CGMutableImageMetadataRef mutableMetadata = CGImageMetadataCreateMutableCopy(metadata);
            
            NSString *exifUserCommentPath = [NSString stringWithFormat:@"%@:%@",
                (__bridge NSString *)kCGImageMetadataPrefixExif,
                (__bridge NSString *)kCGImagePropertyExifUserComment];
            
            CGImageMetadataTagRef metadataTag = CGImageMetadataTagCreate(
                kCGImageMetadataNamespaceExif,
                kCGImageMetadataPrefixExif,
                kCGImagePropertyExifUserComment,
                kCGImageMetadataTypeString,
                CFSTR("My comment!"));
            
            assert(CGImageMetadataSetTagWithPath(mutableMetadata, nil, (__bridge CFStringRef)exifUserCommentPath, metadataTag));
            
            NSURL *destinationImageUrl = [[NSURL alloc] initFileURLWithPath:@"/Users/tolik/Desktop/Lion_with_comment.jpg"];
            
            CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL(
                (__bridge CFURLRef)destinationImageUrl,
                CGImageSourceGetType(imageSource),
                1,
                NULL);
            assert(imageDestination);
            
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
            
            CGImageDestinationAddImageAndMetadata(
                imageDestination,
                image,
                mutableMetadata,
                nil);
            
            CGImageDestinationFinalize(imageDestination);

            CFRelease(image);
            CFRelease(metadataTag);
            CFRelease(imageDestination);
            CFRelease(mutableMetadata);
            CFRelease(metadata);
            CFRelease(imageSource);
        }
    }
    
    return 0;
}
