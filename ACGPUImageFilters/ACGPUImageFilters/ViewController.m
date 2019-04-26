//
//  ViewController.m
//  ACGPUImageFilters
//
//  Created by albert on 2019/4/24.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>

#import "ACMaskWithColorFilter.h"
#import "ACInvertedMaskWithColorFilter.h"

#import "ACImageMaskFilter.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *resultImageView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self configSubviews];
    
    [self testingACFiltedImage];
}

- (void)configSubviews {
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.resultImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resultImageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.resultImageView];
    
    CGFloat imageEdge = 300.0;
    CGFloat imageX = (self.view.frame.size.width - imageEdge) / 2.0;
    self.resultImageView.frame = CGRectMake(imageX,
                                            120,
                                            imageEdge,
                                            imageEdge);
}

- (void)testingACFiltedImage {
    UIImage *resImage = nil;
    
    UIImage *originalImage = [UIImage imageNamed:@"star.png"];
    
    ACInvertedMaskWithColorFilter *maskFilter = [[ACInvertedMaskWithColorFilter alloc] init];
    [maskFilter configMaskColor:[UIColor blueColor]];
    
    UIImage *invertedMaskImage = [maskFilter imageByFilteringImage:originalImage];
    
//    CGFloat blurRadius = (maskImage.size.width * 0.1);
//    maskImage = [self imageWithShadowByImage:maskImage color:[UIColor redColor] blurRadius:blurRadius];
    
    
    CGFloat blurRadius = (originalImage.size.width * 0.1);
    NSLog(@"blur radius = %@", @(blurRadius));
    GPUImageGaussianBlurFilter *atFilter = [[GPUImageGaussianBlurFilter alloc] init];
    atFilter.blurRadiusInPixels = blurRadius;
    resImage = [atFilter imageByFilteringImage:invertedMaskImage];

    resImage = [self clipImage:resImage byMaskImage:originalImage];
    
    //resImage = [self maskImage:resImage withMask:invertedMaskImage];
    
    self.resultImageView.image = resImage;
    
    UIImage *st = self.resultImageView.image;
    NSString *breakPoint;
}

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}

- (UIImage *)clipImage:(UIImage *)image byMaskImage:(UIImage *)maskImage {
    UIImage *imgMask = maskImage;
    UIImage *imgBgImage = image;
    ACImageMaskFilter *maskingFilter = [[ACImageMaskFilter alloc] init];

    GPUImagePicture * maskGpuImage = [[GPUImagePicture alloc] initWithImage:imgMask ];
    GPUImagePicture *FullGpuImage = [[GPUImagePicture alloc] initWithImage:imgBgImage ];
    
    
    [FullGpuImage addTarget:maskingFilter];
    [FullGpuImage processImage];
    [maskingFilter useNextFrameForImageCapture];
    [maskGpuImage addTarget:maskingFilter];
    [maskGpuImage processImage];
    
    UIImage *OutputImage = [maskingFilter imageFromCurrentFramebuffer];
    
    return OutputImage;
}

- (UIImage*)imageWithShadowByImage:(UIImage *)image
                             color:(UIColor *)color
                        blurRadius:(CGFloat)blurRadius {
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext =
    CGBitmapContextCreate(NULL,
                          image.size.width,
                          image.size.height,
                          CGImageGetBitsPerComponent(image.CGImage),
                          0,
                          colourSpace,
                          kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // Set up the shadow
    CGSize offset = CGSizeZero;
    CGFloat blur = blurRadius;
    UIColor *innerGlowColor = color;
    CGContextSetShadowWithColor(shadowContext,
                                offset,
                                blur,
                                innerGlowColor.CGColor);
    CGContextDrawImage(shadowContext,
                       CGRectMake(0,
                                  0,
                                  image.size.width,
                                  image.size.height),
                       image.CGImage);
    
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}


@end
