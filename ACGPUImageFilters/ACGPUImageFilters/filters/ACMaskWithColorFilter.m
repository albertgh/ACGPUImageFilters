//
//  ACMaskWithColorFilter.m
//  ACGPUImageFilters
//
//  Created by albert on 2019/4/24.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ACMaskWithColorFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kACMaskWithColorFilterFragmentShaderString = SHADER_STRING
(
 precision lowp float; // 'vec4' : declaration must include a precision qualifier for type
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform vec3 maskColor;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((maskColor.rgb * textureColor.a), textureColor.a);
 }
 
 );
#else
NSString *const kACMaskWithColorFilterFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform vec3 maskColor;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((maskColor.rgb * textureColor.a), textureColor.a);
 }
 
 );
#endif


@interface ACMaskWithColorFilter ()
{
    GLint maskColorUniform;
}

@property(readwrite, nonatomic) GPUVector3 maskColor;

@end


@implementation ACMaskWithColorFilter

@synthesize maskColor = _maskColor;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kACMaskWithColorFilterFragmentShaderString]))
    {
        return nil;
    }
    
    maskColorUniform = [filterProgram uniformIndex:@"maskColor"];
    self.maskColor = (GPUVector3){1.0, 1.0, 1.0}; // default white
    
    return self;
}


#pragma mark - Public

- (void)configMaskColor:(UIColor *)color
{
    if (color)
    {
        const CGFloat *_components = CGColorGetComponents(color.CGColor);
        
        CGFloat red     = _components[0];
        CGFloat green   = _components[1];
        CGFloat blue    = _components[2];
        
        [self setMaskColorRed:red
                        green:green
                         blue:blue];
    }
}

#pragma mark - Accessors

- (void)setMaskColor:(GPUVector3)newValue;
{
    _maskColor = newValue;
    
    [self setMaskColorRed:_maskColor.one green:_maskColor.two blue:_maskColor.three];
}

-(void)setMaskColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
{
    GPUVector3 maskColor = {redComponent, greenComponent, blueComponent};
    _maskColor = maskColor;
    
    [self setVec3:maskColor forUniform:maskColorUniform program:filterProgram];
}

@end
