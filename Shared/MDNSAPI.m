//
//  MDNSAPI.m
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import "MDNSAPI.h"
#import "CJSONDeserializer.h"
#import "MDNSKey.h"
#import "NSDictionaryURLEncoding.h"


#define MDNSAPIRoot @"http://dns.m.ac.nz/dnsconfig/api/"

@interface MDNSAPI()

+(void)startNetworkActivity;
+(void)stopNetworkActivity;

-(id)apiPostToMethod:(NSString*)method withParams:(NSString*)params;
-(id)apiGetToMethod:(NSString*)method withParams:(NSString*)params;

@end

@implementation MDNSAPI

@synthesize apiKey;

+api {
	return [[[MDNSAPI alloc] initWithAPIKey:MDNS_API_KEY] autorelease];
}

+(void)startNetworkActivity {
	NSLog(@"startNetworkActivity!");
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@"no, really, startNetworkActivity!");
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	});
}

+(void)stopNetworkActivity {
	NSLog(@"stopNetworkActivity!");
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@"no, really, stopNetworkActivity!");
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	});
}

-initWithAPIKey:(NSString*)key {
	if((self = [super init])) {
		apiKey = [key copy];
		queue = dispatch_queue_create("com.pftqg.iOS.MDNSAPI", NULL);
	}
	return self;
}

-(void)dealloc {
	dispatch_release(queue);
    [super dealloc];
}

-(void)fetchDomains:(void (^)(NSArray*))callback {
	dispatch_async(queue, ^{
		[MDNSAPI startNetworkActivity];
		
		NSDictionary *domains = [self apiGetToMethod:@"domain/all" withParams:@""];

		dispatch_async(dispatch_get_main_queue(), ^{
			if([[domains objectForKey:@"status"] isEqualToString:@"ok"]) {
				callback([domains objectForKey:@"domains"]);
			} else {
				callback(nil);
			}
		});
				
		[MDNSAPI stopNetworkActivity];
	});
}

-(void)fetchDomain:(NSString*)domainID onComplete:(void (^)(NSDictionary*))callback {
	dispatch_async(queue, ^{
		[MDNSAPI startNetworkActivity];
		
		NSDictionary *domain = [self apiGetToMethod:@"domain/get" withParams:[@"id=" stringByAppendingString:domainID]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if([[domain objectForKey:@"status"] isEqualToString:@"ok"]) {
                callback(domain);
			} else {
                callback(nil);
			}
		});
		
		[MDNSAPI stopNetworkActivity];
	});
}

-(void)saveDomainRecord:(NSDictionary*)record onComplete:(void (^)(BOOL, NSString*))callback {
    dispatch_async(queue, ^{
        [MDNSAPI startNetworkActivity];		NSString *params = [record urlEncoded];
		NSLog(@"About to post %@", params);
        NSDictionary *result = (NSDictionary*)[self apiPostToMethod:@"record/modify" withParams:params];
        if(!result || ![[result objectForKey:@"status"] isEqualToString:@"ok"]) {
            callback(NO, result ? [result objectForKey:@"err"] : @"UNKNOWN_ERROR");
        } else {
            callback(YES, nil); 
        }
    });
}

#pragma mark -
#pragma mark API HTTP methods

-(id)apiGetToMethod:(NSString*)method withParams:(NSString*)params {
	NSURL *url = [NSURL URLWithString:[MDNSAPIRoot stringByAppendingFormat:@"%@?api.key=%@&%@", method, self.apiKey, params]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setTimeoutInterval:30];
	
	NSError *err; 
	NSURLResponse *response;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
	
	NSDictionary *dict = nil;
	if(responseData != nil) {
        dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:nil];
	} else {
		NSLog(@"Failed to get updates");
	}
	
	return dict;	
}

-(id)apiPostToMethod:(NSString*)method withParams:(NSString*)params {
	NSURL *url = [NSURL URLWithString:[MDNSAPIRoot stringByAppendingFormat:@"%@?api.key=%@", method, self.apiKey]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setTimeoutInterval:30];

	NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:data];
	
	NSError *err; 
	NSURLResponse *response;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];

	NSDictionary *dict = nil;
	if(responseData != nil) {
        dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:nil];
	} else {
		NSLog(@"Failed to get updates");
	}
	
	return dict;
}

@end
