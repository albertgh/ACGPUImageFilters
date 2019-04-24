//
//  ACMaskWithColorFilter.h
//  ACGPUImageFilters
//
//  Created by albert on 2019/4/24.
//  Copyright © 2019 albert. All rights reserved.
//

#import "GPUImageFilter.h"


@interface ACMaskWithColorFilter : GPUImageFilter

- (void)configMaskColor:(UIColor *_Nullable)color;

@end
