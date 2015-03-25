//
//  MMNT_ContactsCell.h
//  Momunt
//
//  Created by Masha Belyi on 8/28/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MMNT_Contact.h"

@interface MMNT_ContactsCell : UITableViewCell{
    AsyncImageView  *_contactPic;
    UILabel         *_contactName;
    UILabel         *_contactNumber;
    UILabel         *_inviteBtn;
    UIImageView     *_checkImg;
    MMNT_Contact    *_contact;
    BOOL            _isSelected;

}
@property BOOL isSelected;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNT_Contact *)contact selected:(BOOL)selected;
- (BOOL)toggleSelection;
@end
