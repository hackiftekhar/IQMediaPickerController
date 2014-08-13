
#import <UIKit/UIKit.h>

@class IQFeatureOverlay;

@protocol IQFeatureOverlayDelegate <NSObject>

@optional
//-(BOOL)featureOverlay:(IQFeatureOverlay*)featureOverlay shouldMoveToCenter:(CGPoint)center;
-(void)featureOverlay:(IQFeatureOverlay*)featureOverlay didEndWithCenter:(CGPoint)center;
@end

@interface IQFeatureOverlay : UIImageView

@property(nonatomic, assign) id<IQFeatureOverlayDelegate> delegate;

-(void)animate;

@end
