//
//  MDNSAPI.m
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Sharkey Media. All rights reserved.
//

#import "MDNSAPIDelegate.h"
#import "MDNSAPI.h"
#import "CJSONDeserializer.h"


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
	return [[[MDNSAPI alloc] initWithAPIKey:@"~APIKEYGOESHERE~"] autorelease];
}

+(void)startNetworkActivity {
	NSLog(@"startNetworkActivity!");
	//[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(setNetworkActivityIndicatorVisible:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
}

+(void)stopNetworkActivity {
	NSLog(@"stopNetworkActivity!");
	[self performSelectorOnMainThread:@selector(stopNetworkActivityMain) withObject:nil waitUntilDone:YES];
}

+(void)stopNetworkActivityMain {
	NSLog(@"no, really, stopNetworkActivity!");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		[MDNSAPI startNetworkActivity];
		
		NSDictionary *domains = [self apiGetToMethod:@"domain/all" withParams:@""];
		[self performSelectorOnMainThread:@selector(fetchDomainsComplete:) withObject:domains waitUntilDone:YES];
				
		[MDNSAPI stopNetworkActivity];
		[pool release];
	});
//	[self performSelectorInBackground:@selector(fetchDomainsInBackground) withObject:nil];
}

-(void)fetchDomainsInBackground {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[MDNSAPI startNetworkActivity];
	
	NSArray *domains = [self apiGetToMethod:@"domain/all" withParams:@""];
	[self performSelectorOnMainThread:@selector(fetchDomainsComplete:) withObject:domains waitUntilDone:YES];
	
	[MDNSAPI stopNetworkActivity];
    [pool release];
}

-(void)fetchDomainsComplete:(NSDictionary*)domains {
	if([[domains objectForKey:@"status"] isEqualToString:@"ok"]) {
		[delegate mdnsapi:self didFetchDomains:[domains objectForKey:@"domains"]];
	} else {
		[delegate mdnsapi:self didFetchDomains:nil];
	}
}

-(void)fetchDomain:(NSString*)domainID {
	dispatch_async(queue, ^{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		[MDNSAPI startNetworkActivity];
		
		NSDictionary *domain = [self apiGetToMethod:@"domain/get" withParams:[@"id=" stringByAppendingString:domainID]];
		[self performSelectorOnMainThread:@selector(fetchDomainComplete:) withObject:domain waitUntilDone:NO];

		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Done! %@", self->delegate);
			//[self->delegate mdnsapi:self didFetchDomain:domain];
		});
		
		[MDNSAPI stopNetworkActivity];
		[pool release];
	});
}

-(void)fetchDomainComplete:(NSDictionary*)domain {
	if([[domain objectForKey:@"status"] isEqualToString:@"ok"]) {
		[delegate mdnsapi:self didFetchDomain:domain];
	} else {
		[delegate mdnsapi:self didFetchDomain:nil];
	}
}

-(void)saveDomainRecord:(NSDictionary*)record withCallback:(void (^)(BOOL, NSString*))callback {
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
