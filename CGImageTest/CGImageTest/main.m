//
//  main.m
//  CGImageTest
//
//  Created by Anatoliy Goodz on 7/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

// https://en.wikipedia.org/wiki/Extensible_Metadata_Platform

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <CoreServices/CoreServices.h>

void PrintSupportedFormats(void);
void PrintMetadata(NSString *path);
NSString *DescriptionForTag(CGImageMetadataTagRef _Nonnull tag);
void SetValueForTag(NSString *path, NSString *tagName, NSString *tagValue);

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
//       PrintSupportedFormats();
//       PrintMetadata(@"/Users/tolik/Desktop/Lion.jpg");
       SetValueForTag(@"/Users/tolik/Desktop/Lion.jpg"
                    , @"FAB4B99E-B75A-4AD2-B5CF-C979F52680B5"
                    , @"WOW!!!");
       PrintMetadata(@"/Users/tolik/Desktop/Lion_with_comment.jpg");

       /*
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
        */
    }
    
    return 0;
}

void PrintSupportedFormats()
{
   NSArray *types = CFBridgingRelease(CGImageSourceCopyTypeIdentifiers());
   for (NSString *type in types)
   {
      CFStringRef description = UTTypeCopyDescription((__bridge CFStringRef)type);
      printf("%30s - %s\n", [type UTF8String], [(__bridge NSString *)description UTF8String]);
      if (description)
      {
         CFRelease(description);
      }
   }
}

void PrintMetadata(NSString *path)
{
   NSURL *imageUrl = [[NSURL alloc] initFileURLWithPath:path];
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
               NSString *type = DescriptionForTag(tag);
               NSString *value = [(id)CFBridgingRelease(CGImageMetadataTagCopyValue(tag)) description];

               printf("%s (%s) - %s\n"
                      , [(__bridge NSString *)path UTF8String]
                      , [type UTF8String]
                      , [value UTF8String]);

               return true;
            }
         );

      CFRelease(metadata);
      CFRelease(imageSource);
   }
}

NSString *DescriptionForTag(CGImageMetadataTagRef _Nonnull tag)
{
   NSString *result;

   switch (CGImageMetadataTagGetType(tag))
   {
      case kCGImageMetadataTypeDefault:
         result = @"Default";
         break;
      case kCGImageMetadataTypeString:
         result = @"String";
         break;
      case kCGImageMetadataTypeArrayUnordered:
         result = @"Unordered array";
         break;
      case kCGImageMetadataTypeArrayOrdered:
         result = @"Ordered array";
         break;
      case kCGImageMetadataTypeAlternateArray:
         result = @"Alternate array";
         break;
      case kCGImageMetadataTypeAlternateText:
         result = @"Alternate text";
         break;
      case kCGImageMetadataTypeStructure:
         result = @"Structure";
         break;
      default:
         result = @"Invalid";
   }

   return result;
}

void SetValueForTag(NSString *path, NSString *tagName, NSString *tagValue)
{
#pragma unused(tagName, tagValue)

   NSURL *imageUrl = [[NSURL alloc] initFileURLWithPath:path];
   CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
   if (NULL != imageSource)
   {
      CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);

      CGMutableImageMetadataRef mutableMetadata = CGImageMetadataCreateMutableCopy(metadata);

      CFStringRef xmlns = CFSTR("http://ns.tolik.com/description/1.0/");
      CFStringRef prefix = CFSTR("custom-shape");

      CFErrorRef error = NULL;
      BOOL isOk = CGImageMetadataRegisterNamespaceForPrefix(
         mutableMetadata,
         xmlns,
         prefix,
         &error);
      if (!isOk)
      {
         printf("Error code %ld\n", (long)CFErrorGetCode(error));
      }

      CGImageMetadataTagRef metadataTag = CGImageMetadataTagCreate(
         xmlns,
         prefix,
         CFSTR("my-shape"),
         kCGImageMetadataTypeString,
         CFSTR("It is a circle."));

      isOk = CGImageMetadataSetTagWithPath(mutableMetadata, nil, CFSTR("custom-shape:my-shape"), metadataTag);
      if (!isOk)
      {
         printf("Error!\n");
      }

      NSURL *destinationImageUrl = [[NSURL alloc] initFileURLWithPath:@"/Users/tolik/Desktop/Lion_with_comment.jpg"];

      CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL(
         (__bridge CFURLRef)destinationImageUrl,
         CGImageSourceGetType(imageSource),
         1,
         NULL);

      CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);

      CGImageDestinationAddImageAndMetadata(
         imageDestination,
         image,
         mutableMetadata,
         nil);

      CGImageDestinationFinalize(imageDestination);

      CFRelease(image);
      CFRelease(imageDestination);
      CFRelease(metadataTag);
      CFRelease(mutableMetadata);
      CFRelease(metadata);
      CFRelease(imageSource);
   }

//   CFShow(kCGImageMetadataNamespaceExif);
//   CFShow(kCGImageMetadataPrefixExif);
//   CFShow(kCGImagePropertyExifUserComment);
}
