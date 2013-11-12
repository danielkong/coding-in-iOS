//
//  CVContactListSvcModel.m
//  Vmoso
//
//  Copyright (c) 2013 Broadvision. All rights reserved.
//

#import "CVContactListSvcModel.h"
#import "CVContactItem.h"
#import "CVContactGroupItem.h"
#import "CVUserListItem.h"
#import <AddressBook/AddressBook.h>

@implementation CVContactListSvcModel

- (id)init {
    if (self = [super init]) {
        self.filter = @"";
        self.type = @"";
        self.sortBy = @"";
        self.order = @"";
        self.searchText = @"";
        if(self.selectedKeys == nil)
            self.selectedKeys = [NSMutableSet set];
        self.contactKey = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // decode instance properties with the coder
        _contactKey = [aDecoder decodeObjectForKey:@"contactKey"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    // encode the properties
    // note: never encode delegate property
    
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_contactKey forKey:@"contactKey"];
    
}

+ (NSString*)getCachedModelIdWithFilter:(NSString*)filter withType:(NSString*)type withSort: (NSString*)sortBy withContactKey: (NSString*)contactKey{
    
    if([CVAPIUtil isEmptyString:filter])
        filter = CONTACT_TYPE_ALL;
    
    if([CVAPIUtil isEmptyString:type])
        type = CONTACT_LIST_TYPE_CONTACT;
    
    if([CVAPIUtil isEmptyString:sortBy])
        sortBy = CONTACT_LIST_SORT_NAME;
    
    if([CVAPIUtil isEmptyString:contactKey])
        contactKey = @"";
    
    
    return [NSString stringWithFormat:@"%@_%@_%@_%@_%@", CONTACT_LIST_MODEL_ID, filter, type, sortBy, contactKey];
}

- (void)loadMore:(BOOL)more {
    
    if ([self.filter isEqualToString:CONTACT_TYPE_ADDRESSBOOK]) {
        NSArray* allContacts = [self getLocalContacts];
        
        if (self.pageIdx == 0)
            [self.items removeAllObjects];

        for (NSDictionary* contact in allContacts){
            CVContactItem* contactItem = [[CVContactItem alloc] init];
            
            contactItem.key = [CVAPIUtil getValidString:[contact objectForKey:@"key"]];
            contactItem.firstName = [CVAPIUtil getValidString:[contact objectForKey:@"firstName"]];
            contactItem.lastName = [CVAPIUtil getValidString:[contact objectForKey:@"lastName"]];
            contactItem.firstNameInEnglish = [CVAPIUtil getValidString:[contact objectForKey:@"firstName"]];
            contactItem.lastNameInEnglish = [CVAPIUtil getValidString:[contact objectForKey:@"lastName"]];

            contactItem.displayName = [CVAPIUtil getValidString:[NSString stringWithFormat:@"%@ %@",[contact objectForKey:@"firstName"], [contact objectForKey:@"lastName"]]];
            
            if([CVAPIUtil isEmptyString:contactItem.email])
                contactItem.email = contactItem.displayName;
            contactItem.contactType = @"addressbook";
            
            if ([[contact objectForKey:@"firstName"] isEqualToString:@""] && [[contact objectForKey:@"lastName"] isEqualToString:@""]) {
                contactItem.firstName = [NSString stringWithFormat:@"%@ ",[contact objectForKey:@"email"]];
                contactItem.displayName = contactItem.email;
            }
            [self.items addObject:contactItem];
        }
        
        NSInteger total= [allContacts count];
        self.hasMore = (total > ((self.pageIdx + 1)  * PAGE_LIMIT));

        [self.delegate modelDidFinishLoad:self action:@"Load"];
    } else {
        self.pageIdx = !more ? 0 : self.pageIdx + 1;
        
        CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:[self getAPIPath]];
        [request setHTTPMethod:@"GET"];
        
        [self sendRequest:request completion:^(NSDictionary* apiResult, NSError* error){
            
            [self updateModelWithResult:apiResult error:error action:@"load"];
            
        }];
    }
    
}

