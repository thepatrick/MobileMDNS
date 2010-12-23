//
//  TextFieldCell.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 29/08/10.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextFieldCell : UITableViewCell {

	UITextField *valueTextField;
	
}

@property (readonly) UITextField *valueTextField;

@end
