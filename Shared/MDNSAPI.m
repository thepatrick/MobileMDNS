//
//  MDNSAPI.m
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import "MDNSAPIDelegate.h"
#import "MDNSAPI.h"
#import "CJSONDeserializer.h"
#import "MDNSKey.h"


#define MDNSAPIRoot @"http://dns.m.ac.nz/dnsconfig/api/"

@interface MDNSAPI()

+(void)startNetworkActivity;
+(void)stopNetworkActivity;

-(id)apiPostToMethod:(NSString*)method withParams:(NSString*)params;
-(id)apiGetToMethod:(NSString*)method withParams:(NSString*)params;

@end

@implementation MDNSAPI

@synthesize delegate, apiKey;

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
	[self performSelectorOnMainThread:@selector(stopNetworkActivityMain) withObject:nil waitUntilDone:YES];
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

-(void)fetchDomains {
	dispatch_async(queue, ^{
		[MDNSAPI startNetworkActivity];
		
		NSDictionary *domains = [self apiGetToMethod:@"domain/all" withParams:@""];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if([[domains objectForKey:@"status"] isEqualToString:@"ok"]) {
				[delegate mdnsapi:self didFetchDomains:[domains objectForKey:@"domains"]];
			} else {
				[delegate mdnsapi:self didFetchDomains:nil];
			}
		});
				
		[MDNSAPI stopNetworkActivity];
	});
}

-(void)fetchDomain:(NSString*)domainID {
	dispatch_async(queue, ^{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		[MDNSAPI startNetworkActivity];
		
		NSDictionary *domain = [self apiGetToMethod:@"domain/get" withParams:[@"id=" stringByAppendingString:domainID]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Done! %@", self->delegate);
			if([[domain objectForKey:@"status"] isEqualToString:@"ok"]) {
				[delegate mdnsapi:self didFetchDomain:domain];
			} else {
				[delegate mdnsapi:self didFetchDomain:nil];
			}
		});
		
		[MDNSAPI stopNetworkActivity];
		[pool release];
	});
}

-(void)saveDomainRecord:(NSDictionary*)record onComplete:(void (^)(BOOL, NSString*))callback {
    dispatch_async(queue, ^{
        [MDNSAPI startNetworkActivity];
        NSDictionary *result = (NSDictionary*)[self apiPostToMethod:@"record/modify" withParams:@""];
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
	NSString *showsJSONData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *dict = nil;
	if(showsJSONData != nil) {
        dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[showsJSONData dataUsingEncoding:NSUTF8StringEncoding] error:nil];
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
