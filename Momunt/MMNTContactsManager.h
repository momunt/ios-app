//
//  MMNTContactsManager.h
//  Momunt
//
//  Created by Masha Belyi on 10/5/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MMNTApiCommuniator.h"

@interface MMNTContactsManager : NSObject <UIActionSheetDelegate>{
    BOOL _listeningForContactsChanges;
}

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray *allMomuntUsers;
@property (strong, nonatomic) NSMutableArray *momuntContacts;
@property (strong, nonatomic) NSMutableArray *phoneContacts;
@property (strong, nonatomic) NSMutableArray *myContact;
@property (strong, nonatomic) NSMutableArray *sercheableContacts;


+(MMNTContactsManager*)sharedInstance;
@property (strong, nonatomic) MMNTApiCommuniator *APIcommunicator;

-(void)getAddressBook;
-(void)updateContacts;
-(NSArray *)allPhoneContacts;
-(NSArray *)allMomuntContacts;

void MyAddressBookExternalChangeCallback (ABAddressBookRef ntificationaddressbook,CFDictionaryRef info,void *context);

@end
