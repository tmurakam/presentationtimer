#import <Foundation/Foundation.h>

IB_DESIGNABLE
@interface CustomButton : UIButton
@property (nonatomic) IBInspectable UIColor *backgroundColor;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@end