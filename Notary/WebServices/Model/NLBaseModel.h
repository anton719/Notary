

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

#define KDBName @"Notary"
#define KAPIUrl @"https://mojmnp.azurewebsites.net/Apps/"

@interface NLBaseModel : NSObject

RKResponseDescriptor *newResponseDescriptor(RKEntityMapping* entityMapping, RKRequestMethod requestMethod, NSString *pathPattern, NSString *keyPath, RKStatusCodeClass statusCodeClass);


RKResponseDescriptor *newObjectDescriptor(RKObjectMapping* objectMapping, RKRequestMethod requestMethod, NSString *pathPattern, NSString *keyPath, RKStatusCodeClass statusCodeClass);

+ (void)modelSetup;

@end
