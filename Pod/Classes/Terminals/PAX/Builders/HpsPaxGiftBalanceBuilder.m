#import "HpsPaxGiftBalanceBuilder.h"

@implementation HpsPaxGiftBalanceBuilder

- (id)initWithDevice: (HpsPaxDevice*)paxDevice{
    self = [super init];
    if (self != nil)
    {
        device = paxDevice;
        self.currencyType = HpsCurrencyCodes_USD;
    }
    return self;
}

- (void) execute:(void(^)(HpsPaxGiftResponse*, NSError*))responseBlock{
    
    [self validate];
    
    NSMutableArray *subgroups = [[NSMutableArray alloc] init];
    
    HpsPaxAmountRequest *amounts = [[HpsPaxAmountRequest alloc] init];
    [subgroups addObject:amounts];
    
    HpsPaxAccountRequest *account = [[HpsPaxAccountRequest alloc] init];
    if (self.giftCard != nil) {
        account.accountNumber = self.giftCard.value;
    }
    [subgroups addObject:account];
    
    HpsPaxTraceRequest *traceRequest = [[HpsPaxTraceRequest alloc] init];
    traceRequest.referenceNumber = [NSString stringWithFormat:@"%d", self.referenceNumber];
    [subgroups addObject:traceRequest];
    
    [subgroups addObject:[[HpsPaxCashierSubGroup alloc] init]];
    
    HpsPaxExtDataSubGroup *extData = [[HpsPaxExtDataSubGroup alloc] init];
    [subgroups addObject:extData];
    
    NSString *messageId = self.currencyType == HpsCurrencyCodes_USD ? T06_DO_GIFT : T08_DO_LOYALTY;
    
    [device doGift:messageId withTxnType:PAX_TXN_TYPE_BALANCE andSubGroups:subgroups withResponseBlock:^(HpsPaxGiftResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            responseBlock(response, error);
        });
    }];
}

- (void) validate
{
    if (self.currencyType < 0) {
        @throw [NSException exceptionWithName:@"HpsPaxException" reason:@"currencyType is required." userInfo:nil];
    }
}

@end
