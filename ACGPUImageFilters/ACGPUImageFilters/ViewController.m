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
    self.resultImageView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.resultImageView];
    
    CGFloat imageEdge = 300.0;
    CGFloat imageX = (self.view.frame.size.width - imageEdge) / 2.0;
    self.resultImageView.frame = CGRectMake(imageX,
                                            120,
                                            imageEdge,
                                            imageEdge);
}

- (void)testingACFiltedImage {
    UIImage *originalImage = [UIImage imageNamed:@"star.png"];
    
    ACInvertedMaskWithColorFilter *maskFilter = [[ACInvertedMaskWithColorFilter alloc] init];
    [maskFilter configMaskColor:[UIColor blueColor]];
    
    UIImage *maskImage = [maskFilter imageByFilteringImage:originalImage];
    
    
    self.resultImageView.image = maskImage;
}


@end
