
//  TableView.h

//  Created by Sebastian Jachec on 05/04/2015.
//  Copyright (c) Sebastian Jachec. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface TableView : NSTableView

/**
 * The index of the column the user right-clicked.
 */
- (NSInteger)rightClickedColumn;

/**
 * The index of the row the user right-clicked.
 */
- (NSInteger)rightClickedRow;

@end
