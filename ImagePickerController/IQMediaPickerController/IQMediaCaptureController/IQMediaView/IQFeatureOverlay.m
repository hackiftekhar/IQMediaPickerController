
#import "IQFeatureOverlay.h"

@implementation IQFeatureOverlay
{
    UIPanGestureRecognizer *_panRecognizer;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0, 1)];
        [self.layer setShadowRadius:1.0];
        [self.layer setShadowOpacity:0.5];
        
        [self setUserInteractionEnabled:YES];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [self addGestureRecognizer:_panRecognizer];
    }
    return self;
}

-(void)panGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint center = [recognizer locationInView:self.superview];

    [self setCenter:center];
    
    if (recognizer.state == UIGestureRecognizerStateEnded  && [self.delegate respondsToSelector:@selector(featureOverlay:didEndWithCenter:)])
    {
        [self.delegate featureOverlay:self didEndWithCenter:self.center];
    }
}

-(void)animate
{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}


@end
