//
//  DomainRecordViewController.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 29/08/10.
//  Copyright (c) 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDNSModalDelegate.h"

@interface DomainRecordViewController : UITableViewController<UITextFieldDelegate> {

    NSDictionary *record;
	
	id<MDNSModalDelegate> delegate;
    
}

@property (nonatomic, retain) NSDictionary *record;
@property (nonatomic, assign) id<MDNSModalDelegate> delegate;

+drvcForRecord:(NSDictionary*)record;

@end