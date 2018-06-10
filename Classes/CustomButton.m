#import "CustomButton.h"

@implementation CustomButton {
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initParam];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initParam];
    return self;
}

- (void)initParam {
    self.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    self.cornerRadius = 7.5f;
}

- (void)drawRect:(CGRect)rect {
    self.layer.backgroundColor = _backgroundColor.CGColor;
    self.layer.cornerRadius = _cornerRadius;
    [super drawRect:rect];
}

@end
