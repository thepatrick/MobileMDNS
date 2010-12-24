//
//  MDNSAPI.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDNSAPIDelegate;

@interface MDNSAPI : NSObject {

	id<MDNSAPIDelegate> delegate;
	NSString *apiKey;
	
	dispatch_queue_t queue;
	
}

@property (nonatomic, assign) id<MDNSAPIDelegate> delegate;
@property (nonatomic, copy) NSString *apiKey;

+api;

-initWithAPIKey:(NSString*)key;

-(void)fetchDomains:(void (^)(NSArray*))callback;
-(void)fetchDomain:(NSString*)domainID onComplete:(void (^)(NSDictionary*))callback;
-(void)saveDomainRecord:(NSDictionary*)record onComplete:(void (^)(BOOL, NSString*))callback;

-(void)fetchDomain:(NSString*)domainID;

@end
