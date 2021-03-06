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

#import "ACImageClipFilter.h"


@interface ViewController ()

@property (nonatomic, strong) UIImageView *originalImageView;

@property (nonatomic, strong) UIImageView *resultImageView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self configSubviews];
    
    [self testingACFiltedImage];
    
    [self testingAvgColorAndLum];
    
    
}

- (void)configSubviews {
    CGFloat imageEdge = 300.0;
    CGFloat imageX = (self.view.frame.size.width - imageEdge) / 2.0;
    
    self.originalImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.originalImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.originalImageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.originalImageView];
    
    self.originalImageView.frame = CGRectMake(imageX,
                                              120,
                                              imageEdge,
                                              imageEdge);
    
    
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.resultImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resultImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.resultImageView];
    
    self.resultImageView.frame = CGRectMake(imageX,
                                            120,
                                            imageEdge,
                                            imageEdge);
}

- (void)testingAvgColorAndLum {
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"shuijiao_clipped.png"]];

    GPUImageAverageColor *averageColor = [[GPUImageAverageColor alloc] init];
    [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime){
        NSLog(@"Red: %f, green: %f, blue: %f, alpha: %f", redComponent, greenComponent, blueComponent, alphaComponent);
    }];
    
    
    GPUImageLuminosity *luminosity = [[GPUImageLuminosity alloc] init];
    [luminosity setLuminosityProcessingFinishedBlock:^(CGFloat luminosity, CMTime frameTime) {
        NSLog(@"bg Lumin is %f ", luminosity);
    }];
    
    [imagePicture addTarget:averageColor];
    [imagePicture addTarget:luminosity];
    [imagePicture processImage];
}

- (void)testingACFiltedImage {
    self.originalImageView.image = [UIImage imageNamed:@"shuijiao_clipped.png"];
    
    UIImage *resImage = nil;
    
    UIImage *originalImage = [UIImage imageNamed:@"shuijiao_clipped.png"];
    
    ACInvertedMaskWithColorFilter *maskFilter = [[ACInvertedMaskWithColorFilter alloc] init];
    [maskFilter configMaskColor:[UIColor blueColor]];
    
    UIImage *invertedMaskImage = [maskFilter imageByFilteringImage:originalImage];

    
    CGFloat blurRadius = (originalImage.size.width * 0.1);
    NSLog(@"blur radius = %@", @(blurRadius));
    GPUImageGaussianBlurFilter *atFilter = [[GPUImageGaussianBlurFilter alloc] init];
    atFilter.blurRadiusInPixels = blurRadius;
    atFilter.texelSpacingMultiplier = 0.68;
    resImage = [atFilter imageByFilteringImage:invertedMaskImage];

    resImage = [self clipImage:resImage byMaskImage:originalImage];
    //resImage = [self maskImage:resImage withMask:invertedMaskImage];
    
    self.resultImageView.image = resImage;
}

- (UIImage *)clipImage:(UIImage *)image byMaskImage:(UIImage *)maskImage {
    UIImage *imgMask = maskImage;
    UIImage *imgBgImage = image;
    ACImageClipFilter *maskingFilter = [[ACImageClipFilter alloc] init];

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

- (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
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
