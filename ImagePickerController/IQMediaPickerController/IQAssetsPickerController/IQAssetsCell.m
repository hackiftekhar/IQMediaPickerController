
#import "IQAssetsCell.h"
#import "IQShadowView.h"

@implementation IQAssetsCell

-(void)initialize
{
    self.checkmarkView.alpha = 0,0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        IQShadowView *shadowView = [[IQShadowView alloc] initWithFrame:self.contentView.bounds];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:shadowView];
        
        self.imageViewAsset = [[UIImageView alloc] initWithFrame:shadowView.bounds];
        self.imageViewAsset.clipsToBounds = YES;
        self.imageViewAsset.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewAsset.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.imageViewAsset];
    
        self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(3, self.imageViewAsset.bounds.size.height-15, self.bounds.size.width-6, 15)];
        self.labelDuration.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
//        self.labelDuration.textAlignment = NSTextAlignmentCenter;
        self.labelDuration.textColor = [UIColor whiteColor];
        self.labelDuration.font = [UIFont boldSystemFontOfSize:12];
        self.labelDuration.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.labelDuration];

        self.checkmarkView = [[IQCheckmarkView alloc] init];
        self.checkmarkView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        self.checkmarkView.frame = CGRectMake(self.imageViewAsset.bounds.size.width - 24, self.imageViewAsset.bounds.size.height - 24, 20, 20);
        [self.contentView addSubview:self.checkmarkView];
        
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
