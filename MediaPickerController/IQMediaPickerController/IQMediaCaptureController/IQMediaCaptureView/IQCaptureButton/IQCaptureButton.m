//
//  IQCaptureButton.m
//  https://github.com/hackiftekhar/IQMediaPickerController
//  Copyright (c) 2017 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "IQCaptureButton.h"

@implementation IQCaptureButton
{
    CALayer *outsideLayer;
    
    CGSize oldSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        oldSize = frame.size;
        outsideLayer = [[CALayer alloc] init];
        outsideLayer.borderWidth = 6.0;
        outsideLayer.borderColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:outsideLayer];
    }
    return self;
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    outsideLayer.frame = self.layer.bounds;
    outsideLayer.cornerRadius = self.layer.bounds.size.width/2;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(oldSize, self.frame.size) == false)
    {
        [self resetCaptureStyle];
    }
    
    oldSize = self.frame.size;
}

-(void)setCaptureMode:(IQMediaCaptureControllerCaptureMode)captureMode
{
    _captureMode = captureMode;
    [self resetCaptureStyle];
}

-(void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
    
    [self resetCaptureStyle];
}

-(void)resetCaptureStyle
{
    UIImage *newImage = nil;
    switch (self.captureMode)
    {
        default:
        case IQMediaCaptureControllerCaptureModePhoto:
        {
            CGSize size = self.frame.size;
            size.width = MAX(size.width-18, 0);
            size.height = MAX(size.height-18, 0);
            newImage = [[self class] circledImageWithColor:[UIColor whiteColor] size:size];
        }
            break;
        case IQMediaCaptureControllerCaptureModeVideo:
        {
            CGSize size = self.frame.size;
            
            if (self.isRecording)
            {
                CGSize size = self.frame.size;
                size.width = MAX(size.width-6, 0);
                size.height = MAX(size.height-6, 0);
                size.width /= 2;
                size.height /= 2;
                newImage = [[self class] recordingImageWithColor:[UIColor redColor] size:size];
            }
            else
            {
                size.width = MAX(size.width-18, 0);
                size.height = MAX(size.height-18, 0);
                newImage = [[self class] circledImageWithColor:[UIColor redColor] size:size];
            }
        }
            break;
        case IQMediaCaptureControllerCaptureModeAudio:
        {
            CGSize size = self.frame.size;
            
            if (self.isRecording)
            {
                CGSize size = self.frame.size;
                size.width = MAX(size.width-6, 0);
                size.height = MAX(size.height-6, 0);
                size.width /= 2;
                size.height /= 2;
                newImage = [[self class] recordingImageWithColor:[UIColor cyanColor] size:size];
            }
            else
            {
                size.width = MAX(size.width-18, 0);
                size.height = MAX(size.height-18, 0);
                newImage = [[self class] circledImageWithColor:[UIColor cyanColor] size:size];
            }
        }
            break;
    }
    
//    UIImage *oldImage = [self imageForState:UIControlStateNormal];
    
    [self setImage:newImage forState:UIControlStateNormal];

//    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
//    crossFade.duration = 0.5;
//    crossFade.fromValue = (id)oldImage.CGImage;
//    crossFade.toValue = (id)newImage.CGImage;
//    crossFade.removedOnCompletion = YES;
//    crossFade.fillMode = kCAFillModeForwards;
//    [self.imageView.layer addAnimation:crossFade forKey:@"animateContents"];
}

+ (UIImage *)circledImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGPathRef thePath = CGPathCreateWithRoundedRect(rect, size.width*0.5, size.height*0.5, NULL);
    CGContextAddPath(context, thePath);
    CGPathRelease(thePath);
    CGContextFillPath(context);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)recordingImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGPathRef thePath = CGPathCreateWithRoundedRect(rect, size.width*0.2, size.height*0.2, NULL);
    CGContextAddPath(context, thePath);
    CGPathRelease(thePath);
    CGContextFillPath(context);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
