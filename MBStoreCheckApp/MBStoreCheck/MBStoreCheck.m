// MBStoreCheck.m
//
// Copyright (c) 2014 MBStoreCheck
//
// Created by Michael Babiy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MBStoreCheck.h"

@implementation MBStoreCheck

+ (instancetype)sharedStoreCheck
{
    static MBStoreCheck *sharedStoreCheck = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStoreCheck = [[[self class]alloc]init];
    });
    
    return sharedStoreCheck;
}

- (BOOL)isAuthorized
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:kUserAuthorized];
}

- (void)authorize
{
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kProductIdentifier]];
        request.delegate = self; [request start];
    } else {
        // Parental Control is enabled, cannot make a purchase!
    }
}

#pragma mark - SKProductsRequestDelegate

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // NSLog(@"Processing...");
                break;
                
            case SKPaymentTransactionStatePurchased:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kUserAuthorized];
                // NSLog(@"Purchase complete. Unlock the feature.");
                break;
                
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // NSLog(@"Previous purchase restored...");
                break;
                
            case SKPaymentTransactionStateFailed:
                if (transaction.error.code != SKErrorPaymentCancelled) { NSLog(@"Error payment cancelled"); }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // NSLog(@"Purchase error.");
                break;
                
            default:
                break;
        }
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([response.products count]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:response.products[0]]]; // Transaction happening... cool.
    } else {
        // No products to purchase.
    }
}

@end
