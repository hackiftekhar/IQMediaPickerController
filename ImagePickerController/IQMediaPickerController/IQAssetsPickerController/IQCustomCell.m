
#import "IQCustomCell.h"
#import "IQShadowView.h"

@implementation IQCustomCell

-(void)initialize
{
    self.check.hidden = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        IQShadowView *shadowView = [[IQShadowView alloc] initWithFrame:self.contentView.bounds];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:shadowView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.imageView];
    
        self.duration = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.bounds.size.height-15, self.bounds.size.width, 15)];
        self.duration.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        self.duration.textAlignment = NSTextAlignmentCenter;
        self.duration.font = [UIFont systemFontOfSize:13];
        self.duration.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.duration];

        self.check = [[IQCheckmarkView alloc] init];
        self.check.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        self.check.frame = CGRectMake(self.imageView.bounds.size.width - 24, self.imageView.bounds.size.height - 24, 20, 20);
        [self.contentView addSubview:self.check];
        
        [self initialize];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

@end
