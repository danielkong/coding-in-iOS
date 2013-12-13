#import "NSObject+CVJSON.h"

@implementation NSObject (JSON)

-(NSString*)jsonValue {
    NSString *json = @"";
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        if(!error) {
            json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //NSLog(@"json data:%@",json);
        }
        else
            NSLog(@"JSON parse error: %@", error);
    }
    else
        NSLog(@"Not a valid JSON object: %@", self);
    return json;
}

@end