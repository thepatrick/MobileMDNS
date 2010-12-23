//
//  MDNSAPI.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Sharkey Media. All rights reserved.
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

-(void)fetchDomains;
-(void)fetchDomain:(NSString*)domainID;

@end
