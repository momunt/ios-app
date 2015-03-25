//
//  MMNT_ContactsTextCell.m
//  Momunt
//
//  Created by Masha Belyi on 2/1/15.
//  Copyright (c) 2015 Masha Belyi. All rights reserved.
//

#import "MMNT_ContactsTextCell.h"

@implementation MMNT_ContactsTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier text:(NSString *)text type:(NSString *)type{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    self.contentView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
    
    self.textLabel.text = text;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    if([type isEqualToString:@"bold"]){
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.24];
        self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.24];
    }else{
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        self.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    
    
    return self;
    
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

//    // Configure the view for the selected state
//    self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
//    self.contentView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0]; // clear background
}

@end
