//
//  MMNTContactsManager.m
//  Momunt
//
//  Parses through user contac book. Sync user contacts with Momunt users.
//
//  Created by Masha Belyi on 10/5/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTContactsManager.h"
#import "MMNT_Contact.h"
#import "MMNTDataController.h"
#import "MMNTAccountManager.h"
#import "JNKeychain.h"


void MyAddressBookExternalChangeCallback (ABAddressBookRef ntificationaddressbook,CFDictionaryRef info,void *context)
{
    NSLog(@"ADDRESS BOOK CHANGED!");
    [[MMNTContactsManager sharedInstance] updateContacts];
}


@implementation MMNTContactsManager


- (id)init
{
    // RUNS FIRST TIME MMNTContactsManager is used
    self = [super init];
    if (self != nil) {
        _contacts = [[NSMutableArray alloc] init];
        _allMomuntUsers = [[NSMutableArray alloc] init];
        _momuntContacts = [[NSMutableArray alloc] init];
        _phoneContacts = [[NSMutableArray alloc] init];
        _APIcommunicator = [[MMNTApiCommuniator alloc] init];
//        [self checkPermissions];
        NSMutableArray *contacts = [self getUserContacts];
        NSLog(@"here");
        
    }
    
    return self;
}

+ (MMNTContactsManager*)sharedInstance
{
    static MMNTContactsManager *sharedInstance;
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
            [sharedInstance updateContacts];
            // update contacts every minute... watch for new users
            NSTimer *contactsRefresh = [NSTimer scheduledTimerWithTimeInterval:1*60 target:sharedInstance selector:@selector(updateContacts) userInfo:nil repeats:YES];
        }
        
        return sharedInstance;
    }
}


/*
 CONTACTS PERMISSIONS
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 */

-(void)checkPermissions{
    
    if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        // ask permission to use address book
         // 1) CUSTOM ALERT
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Let Momunt Use Address Book?"
                                                         message:@"Sharing with friends is simple when choosing them from the address book on your phone."
                                                        delegate:self
                                               cancelButtonTitle:@"Not Now"
                                               otherButtonTitles:@"Use Address Book", nil];
         [alert show];

    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access
//        [self updateContacts];
    }
    else {
        // The user has previously denied access
        // Don't do anything yet. Let user see 0 contacts, then request to see iphone contacts
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        // store user preference, try again later
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"allowAddressBook"];
        
    }else{
        // store user preference
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"allowAddressBook"];
        
        // show real address book permissions dialog
        BOOL allowAddressBook = [[MMNTDataController sharedInstance] askAddressBookPermission];
        if(allowAddressBook){
//            [self updateContacts];
        }
    }
    
    
}
/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
- (void)getAddressBook
{
    NSLog(@"getAddressBook no longer supported");
}
-(void)parseUsers:(NSArray *)userData{
    for (NSDictionary *userDict in userData) {
        NSPredicate *predExists = [NSPredicate predicateWithFormat:@"SELF.username == %@", [userDict objectForKey:@"username"]];
        NSUInteger index = [_allMomuntUsers indexOfObjectPassingTest:
                            ^(id obj, NSUInteger idx, BOOL *stop) {
                                return [predExists evaluateWithObject:obj];
                            }];
        if (index == NSNotFound) {
            MMNT_Contact *user = [[MMNT_Contact alloc] initWithDict:userDict];
            user.momuntUser = YES;
            if(user.userId != [[MMNTAccountManager sharedInstance] userId] ){
                [_allMomuntUsers addObject:user];
            }else{
                [_myContact addObject:user];
            }
        }
    }

}

-(NSMutableArray *)getUserContacts{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (addressBook != nil) {
            
            if(!_listeningForContactsChanges){
                ABAddressBookRegisterExternalChangeCallback(addressBook, MyAddressBookExternalChangeCallback, (__bridge void *)(self));
                _listeningForContactsChanges = YES;
            }
            
            //2
            NSMutableSet *unifiedRecordsSet = [NSMutableSet set];
            NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            //3
            NSUInteger i = 0;
            for (i = 0; i < [allContacts count]; i++)
            {
                ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
//                BOOL isMomuntContact = NO;
//                BOOL isMe = NO;
                //4
                NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName!=NULL ? lastName : @""];
                
                // Get all phone numbers of a contact. Iterate through each, see if it's a momunt user
                ABMultiValueRef phoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)(allContacts[i]), kABPersonPhoneProperty);
                NSMutableArray *phonesArray = [[NSMutableArray alloc] init];
                
                NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
                if(phoneNumberCount>0){
                
                    for (int i = 0; i < phoneNumberCount; i++) {
                        NSString *number = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                        NSString *cleanNumber = [[number componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                        [phonesArray addObject:cleanNumber];
                    }
                    NSDictionary *person = [NSDictionary dictionaryWithObjectsAndKeys:
                                            fullName, @"name",
                                            phonesArray, @"phoneNumbers",
                                            nil];
                    [contacts addObject:person];
                    
                }
                
            } // end iterate through contact book
            
        }//8
        //        CFRelease(addressBook);
    }
    else {
        NSLog(@"ERROR reading address book");
    }
    
    return contacts;
}
- (void)updateContacts{
    NSString *token = [JNKeychain loadValueForKey:@"AccessToken"];
    if(token.length==0){ // no API key -> logged out
        return;
    }
    
    NSArray *addressbook = [self getUserContacts];

    [_APIcommunicator syncContacts:addressbook completion:^(NSDictionary *obj) {
        _allMomuntUsers = [NSMutableArray new];
        _momuntContacts = [NSMutableArray new];
        _phoneContacts = [NSMutableArray new];
        _myContact = [NSMutableArray new];
        _sercheableContacts = [NSMutableArray new];

        
        NSArray *momuntContacts = [obj objectForKey:@"momuntContacts"];
        NSArray *momuntUsers = [obj objectForKey:@"momuntUsers"];
        NSArray *addressbook = [obj objectForKey:@"addressbook"];
        
        for (NSDictionary *contactDict in momuntContacts) {
            [_momuntContacts addObject: [[MMNT_Contact alloc] initWithDict:contactDict] ];
        }
        
        for (NSDictionary *contactDict in momuntUsers) {
            [_allMomuntUsers addObject: [[MMNT_Contact alloc] initWithDict:contactDict] ];
        }
        
        for (NSDictionary *contactDict in addressbook) {
            [_phoneContacts addObject: [[MMNT_Contact alloc] initWithDict:contactDict] ];
        }
        
        _sercheableContacts = [[_momuntContacts arrayByAddingObjectsFromArray:_allMomuntUsers] arrayByAddingObjectsFromArray:_phoneContacts];

    }];
}

-(NSArray *)allMomuntContacts{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i=0; i<[_contacts count]; i++){
        MMNT_Contact *contact = _contacts[i];
        if(contact.momuntUser){
            [array addObject:contact];
        }
    }
    return [NSArray arrayWithArray:array];
}


@end
