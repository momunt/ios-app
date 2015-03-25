//
//  MMNT_SavedMomunt_Cell.h
//  Momunt
//
//  Created by Masha Belyi on 8/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNTObj.h"
#import "MMNTMessageObj.h"
#import "MMNT_AsyncImage.h"
#import "MMNT_InteractiveIcon.h"

static NSString *CollectionViewCellIdentifier = @"SavedMomuntCell";
@class MMNT_SavedMomunt_Cell;

//@protocol SavedMomuntCellDelegate
//
//-(void)cell:(MMNT_SavedMomunt_Cell *)cell selectedMomunt:(MMNTObj *)mmnt;
//
//@end

@interface MMNT_SavedMomunt_Cell : UITableViewCell <MMNTInteractiveIconDelegate> {
    UIView     *_header;
    UILabel    *_location;
//    UILabel    *_date;
    UILabel    *_time;
    MMNTObj    *_data;
    MMNTObj    *_theMomunt;
    NSString   *_type;
    NSString   *_momuntId;
    BOOL       _uploading;
    BOOL       _canDelete;
    
    MMNT_AsyncImage  *_poster;
    UILabel          *_name;
    UILabel          *_date;
    
    UIView     *_momunt;
    UIView     *_delete;
    UIView     *_share;
    NSArray    *_shareButtons;
    
    
    BOOL       _startedPan;      // started swipe to open delete/share buttons
    NSInteger  _swipeDirection;  // direction of swipe +1/-1
    BOOL       _optionsOpen;     // swiped to open delete/share
    CGPoint    _startCenter;     // center of view at beginning of pan gesture
    BOOL       _openedShare;     // yes/no?
    BOOL       _verticalPan;
    
//    CGFloat       _numLocationFetch;
//    CLLocation    *_fetchedLocation;

    
}

@property UITableView        *tableView;
@property NSIndexPath        *indexPath;
@property NSMutableArray     *parentArray;
@property UIViewController   *parentVC;

@property (nonatomic, strong) UICollectionView *collectionView;
-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

/*
 Init
 @param UITableViewCelLStyle style
 @param NSString reuseIdentifier
 @param MMNTObj data
 @param NSString type (me/trending/chat)
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellData:(MMNTObj *)mmnt type:(NSString *)type;

/*
 Init from message
 @param UITableViewCelLStyle style
 @param NSString reuseIdentifier
 @param MMNTMessageObj msg
 @param NSString type (me/trending/chat)
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageData:(MMNTMessageObj *)msg;
@end
