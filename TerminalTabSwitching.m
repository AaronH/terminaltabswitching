#import "JRSwizzle.h"

@implementation NSWindowController (Mine)
- (void)updateTabListMenu
{
	NSMenu* windowsMenu = [[NSApplication sharedApplication] windowsMenu];
	
	BOOL wasSeparator = FALSE;

	for(NSMenuItem* menuItem in [windowsMenu itemArray])
	{
		// makeKeyAndOrderFront switches windows based on COMMAND+NUMBER in Snow Leopard
		// When starting Terminal with a multi-window Window group, tabswitching will
		// fall down due to conflict.  Removing these items fixes the problem.
		// Ideally, you could switch their keyEquivelant to OPTION or something, 
		// but that is a project for another day.
		if([menuItem action] == @selector(selectRepresentedTabViewItem:) || [menuItem action] == @selector(makeKeyAndOrderFront:))
			[windowsMenu removeItem:menuItem];
		
		// remove duplicate separators that can appear in Snow Leopard
		// when removing menu items
		if ([menuItem isSeparatorItem]) {
			if (wasSeparator == TRUE) [windowsMenu removeItem:menuItem];
			wasSeparator = TRUE;
		}
		else wasSeparator = FALSE;
		

	}

	NSArray* tabViewItems = [[self valueForKey:@"tabView"] tabViewItems];
	for(size_t tabIndex = 0; tabIndex < [tabViewItems count]; ++tabIndex)
	{
		NSString* keyEquivalent = (tabIndex < 10) ? [NSString stringWithFormat:@"%d", (tabIndex+1)%10] : @"";
		NSTabViewItem* tabViewItem = [tabViewItems objectAtIndex:tabIndex];
		NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:[tabViewItem label]
                                                        action:@selector(selectRepresentedTabViewItem:)
                                                 keyEquivalent:keyEquivalent];
		[menuItem setRepresentedObject:tabViewItem];
		[windowsMenu addItem:menuItem];
		[menuItem release];
	}
}

- (void)TerminalTabSwitching_windowDidBecomeMain:(id)fp8;
{
	[self TerminalTabSwitching_windowDidBecomeMain:fp8];
	[self updateTabListMenu];
}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView*)aTabView
{
	[self updateTabListMenu];
}

- (void)TerminalTabSwitching_awakeFromNib;
{
	[[NSApplication sharedApplication] removeWindowsItem:[self window]];
	[[self window] setExcludedFromWindowsMenu:YES];
	[self TerminalTabSwitching_awakeFromNib];
}

- (void)TerminalTabSwitching_newTab:(id)fp8;
{
	[self TerminalTabSwitching_newTab:fp8];
	[self updateTabListMenu];
}
- (void)TerminalTabSwitching_mergeAllWindows:(id)fp8;
{
	[self TerminalTabSwitching_mergeAllWindows:fp8];
	[self updateTabListMenu];
}
- (void)selectRepresentedTabViewItem:(NSMenuItem*)item
{
	NSTabViewItem* tabViewItem = [item representedObject];
	[[tabViewItem tabView] selectTabViewItem:tabViewItem];
}
@end

@interface TerminalTabSwitching : NSObject
@end

@implementation TerminalTabSwitching
+ (void)load
{
	[[[NSApplication sharedApplication] windowsMenu] addItem:[NSMenuItem separatorItem]];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(windowDidBecomeMain:) withMethod:@selector(TerminalTabSwitching_windowDidBecomeMain:) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(awakeFromNib) withMethod:@selector(TerminalTabSwitching_awakeFromNib) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(newTab:) withMethod:@selector(TerminalTabSwitching_newTab:) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(mergeAllWindows:) withMethod:@selector(TerminalTabSwitching_mergeAllWindows:) error:NULL];
}
@end
