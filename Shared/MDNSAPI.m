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

-(id)apiPostToMethod:(NSString*)method withParams:(NSString*)params deserialize:(BOOL)deserialize;
-(id)apiGetToMethod:(NSString*)method withParams:(NSString*)params deserialize:(BOOL)deserialize;

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
		
		NSDictionary *domains = [self apiGetToMethod:@"domain/all" withParams:@"" deserialize:YES];

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
		
		NSDictionary *domain = [self apiGetToMethod:@"domain/get" withParams:[@"id=" stringByAppendingString:domainID] deserialize:YES];
		
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

-(void)createDomain:(NSDictionary*)domain onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"domain/create";
	dispatch_async(queue, ^{
        [MDNSAPI startNetworkActivity];		
		NSString *params = [domain urlEncoded];
		NSLog(@"About to post %@", params);
        NSDictionary *result = (NSDictionary*)[self apiPostToMethod:path withParams:params deserialize:YES];
        if(!result || ![[result objectForKey:@"status"] isEqualToString:@"ok"]) {
            callback(NO, result ? [result objectForKey:@"err"] : @"UNKNOWN_ERROR");
        } else {
            callback(YES, [result objectForKey:@"domain"]); 
        }
    });
}

-(void)modifyDomainAdvanced:(NSDictionary*)domain onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"domain/modifyAdvanced";
	// post (id, refresh, retry, expire, default_ttl), if fail err || domain	
}

-(void)destroyDomain:(NSString*)domainID onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"domain/destroy";
	// post (id), if fail err || destroyed == domain key
}


-(void)publishDomain:(NSString*)domainID onComplete:(void (^)(BOOL,NSString*))callback {
	dispatch_async(queue, ^{
		[MDNSAPI startNetworkActivity];	
		NSString *params = [NSString stringWithFormat:@"id=%@", [domainID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSLog(@"About to post %@", params);
        NSDictionary *result = (NSDictionary*)[self apiPostToMethod:@"domain/publish" withParams:params deserialize:YES];
        if(!result || ![[result objectForKey:@"status"] isEqualToString:@"ok"]) {
            callback(NO, result ? [result objectForKey:@"err"] : @"UNKNOWN_ERROR");
        } else {
            callback(YES, [result objectForKey:@"version"]); 
        }
		
		// status = ok, then "version", else "err"
		[MDNSAPI stopNetworkActivity];
	});
}

-(void)zonefileForDomain:(NSString*)domainID onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"domain/zonefile";
	// ?key=%@, domainID
	// deserialize:NO
}

-(void)domainRecordTypes:(void (^)(BOOL, NSArray*))callback {
	NSString *path = @"record/getTypes";
	// no params, return type is an array
}

-(void)domainRecord:(NSString*)recordID onComplete:(void (^)(BOOL, NSDictionary*))callback {
	NSString *path = @"record/get";
	// ?id=%@, recordID
	// return type is dictionary
}

-(void)createDomainRecord:(NSDictionary*)record onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"record/create";
	// post
	// return type is dictionary as "record"
}

-(void)saveDomainRecord:(NSDictionary*)record onComplete:(void (^)(BOOL, NSString*))callback {
    dispatch_async(queue, ^{
        [MDNSAPI startNetworkActivity];		
		NSString *params = [record urlEncoded];
		NSLog(@"About to post %@", params);
        NSDictionary *result = (NSDictionary*)[self apiPostToMethod:@"record/modify" withParams:params deserialize:YES];
        if(!result || ![[result objectForKey:@"status"] isEqualToString:@"ok"]) {
            callback(NO, result ? [result objectForKey:@"err"] : @"UNKNOWN_ERROR");
        } else {
            callback(YES, nil); 
        }
    });
}

-(void)destroyDomainRecord:(NSString*)recordID onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"domain/destroy";
	// post (id), if fail err || destroyed (= recordID)
}

-(void)createAuthKeyForDevice:(NSString*)deviceID andApplication:(NSString*)applicationID onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"key/create";
	// get (device_id, application_name), if (error) error || key. 
}

-(void)verifyKey:(NSString*)key onComplete:(void (^)(BOOL, NSString*))callback {
	NSString *path = @"key/auth";
	// get (api.key), if error: BAD_KEY then error, if NOT_AUTHD_YET then auth_url, if ok then user
}
#pragma mark -
#pragma mark API HTTP methods

-(id)apiGetToMethod:(NSString*)method withParams:(NSString*)params deserialize:(BOOL)deserialize {
	NSURL *url = [NSURL URLWithString:[MDNSAPIRoot stringByAppendingFormat:@"%@?api.key=%@&%@", method, self.apiKey, params]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setTimeoutInterval:30];
	
	NSError *err; 
	NSURLResponse *response;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
	
	NSDictionary *dict = nil;
	if(responseData != nil) {
		dict = [[CJSONDeserializer deserializer] deserialize:responseData error:nil];
	} else {
		NSLog(@"Failed to get updates");
	}
	
	return dict;	
}

-(id)apiPostToMethod:(NSString*)method withParams:(NSString*)params deserialize:(BOOL)deserialize {
	NSURL *url = [NSURL URLWithString:[MDNSAPIRoot stringByAppendingFormat:@"%@?api.key=%@", method, self.apiKey]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setTimeoutInterval:30];

	NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:data];
	
	NSError *err; 
	NSURLResponse *response;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];

	id dict = nil;
	if(responseData != nil) {
		if(deserialize) {
			dict = [[CJSONDeserializer deserializer] deserialize:responseData error:nil];
		} else {
			dict = [NSString stringWithUTF8String:[responseData bytes]];
		}
	} else {
		NSLog(@"Failed to get updates");
	}
	
	return dict;
}

@end
