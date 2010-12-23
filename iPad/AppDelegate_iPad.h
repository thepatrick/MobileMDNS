//
//  AppDelegate_iPad.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright Patrick Quinn-Graham 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DomainViewController;
@class DomainListViewController;

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UISplitViewController *splitViewController;
	
	DomainListViewController *domainListViewController;
	DomainViewController *domainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet DomainListViewController *domainListViewController;
@property (nonatomic, retain) IBOutlet DomainViewController *domainViewController;

@end

