//
// Copyright 2013 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "DestinationInfo.h"

static NSDictionary *ParsePairsFromDestinationString(NSString *destinationString, NSString **errorMessage)
{
  NSMutableDictionary *resultBuilder = [[[NSMutableDictionary alloc] init] autorelease];

  // Might need to do this well later on. Right now though, just blindly split on the comma.
  NSArray *components = [destinationString componentsSeparatedByString:@","];
  for (NSString *component in components) {
    NSError *error = nil;
    NSString *pattern = @"^\\s*([^=]*)=([^=]*)\\s*$";
    NSRegularExpression *re = [[[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error] autorelease];
    if (error) {
      *errorMessage = [NSString stringWithFormat:@"Error while creating regex with pattern '%@'. Reason: '%@'.", pattern, [error localizedFailureReason]];
      return nil;
    }
    NSArray *matches = [re matchesInString:component options:0 range:NSMakeRange(0, [component length])];
    NSCAssert(matches, @"Apple's documentation states that the above call will never return nil.");
    if ([matches count] != 1) {
      *errorMessage = [NSString stringWithFormat:@"The string '%@' is formatted badly. It should be KEY=VALUE. "
                       @"The number of matches with regex '%@' was %llu.",
                       component, pattern, (long long unsigned)[matches count]];
      return nil;
    }
    NSTextCheckingResult *match = matches[0];
    if ([match numberOfRanges] != 3) {
      *errorMessage = [NSString stringWithFormat:@"The string '%@' is formatted badly. It should be KEY=VALUE. "
                       @"The number of ranges with regex '%@' was %llu.",
                       component, pattern, (long long unsigned)[match numberOfRanges]];
      return nil;
    }
    NSString *lhs = [component substringWithRange:[match rangeAtIndex:1]];
    NSString *rhs = [component substringWithRange:[match rangeAtIndex:2]];
    resultBuilder[lhs] = rhs;
  }

  return resultBuilder;
}


@implementation DestinationInfo

+ (instancetype)parseFromString:(NSString *)str error:(NSString **)error
{
  NSString *parsePairsError = nil;
  NSDictionary *pairs = ParsePairsFromDestinationString(str, &parsePairsError);

  if (parsePairsError) {
    *error = parsePairsError;
    return nil;
  }

  DestinationInfo *di = [[[DestinationInfo alloc] init] autorelease];

  di.arch = pairs[@"arch"];
  di.identifier = pairs[@"id"];
  di.name = pairs[@"name"];
  di.platform = pairs[@"platform"];
  di.os = pairs[@"OS"];

  return di;
}

- (void)dealloc
{
  [_arch release];
  [_identifier release];
  [_name release];
  [_platform release];
  [_os release];
  [super dealloc];
}

@end