//
//  MMNT_TransparentTableView.m
//  
//
//  Created by Masha Belyi on 11/28/14.
//
//

#import "MMNT_TransparentTableView.h"

@implementation MMNT_TransparentTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        
    }
    return self;
}

@end
