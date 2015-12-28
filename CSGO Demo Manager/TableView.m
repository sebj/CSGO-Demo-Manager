
//  TableView.m

//  Created by Sebastian Jachec on 05/04/2015.
//  Copyright (c) Sebastian Jachec. All rights reserved.

#import "TableView.h"
#import <objc/runtime.h>

@implementation TableView: NSTableView

- (void)mouseDown:(NSEvent *)event {
    
    NSPoint mousePoint = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];
    
    [super mouseDown:event];
    
    if (row == UINT64_MAX) {
        row = -1;
        [self deselectAll:nil];
        
    } else {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:shouldSelectRow:)])
        [self.delegate tableView:self shouldSelectRow:row];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint mousePoint = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger row  = [self rowAtPoint:mousePoint];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:shouldSelectRow:)])
        [self.delegate tableView:self shouldSelectRow:row];
    
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    objc_setAssociatedObject(self, @selector(rightClickedColumn), @([self columnAtPoint:mousePoint]), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, @selector(rightClickedRow), @(row), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return self.menu;
}

- (NSInteger)rightClickedColumn {
    return [objc_getAssociatedObject(self, @selector(rightClickedColumn)) integerValue];
}

- (NSInteger)rightClickedRow {
    return [objc_getAssociatedObject(self, @selector(rightClickedRow)) integerValue];
}

@end
