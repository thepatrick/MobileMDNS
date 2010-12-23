//
//  TextFieldCell.m
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 29/08/10.
//  Copyright 2010 Sharkey Media. All rights reserved.
//

#import "TextFieldCell.h"


@implementation TextFieldCell

@synthesize valueTextField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		CGRect	frame =  CGRectMake(92, 12, 200, 20);
		valueTextField = [[UITextField alloc] initWithFrame:frame];
		valueTextField.borderStyle = UITextBorderStyleNone;
		valueTextField.textColor = [UIColor blackColor];
		valueTextField.font = [UIFont systemFontOfSize:18.0];
		valueTextField.backgroundColor = [UIColor clearColor];
		valueTextField.returnKeyType = UIReturnKeyDone;
		valueTextField.backgroundColor = [UIColor clearColor];
		valueTextField.textAlignment = UITextAlignmentRight;
		[self addSubview:valueTextField];
		[valueTextField release];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[valueTextField release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	NSInteger width = rect.size.width;
	// These work well for iPad... may not work so great on iPhone?
	CGRect	frame =  CGRectMake(width / 2, 12, (width / 2) - 40, 20);
	[valueTextField setFrame:frame];
	[super drawRect:rect];
}


@end
