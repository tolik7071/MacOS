//
//  main.m
//  ImageConverter
//
//  Created by Anatoliy Goodz on 7/23/14.
//  Copyright (c) 2014 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

void Usage(const char * path);
CFStringRef CreateUTIForFile(const char * path);
CGImageRef CreateImageWithAlpha(CGImageRef image);

const char kAddAlphaKey[] = "+alpha";

int main(int argc, const char * argv[])
{
    int result = 0;
    
    CGImageSourceRef sourceImage = NULL;
    CGImageDestinationRef destinationImage = NULL;
    BOOL isAlpha = NO;
    
    @autoreleasepool
    {
        do
        {
            // either 3 or 4 
            if (3 != argc && 4 != argc)
            {
                Usage(argv[0]);
                break;
            }
            
            if (4 == argc && 0 == strcmp(argv[3], kAddAlphaKey))
            {
                isAlpha = YES;
            }
            
            BOOL isDirectory = YES;
            if (! [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:argv[1]] isDirectory:&isDirectory]
                || isDirectory)
            {
                fprintf(stderr, "%s - no such image\n", argv[1]);
                result = 1;
                break;
            }
            
            NSURL *sourceImageUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]] isDirectory:NO];
            NSURL *destinationImageUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[2]] isDirectory:NO];
            if (! sourceImageUrl || ! destinationImageUrl)
            {
                result = 2;
                break;
            }
            
            sourceImage = CGImageSourceCreateWithURL((CFURLRef)sourceImageUrl, NULL);
            CFStringRef destinationImageUTI = CreateUTIForFile(argv[2]);
            if (destinationImageUTI)
            {
                destinationImage = CGImageDestinationCreateWithURL((CFURLRef)destinationImageUrl, destinationImageUTI, 1, NULL);
                CFRelease(destinationImageUTI);
            }
            if (! sourceImage || ! destinationImage)
            {
                result = 2;
                break;
            }
            
            CGImageRef image = CGImageSourceCreateImageAtIndex(sourceImage, 0, NULL);
            if (image)
            {
                if (isAlpha)
                {
                    CGImageRef imageWithAlpha = CreateImageWithAlpha(image);
                    if (imageWithAlpha)
                    {
                        CGImageRelease(image);
                        image = imageWithAlpha;
                    }
                    else
                    {
                        fprintf(stderr, "cannot create image with alpha\n");
                    }
                }
                
                CGImageDestinationAddImage(destinationImage, image, NULL);
                CGImageRelease(image);
            }
            else
            {
                result = 3;
            }
            
        } while (NO);
    }
    
    if (sourceImage)
    {
        CFRelease(sourceImage);
    }
    
    if (destinationImage)
    {
        if (0 == result)
        {
            CGImageDestinationFinalize(destinationImage);
        }
        
        CFRelease(destinationImage);
    }
    
    return result;
}

void Usage(const char * path)
{
    fprintf(stdout, "Usage: %s <source image> <destination image> [+alpha]\n"
            "\tFor example: `%s image.jpg image.png`\n"
            "\twill convert the image from JPG format to PNG\n"
            , [[[NSString stringWithUTF8String:path] lastPathComponent] UTF8String]
            , [[[NSString stringWithUTF8String:path] lastPathComponent] UTF8String]);
}

CFStringRef CreateUTIForFile(const char * path)
{
    CFStringRef result = NULL;
    
    NSString *extension = [[NSString stringWithUTF8String:path] pathExtension];
    if (extension)
    {
        result = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)extension, NULL);
    }
    
    return result;
}

CGImageRef CreateImageWithAlpha(CGImageRef image)
{
    if (! image)
    {
        return NULL;
    }
    
    CGImageRef result = NULL;
    
    size_t pixelsWide = CGImageGetWidth(image);
    size_t pixelsHigh = CGImageGetHeight(image);
    
    size_t bitmapBytesPerRow = (pixelsWide * 4);
    size_t bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL)
    {
        return NULL;
    }
    
    void *bitmapData = malloc(bitmapByteCount);
    if (! bitmapData)
    {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    CGContextRef context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8
        , bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast/*RGBA*/);
    if (context)
    {
        CGColorSpaceRelease(colorSpace);
        
        size_t w = CGImageGetWidth(image);
        size_t h = CGImageGetHeight(image);
        CGRect rect = { {0, 0}, {w, h} };
        
        CGContextDrawImage(context, rect, image);
        
        result = CGBitmapContextCreateImage(context);
        
        CGContextRelease(context);
    }
    
    if (bitmapData)
    {
        free(bitmapData);
    }
    
    return result;
}