-(NSString*)getAPIPath {
    self.filter = self.filter ? self.filter : @"";
    self.type = self.type ? self.type : @"";
    self.sortBy = self.sortBy ? self.sortBy : @"";
    self.order = self.order ? self.order : @"";
    self.searchText = self.searchText ? self.searchText : @"";
    self.contactKey = self.contactKey ? self.contactKey : @"";
    
    NSString* apiPath = @"";
    if([self.filter isEqualToString:CONTACT_TYPE_GROUP])
        apiPath = [NSString stringWithFormat:@"/svc/groups?options.type=personal&pg.limit=%d&pg.offset=%d", PAGE_LIMIT, self.pageIdx*PAGE_LIMIT];
    else if([self.filter isEqualToString:CONTACT_TYPE_REQUESTS] || [self.filter isEqualToString:CONTACT_TYPE_PENDING]) {
        NSString* filterPara = [self.filter isEqualToString:CONTACT_TYPE_REQUESTS] ? @"inbound" : @"outbound";
        apiPath = [NSString stringWithFormat:@"/svc/contacts/requests?filter=%@&pg.limit=%d&pg.offset=%d", filterPara, PAGE_LIMIT, self.pageIdx*PAGE_LIMIT];
    }     
    else
        apiPath = [NSString stringWithFormat:@"/svc/contacts?options.contactType=%@&options.listType=%@&options.contactKey=%@&options.sortField=%@&options.ascending=%@&options.search=%@&pg.limit=%d&pg.offset=%d", self.filter, self.type, self.contactKey, self.sortBy, self.order, self.searchText , PAGE_LIMIT, self.pageIdx*PAGE_LIMIT];
    return apiPath;
}

- (void)updateModel:(NSDictionary*)apiResult action:(NSString*)action {
    
    if (apiResult == nil) {
        DLog(@"backend returned corrupt data");
        return;
    }
    
    if (self.pageIdx == 0)
        [self.items removeAllObjects];
    
    if([self.filter isEqualToString:CONTACT_TYPE_GROUP]) {
        [self updateGroups:apiResult];
    }  
    else if([self.filter isEqualToString:CONTACT_TYPE_REQUESTS] || [self.filter isEqualToString:CONTACT_TYPE_PENDING]) {
        [self updateRequests:apiResult];
    }
    else {
        [self updateContacts:apiResult];
    }
}

-(void) updateGroups:(NSDictionary*)apiResult {
    NSArray* groupList = (NSArray*)[apiResult objectForKey:@"groups"];
    
    for (NSDictionary* group in groupList) {
        
        CVContactGroupItem* groupItem = [[CVContactGroupItem alloc] init];
        groupItem.key = [CVAPIUtil getValidString:[group objectForKey:@"key"]];
        groupItem.name = [CVAPIUtil getValidString:[group objectForKey:@"name"]];
        groupItem.description = [CVAPIUtil getValidString:[group objectForKey:@"description"]];
        groupItem.members = [NSMutableSet set];
        
        NSArray* memberList = (NSArray*)[group objectForKey:@"users"];
        if (memberList == nil || ![memberList isKindOfClass:[NSArray class]]) {
            DLog(@"backend returned corrupt group memberList data");
            return;
        }
        for (NSDictionary* member in memberList) {
            CVUserListItem* memberItem = [[CVUserListItem alloc] init];
            memberItem.key = [CVAPIUtil getValidString:[member objectForKey:@"key"]];
            memberItem.displayName = [CVAPIUtil getValidString:[member objectForKey:@"displayName"]];
            memberItem.iconLarge = [CVAPIUtil getValidString:[member objectForKey:@"iconLarge"]];
            memberItem.isAlien = ![[member objectForKey:@"isRegistered"] boolValue];
            [groupItem.members addObject: memberItem];
    
        }
        [self.items addObject:groupItem];
        
    }
    
    NSInteger total= [[[apiResult objectForKey:@"pager"] objectForKey:@"total"] integerValue];
    self.hasMore = (total > ((self.pageIdx + 1)  *PAGE_LIMIT));
}

-(void) updateContacts:(NSDictionary*)apiResult {
    
    NSArray* contactList = (NSArray*)[apiResult objectForKey:@"users"];
    
    for (NSDictionary* contact in contactList) {
        CVContactItem* contactItem = [CVContactItem contactItemWithDictionary:contact];
        [self.items addObject:contactItem];
    }
    
    NSInteger total= [[[apiResult objectForKey:@"pager"] objectForKey:@"total"] integerValue];
    self.hasMore = (total > ((self.pageIdx + 1)  *PAGE_LIMIT));
    
}

