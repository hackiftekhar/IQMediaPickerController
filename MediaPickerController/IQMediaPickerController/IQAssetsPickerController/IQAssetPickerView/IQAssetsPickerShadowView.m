
#import "IQAssetsPickerShadowView.h"

@implementation IQAssetsPickerShadowView

-(void)initialize
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 1;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.layer setShadowPath:[UIBezierPath bezierPathWithRect:self.bounds].CGPath];
}

@end
