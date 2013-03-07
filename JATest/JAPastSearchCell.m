//
//  JAPastSearchCell.m
//  JATest
//
//  Created by Simon Hall on 23/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#import "JAPastSearchCell.h"

@implementation JAPastSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self textLabel] setFont:[UIFont fontWithName:@"TrebuchetMS-Italic" size:18]];
        [[self detailTextLabel] setText:@"Here"];
        [[self imageView] setImage:[UIImage imageNamed:@"06-magnify.png"]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
