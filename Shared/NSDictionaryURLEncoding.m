//
//  NSDictionaryURLEncoding.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 24/12/10.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import "NSDictionaryURLEncoding.h"

@implementation NSDictionary(URLEncoding)

-(NSString *)urlEncoded {
	NSString *key;
	NSObject *value;
	NSString *escapedKey;
	NSString *escapedValue;
	
	NSMutableString *result = [NSMutableString stringWithCapacity: 64];
	
	BOOL first = YES;
	
	for(key in [self allKeys]) {
		if (first) {
			first = NO;
		} else {
			[result appendString: @"&"];
		}		
		
		value = [self objectForKey:key]; 
		escapedValue = [[NSString stringWithFormat:@"%@", value] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		escapedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[result appendString: [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue]];
	}
	return result;
}

@end