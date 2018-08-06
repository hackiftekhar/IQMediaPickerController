//
//  AudioSettingsContainerView.m
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


#import <UIKit/UITableViewCell.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UILabel.h>

#import "IQAudioSettingsContainerView.h"
#import "NSString+IQTimeIntervalFormatter.h"

@interface IQAudioSettingsContainerView ()

@property(nonatomic) UILabel *labelDuration;

@end

@implementation IQAudioSettingsContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
        _labelDuration.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _labelDuration.textAlignment = NSTextAlignmentCenter;
        _labelDuration.font = [UIFont systemFontOfSize:18];
        _labelDuration.textColor = [UIColor whiteColor];
        [self addSubview:self.labelDuration];
        
        self.duration = 0;
    }
    return self;
}

-(void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    _labelDuration.text = [NSString timeStringForTimeInterval:duration forceIncludeHours:YES];
}

-(void)resetUI
{

}

@end