-(void) updateRequests:(NSDictionary*)apiResult {
  
    NSMutableArray* trustedResults = [NSMutableArray array];
    NSArray* trustedUsers = [apiResult objectForKey:@"trustedRequests"];
    
    for (NSDictionary* contact in trustedUsers) {
        CVContactItem* newContact = [CVContactItem contactItemWithDictionary:contact];
        
        newContact.isConnectedUnread = [[CVAPIUtil getValidNumber:[contact objectForKey:@"isUnread"]] intValue] == 1 ? YES : NO;
        newContact.isTrustedUnread = [[CVAPIUtil getValidNumber:[contact objectForKey:@"isTrustedUnread"]] intValue] == 1 ? YES : NO;
        newContact.lastInviteTime = [CVAPIUtil getValidTimestamp:[contact objectForKey:@"lastInviteTime"]];
        newContact.requestType = @"trusted";
 
        [trustedResults addObject:newContact];
    }
    [self.items addObject:trustedResults];
    
    NSMutableArray* connectedResults = [NSMutableArray array];
    NSArray* users = [apiResult objectForKey:@"connectedRequests"];
    
    for (NSDictionary* contact in users) {
        CVContactItem* newContact = [CVContactItem contactItemWithDictionary:contact];
                
        newContact.isConnectedUnread = [[CVAPIUtil getValidNumber:[contact objectForKey:@"isUnread"]] intValue] == 1 ? YES : NO;
        newContact.isTrustedUnread = [[CVAPIUtil getValidNumber:[contact objectForKey:@"isTrustedUnread"]] intValue] == 1 ? YES : NO;
        newContact.lastInviteTime = [CVAPIUtil getValidTimestamp:[contact objectForKey:@"lastInviteTime"]];
        newContact.requestType = @"invite";
        
        [connectedResults addObject:newContact];
    }
    [self.items addObject:connectedResults];

    
    //TODO: just for connected requests now, need to add 'trustedListPageRecord' for trusted requests
    NSInteger total= [[[apiResult objectForKey:@"connectedListPageRecord"] objectForKey:@"total"] integerValue];
    self.hasMore = (total > ((self.pageIdx + 1)  *PAGE_LIMIT));
    
}

-(void) deleteContact: (BOOL) isGroup{
    
    NSString* resource;
    NSString* action;
    NSDictionary* para;
    
    if (isGroup) {
        action = @"deleteGroup";
        resource = @"/svc/groups";
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        [params setObject:@"personal" forKey:@"groupType"];
        [params setObject:[self.selectedKeys allObjects] forKey:@"keys"];
        para = [NSDictionary dictionaryWithDictionary:params];
    } else {
        action = @"deleteContact";
        resource = @"/svc/contacts";
        para = [NSDictionary dictionaryWithObject:[self.selectedKeys allObjects] forKey:@"keys"];
    }
    
    CVAPIRequest* request = [[CVAPIRequest alloc] initWithAPIPath:resource];
    NSString *paraJson = [para jsonValue];
    [request setPUTParamString:paraJson isJsonFormat:YES];
    
    CVAPIRequestModel* reqModel = [[CVAPIRequestModel alloc] init];
    
    [reqModel sendRequest:request completion:^(NSDictionary* apiResult, NSError* error){
        [self dispatchWithResult:apiResult error:error action:action];
    }];

}

- (NSArray *)getLocalContacts {
    
    __block NSMutableArray *allContacts = [NSMutableArray array];
    __block NSMutableSet* uniqueEmails = [NSMutableSet set];
    
    __block BOOL authorizedToAccess = NO;
    
    ABAddressBookRef bookRef = ABAddressBookCreate();
    
    if (ABAddressBookRequestAccessWithCompletion == nil) {
        // we're on iOS 5 or older
        authorizedToAccess = YES;
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(bookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted
            authorizedToAccess = YES;
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access
        authorizedToAccess = YES;
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
    if (!bookRef || !authorizedToAccess) {
        return allContacts;
    }
    
    CFArrayRef allContactsRef = ABAddressBookCopyArrayOfAllPeople(bookRef);
    for (int i = 0, count = CFArrayGetCount(allContactsRef); i < count; i++) {
        ABRecordRef contact = CFArrayGetValueAtIndex(allContactsRef, i);
        
        CFTypeRef firstNameRef = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
        CFTypeRef lastNameRef = ABRecordCopyValue(contact, kABPersonLastNameProperty);
        
        NSString* firstName = (firstNameRef == nil) ? @"" : (__bridge NSString*)firstNameRef;
        NSString* lastName = (lastNameRef == nil) ? @"" : (__bridge NSString*)lastNameRef;
        NSString* firstLastName = (firstNameRef == nil) && (lastNameRef == nil) ? @"" : (firstNameRef == nil) ? lastName : (lastNameRef == nil) ? firstName : [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get all emails and add them to emails dictionary with lable-content pattern.
        
        ABMultiValueRef emailsRef = ABRecordCopyValue(contact, kABPersonEmailProperty);
        NSMutableSet* emails = [NSMutableSet set];
        for (int j = 0, emailsCount = ABMultiValueGetCount(emailsRef); j < emailsCount; j++) {
            NSString* email = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailsRef, j));
            
            // if email the same as of other contacts, skip
            if ([uniqueEmails containsObject:email])
                continue;
            
            [emails addObject:email];
        }
        
        if ([emails count] == 0)
            continue;
        
        [emails enumerateObjectsUsingBlock:^(id obj, BOOL *stop)  {
            [uniqueEmails addObject:obj];
            NSString* displayName = [NSString stringWithFormat:@"%@ <%@>", firstLastName, obj];
            [allContacts addObject:[NSDictionary dictionaryWithObjectsAndKeys:displayName, @"displayName", obj, @"email", obj, @"key", firstName, @"firstName", lastName, @"lastName", nil]];
        }];
        
    }
    
    return allContacts;
}

@end
