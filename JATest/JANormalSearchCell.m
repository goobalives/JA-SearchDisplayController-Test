//
//  JANormalSearchCell.m
//  JATest
//
//  Created by Simon Hall on 23/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import "JANormalSearchCell.h"

@implementation JANormalSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
