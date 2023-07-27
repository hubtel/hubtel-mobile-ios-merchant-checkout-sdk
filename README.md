# Hubtel Checkout SDK  
This SDK is a checkout sdk where merchants can integrate into their application for successful payments.  
  
## Installation  
  
`Hubtel Checkout` is available through SPM. Support for CocoaPods will be added soon.
  
### Swift Package Manager  
1. File > Add Packages  
2. Add `https://hubtel@dev.azure.com/hubtel/Mobile-Apps/_git/SDK%20Card%20Not%20Present%20iOS`  
  
## Getting Started  
_Objects needed_  
1. **Sales Id**: Sales ID given to the merchant to use the sdk  
2. **Api Key**: Base64 encoded string of the customer’s id and password.  
3. **Callback Url**: A url provided by the merchant in order to be able to listen for callbacks from the payment api to know the status of payments.  
4. **PurchaseInfo**: Information about the purchase to process. Details are given in the next sub-section.  
5. **tintColor**: a UIColor of your choosing, or rather your design's.  
6. **Delegate Object**: an object that implements the `PaymentFinishedDelegate` inorder to get information about UI Changes from the sdk.  
7. **HubtelCheckoutDelegate**: this protocol requires you to set the **Sales Id**, **Api Key** and **Callback Url** in your `AppDelegate`.  
## PurchaseInfo  
| Properties | Explanation |  
|--|--|  
| **businessName** (optional) | The name of the vendor or service renderer the customer is trying to purchase from. |  
| **itemPrice** (required) | The price of the item or service the customer is trying to purchase from.|  
| **customersPhoneNumber** (required) | A required mobile number of the customer purchasing the item. |  
| **purchaseDescription** (optional)| An optional description attached to the purchase. |  
## Integration  
1. Add the library using SPM (CocoaPods will be supported soon).  
2. Import `Hubtel_Checkout in your `AppDelegate` file, and implement the `HubtelCheckoutDelegate` protocol.  
- This protocol requires you to implement three properties:  
- `salesID`  
- `apiKey `  
- `hubtelCheckoutCallbackUrl` like so:  
```swift  
extension AppDelegate: HubtelCheckoutDelegate {  
    var hubtelCheckoutCallbackUrl: String = "https://nethook.siqe/81bd4704-d87a-4177-913b-ec42533f51c2"  
    var salesId: String = "12691"  
    var apiKey: String = "R0UwajAzcjo5ZjAxMqhkOTk5ZmM0ODMxYjc3MWFhMpEzYTNjMThbNA=="  
}  
```  
3. Also, import the `CardNotPresentiOS` in the Controller you want to call the checkout function(s).  
On your pay button having all necessary info set, call `openController` for **controller presentation** like so:  
```swift  
CheckoutViewController.openController(with customController: UIViewController, purchaseInfo: PurchaseInfo, delegate: PaymentFinishedDelegate, tintColor: UIColor? = nil)
```  
The calling controller must implement the `finishedBankDelegate` protocol to be able to see the checkout status.  
The finishedBankDelegate protocol has a function with a single parameter value of type `PaymentStatus`  
`PaymentStatus`: An enum displaying the status of payment.  
### PaymentStatus Cases
`userCancelledPayment`: When the user closes the checkout page without performing any transaction.  
`paymentFailed`: When the user performs a transaction but payment fails.  
`paymentSuccessful`: When the user finally pays successfully.
`unknown`: When the user cancels transaction after payment attempt without checking status.
### Example  
```swift  
extension ViewController: PaymentFinishedDelegate {  
    func checkStatus(value: PaymentStatus) {  
    }
}
```
4. If you prefer push navigation, then use `pushController` instead like so:  
```swift  
CheckoutViewController.pushController(with navigationController: UINavigationController?, purchaseInfo: PurchaseInfo, delegate: finishedBankDelegate, tintColor: UIColor? = nil)  
```  
Similarly, you have to implement the `PaymentFinishedDelegate` protocol the same way as above.
