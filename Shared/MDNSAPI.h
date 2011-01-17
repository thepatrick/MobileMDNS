//
//  MDNSAPI.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

enum MDNSAPIReturnTypes {
	MDNSAPIJSONDictionaryResponse = 0,
	MDNSAPIJSONArrayResponse = 1,
	MDNSAPITextResponse = 2
};

@interface MDNSAPI : NSObject {

	NSString *apiKey;
	
	dispatch_queue_t queue;
	
}

@property (nonatomic, copy) NSString *apiKey;

+api;

-initWithAPIKey:(NSString*)key;

-(void)fetchDomains:(void (^)(NSArray*))callback;
-(void)fetchDomain:(NSString*)domainID onComplete:(void (^)(NSDictionary*))callback;
-(void)saveDomainRecord:(NSDictionary*)record onComplete:(void (^)(BOOL, NSString*))callback;


@end
