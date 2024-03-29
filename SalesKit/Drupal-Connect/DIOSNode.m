//  DIOSNode.m
//
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is Kyle Browning, released June 27, 2010.
//
// The Initial Developer of the Original Code is
// Kyle Browning
// Portions created by the Initial Developer are Copyright (C) 2010
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//
// Alternatively, the contents of this file may be used under the terms of
// the GNU General Public License Version 2 or later (the "GPL"), in which
// case the provisions of the GPL are applicable instead of those above. If
// you wish to allow use of your version of this file only under the terms of
// the GPL and not to allow others to use your version of this file under the
// MPL, indicate your decision by deleting the provisions above and replacing
// them with the notice and other provisions required by the GPL. If you do
// not delete the provisions above, a recipient may use your version of this
// file under either the MPL or the GPL.
//
// ***** END LICENSE BLOCK *****
#import "DIOSNode.h"


@implementation DIOSNode
-(id) init {
    [super init];
    return self;
}
-(NSDictionary *) nodeDelete:(NSString *)nid {
  [self setMethod:@"node.delete"];
  [self setRequestMethod:@"DELETE"];
  [self setMethodUrl:[NSString stringWithFormat:@"node/%@", nid]];
  [self runMethod];
  return [self connResult];
}
-(NSDictionary *) nodeGet:(NSString *)nid {
  [self setMethod:@"node.get"];
  [self setRequestMethod:@"GET"];
  [self setMethodUrl:[NSString stringWithFormat:@"node/%@", nid]];
  [self runMethod];
   return [self connResult];
}

-(NSDictionary *) nodeGetWithType:(NSString *)type pageSize:(NSInteger)pz page:(NSInteger)p {
    
    NSString *url = [@"node?" stringByAppendingFormat:@"parameters[type]=%@&pagesize=%i&page=%i", type, pz, p];
    [self setMethod:@"node.get"];
    [self setRequestMethod:@"GET"];
    [self setMethodUrl:url];
    
    [self runMethod];
    return [self connResult];
}

-(NSDictionary *) nodeSave:(NSMutableDictionary *)node {
  [self setMethod:@"node.save"];
  [self setMethodUrl:@"node"];
  if ([[[self userInfo] objectForKey:@"uid"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
    [node setObject:@"" forKey:@"name"];
  } else if([self userInfo] == nil){
    [node setObject:@"" forKey:@"name"];
  } else {
    [node setObject:[[self userInfo] objectForKey:@"name"] forKey:@"name"];
  }
  if ([node objectForKey:@"nid"] != nil && ![[node objectForKey:@"nid"] isEqualToString:@""]) {
    [self setMethodUrl:[NSString stringWithFormat:@"node/%@", [node objectForKey:@"nid"]]];
    [self setRequestMethod:@"PUT"];
  }
  [self addParam:node forKey:@"node"]; 
  [self runMethod];
  return [self connResult];
}
-(NSDictionary *) nodeGetIndex {
  [self setMethod:@"node.get"];
  [self setRequestMethod:@"GET"];
  [self setMethodUrl:[NSString stringWithFormat:@"node"]];
  [self runMethod];
  return [self connResult];
}
- (void) dealloc {
    [super dealloc];
  
}
@end
