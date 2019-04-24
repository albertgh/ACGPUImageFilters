//
//  ViewController.m
//  ACGPUImageFilters
//
//  Created by albert on 2019/4/24.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    
    UIImage *originalImage = [UIImage imageNamed:@"star.png"];
    
    GPUImageOpacityFilter *opacityFilter = [[GPUImageOpacityFilter alloc] init];
    opacityFilter.opacity = 0.5;
    
    UIImage *opacityImage = [opacityFilter imageByFilteringImage:originalImage];
    
    UIImage *breakpoint = opacityImage;
    
    
}


@end
