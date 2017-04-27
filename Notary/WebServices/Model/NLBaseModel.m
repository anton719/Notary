
#import "NLBaseModel.h"
#import "NLCommon.h"
#import "TServices+CoreDataClass.h"
#import "TAppointments+CoreDataClass.h"
#import "TUser+CoreDataClass.h"
#import <RestKit/RestKit.h>
#import <MagicalRecord/MagicalRecord.h>
#import "NLLogin.h"
#import "NLAvailability.h"


@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end

@implementation NLBaseModel : NSObject 

RKResponseDescriptor *newResponseDescriptor(RKEntityMapping* entityMapping, RKRequestMethod requestMethod, NSString *pathPattern, NSString *keyPath, RKStatusCodeClass statusCodeClass)
{
    return [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                        method:requestMethod
                                                   pathPattern:pathPattern
                                                       keyPath:keyPath
                                                   statusCodes:RKStatusCodeIndexSetForClass(statusCodeClass)];
}

RKResponseDescriptor *newObjectDescriptor(RKObjectMapping* objectMapping, RKRequestMethod requestMethod, NSString *pathPattern, NSString *keyPath, RKStatusCodeClass statusCodeClass)
{
    return [RKResponseDescriptor responseDescriptorWithMapping:objectMapping
                                                        method:requestMethod
                                                   pathPattern:pathPattern
                                                       keyPath:keyPath
                                                   statusCodes:RKStatusCodeIndexSetForClass(statusCodeClass)];
}

+ (void)modelSetup
{

    RKLogConfigureByName("*", RKLogLevelError);
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelError];

    NSDictionary *options = @{
                              NSSQLitePragmasOption :@{ @"journal_mode": @"DELETE" }
                              };
    


    NSURL *storeUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",KDBName]];

    NSLog(@"here :%@" , storeUrl);
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:KDBName /*[self.dateSource modelDatabaseName]*/ ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    [managedObjectStore createPersistentStoreCoordinator];
    [managedObjectStore.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:nil];
    [managedObjectStore createManagedObjectContexts];

    
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:managedObjectStore.mainQueueManagedObjectContext];

    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:KAPIUrl]];//[self.dateSource modelBadeUrl]]];
    [RKObjectManager setSharedManager:objectManager];
    objectManager.managedObjectStore = managedObjectStore;
    
//    NSString *tkn = NLCommon.shared.s_access_token;
//    if(tkn.length)
//    {
//        [RKObjectManager.sharedManager.HTTPClient setDefaultHeader:@"s_access_token" value:tkn];
//    }
    
    // Construct our own NSDateFormatter
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter  setDateFormat:@"yyyy-MM-dd"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated"
    [RKObjectMapping addDefaultDateFormatter:dateFormatter];
    #pragma clang diagnostic pop
    
    

    RKEntityMapping *TUserLoginRequestMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([TUser class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [TUserLoginRequestMapping addAttributeMappingsFromDictionary: @{
                                                                    @"@metadata.query.parameters.nationalID" : @"s_national_id",
                                                                    @"@metadata.query.parameters.mobile" : @"s_mobile",
                                                                    @"refGuid" : @"s_access_token"
                                                                    }
     ];
    TUserLoginRequestMapping.identificationAttributes = @[ @"s_national_id" ];
    
    
    RKEntityMapping *TUserLoginCompleteMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([TUser class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [TUserLoginCompleteMapping addAttributeMappingsFromDictionary: @{
                                                                    @"repID": @"pk_i_id",
                                                                    @"@metadata.query.parameters.nationalID" : @"s_national_id",
                                                                    @"@metadata.query.parameters.mobile" : @"s_mobile",
                                                                    @"@metadata.query.parameters.refGuid" : @"s_access_token"
                                                                    }
     ];
    TUserLoginCompleteMapping.identificationAttributes = @[ @"s_national_id" ];
    
    
    //TAppointmentsMapping
    RKEntityMapping *TAppointmentsMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([TAppointments class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    [TAppointmentsMapping addAttributeMappingsFromDictionary:@{
                                                               @"AppointmentID" : @"pk_i_id",
                                                               @"Lat" : @"d_lat",
                                                               @"Lng" : @"d_lng",
                                                               @"ServiceID" : @"fk_i_service_id",
                                                               @"DateTime" : @"s_datetime",
                                                               @"NumberOfBeneficiaries" : @"i_beneficiaries_count",
                                                               @"IsUpcoming" : @"b_upcoming",
                                                               @"IsCancelled" : @"b_cancelled"
                                                               }
     ];
    TAppointmentsMapping.identificationAttributes = @[ @"pk_i_id" ];
    //
    
    
    
    //TServicesMapping
    RKEntityMapping *TServicesMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([TServices class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [TServicesMapping addAttributeMappingsFromDictionary: @{
                                                            @"ServiceID" : @"pk_i_id",
                                                            @"ServiceArabicName" : @"s_name_ar",
                                                            @"ServiceEnglishName" : @"s_name_en"
                                                            }
     ];
    TServicesMapping.identificationAttributes = @[ @"pk_i_id" ];
    //
    
    

    //NLLoginMapping
    RKObjectMapping *NLLoginMapping = [RKObjectMapping mappingForClass:[NLLogin class]];
    
    [NLLoginMapping
     addAttributeMappingsFromDictionary:
     @{
       
       }
     ];
    
    //
    
    
    //NLLoginMapping
    RKObjectMapping *NLAvailabilityMapping = [RKObjectMapping mappingForClass:[NLAvailability class]];
    
    [NLAvailabilityMapping
     addAttributeMappingsFromDictionary:
     @{
       
       }
     ];
    
    //
    
    
    
    
//    [TPaymentInfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"methods" toKeyPath:@"methods" withMapping:TPaymentMethodsMapping]];
    
    [objectManager addResponseDescriptorsFromArray:@[
     // rep
     newObjectDescriptor(TUserLoginRequestMapping, RKRequestMethodGET, @"RepLoginRequest", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TUserLoginCompleteMapping, RKRequestMethodGET, @"RepLoginComplete", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"RepLoginComplete", @"appointments", RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"RepListMyAppointments", @"appointments", RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"RepListAvailableTimes", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"RepCancelAppointment", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"RepConfirmAppointment", nil, RKStatusCodeClassSuccessful),
     
     // client
     newObjectDescriptor(TUserLoginRequestMapping, RKRequestMethodGET, @"ClientListMyAppointments", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"ClientListMyAppointments", @"appointments", RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"ClientListAvailableTimes", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"ClientCancelAppointment", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TAppointmentsMapping, RKRequestMethodGET, @"ClientConfirmAppointment", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(NLLoginMapping, RKRequestMethodGET, @"ClientCheckEligibility", nil, RKStatusCodeClassSuccessful),
     
//     newObjectDescriptor(NLLoginMapping, RKRequestMethodGET, @"ValidateLocation", nil, RKStatusCodeClassSuccessful),
     newObjectDescriptor(TServicesMapping, RKRequestMethodGET, @"ListServices", @"services", RKStatusCodeClassSuccessful),
                                                     ]];
    
    
    
    RKObjectMapping *paginationMapping = [RKObjectMapping mappingForClass:[RKPaginator class]];
    NSDictionary *paginationMappingDic = @{
                                          @"i_per_page"         :  @"perPage",
                                          @"i_total_pages"      :  @"pageCount",
                                          @"i_total_objects"    :  @"objectCount",
                                          };
    [paginationMapping addAttributeMappingsFromDictionary:paginationMappingDic];
    [[RKObjectManager sharedManager] setPaginationMapping:paginationMapping];
    
}

@end
