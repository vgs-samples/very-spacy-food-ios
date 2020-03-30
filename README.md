# Very Spacy Food - VGSCollect iOS SDK showcase app.


Very Spacy Food is a food ordering demo application build with **VGSCollectSDK** for secure collecting credit cards data.


## How to run it?
### Requirements

- Installed latest <a href="https://apps.apple.com/us/app/xcode/id497799835?mt=12" target="_blank">Xcode</a>
- Installed <a href="https://guides.cocoapods.org/using/getting-started.html#installation" target="_blank">CocoaPods</a>
- Organization with <a href="https://www.verygoodsecurity.com/">VGS</a>


#### Step 1

Go to your <a href="https://dashboard.verygoodsecurity.com/" target="_blank">VGS organization</a> and establish <a href="https://www.verygoodsecurity.com/docs/getting-started/quick-integration#securing-inbound-connection" target="_blank">Inbound connection</a>. 

#### Step 2

Clone Very Spacy Food application repository.

``git@github.com:verygoodsecurity/very-spacy-food.git``

#### Step 3

Install application pods.

Open Terminal and change working directory to `Very Spacy Food` application folder:

`$ cd Very\ Spacy\ Food/`

Install pods:

`pod install`


#### Step 4

In `Very Spacy Food` folder find and open `Very Spacy Food.xcworkspace` file.
In the app go to `CollectCreditCardDataViewController.swift` file, find the line:

`let vaultId = "vaultId"`

and replace `vaultId` with your organization
 <a href="https://www.verygoodsecurity.com/docs/terminology/nomenclature#vault" target="_blank">vault id</a>. 
 
### Step 5 

Run the application.
Add some items to cart, then press **Add card data** button, you will be navigated to screnn with VGSCollect forms.
Type test card data(should include valid card number), e.x.:

``` swift

// Cardholder Name 
Joe Business

// Card Number   
4111111111111111

// Exp. Date  
11/22

//CVC code
123

```
Press **Save** button. Then data will be submitted to VGS.  
Go to the Logs tab on <a href="http://dashboard.verygoodsecurity.com" target="_blank">Dashboard</a>, find request and secure a payload.  
Instruction for this step you can find <a href="https://www.verygoodsecurity.com/docs/getting-started/quick-integration#securing-inbound-connection" target="_blank">here</a>.

### Step 6

Check examples how to integrate **VGSCollectSDK** into your app.

`CollectCreditCardDataViewController.swift`is build with VGSCollect Forms. You can check how to customise SDK UI elemetnts, observe field states(validation, card bin & last 4 numbers, card brand, etc), submit data to VGS. After you **submit** card data, VGS will return **alias** for each secured filed instead of raw data. Then you can use **alias** to store on your backend or make payments later.

`CheckoutViewController.swift` use not sensitive card data as card brand, card number bin and last 4 numbers to provide user info about his payment data. On **Pay** action app will send **alias** data to our test backend. For demo purpose backend actually do nothing but send "Success" in response if you reach it. 

Note that usually you shouldn't make payment request to payment provider directly from your production app. For sequrity reasons payment requests should be done from your backend. On payment request **alias** will go through **VGS forward proxy**. More information how to setup **Outbound** request from your backend is described <a href="https://www.verygoodsecurity.com/docs/guides/outbound-connection" target="_blank"> here</a> 

### Useful links

- <a href="https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk/index" target="_blank">Documentation</a> 
- <a href="https://github.com/verygoodsecurity/vgs-collect-ios" target="_blank">Repo</a> 
- <a href="http://cocoapods.org/pods/VGSCollectSDK" target="_blank">CocoaPods</a> 
