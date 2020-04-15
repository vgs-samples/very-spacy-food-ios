

# Very Spacy Food <br/> VGS Collect iOS SDK Showcase Application 


Very Spacy Food is a food ordering demo application build with [VGSCollectSDK](https://github.com/verygoodsecurity/vgs-collect-ios) for secure collecting credit cards data.

<p align="center">
<img src="https://github.com/verygoodsecurity/very-spacy-food/blob/master/app_order_screen.png" width="200">    <img src="https://github.com/verygoodsecurity/very-spacy-food/blob/master/app_collect_card_data_screen.png" width="200">    <img src="https://github.com/verygoodsecurity/very-spacy-food/blob/master/app_confirmation_screen.png" width="200">
</p>

## How to run it?
### Requirements

- Installed latest <a href="https://apps.apple.com/us/app/xcode/id497799835?mt=12" target="_blank">Xcode</a>
- Installed latest <a href="https://guides.cocoapods.org/using/getting-started.html#installation" target="_blank">CocoaPods</a>
- Organization with <a href="https://www.verygoodsecurity.com/">VGS</a>


#### Step 1

Go to your <a href="https://dashboard.verygoodsecurity.com/" target="_blank">VGS organization</a> and establish <a href="https://www.verygoodsecurity.com/docs/getting-started/quick-integration#securing-inbound-connection" target="_blank">Inbound connection</a>. For this demo you can import pre-built Routs configuration:

<p align="center">
<img src="https://github.com/verygoodsecurity/very-spacy-food/blob/master/dashboard_routs.png" width="600">
</p>

-  Inside the app repository find **configuration.yaml** file and download it.
-  On the <a href="https://dashboard.verygoodsecurity.com/" target="_blank">Dashboard</a> screen go to the **Routs** section and selet **Inbound** Tab. 
-  At the right corner you will see **Manage** button. Press it and select **Import YAML file**, then choose **configuration.yaml** that you just download and **Save** the Rout.
-  Now the cards data you send by VGSCollectSDK will be secured.


#### Step 2

Clone Very Spacy Food application repository.

``git@github.com:verygoodsecurity/very-spacy-food.git``

#### Step 3

Install application pods.

Open Terminal and change working directory to `Very Spacy Food` application folder:

    $ cd very-spacy-food

Install pods:

    pod install

If you already try the app before, you can check for pod updates to get the latest SDK version. In Terminal run the command:

    pod update


#### Step 4

In `Very Spacy Food` folder find and open with Xcode `Very Spacy Food.xcworkspace` file (not - `Very Spacy Food.xcodeproj`).
In the app go to `CollectCreditCardDataViewController.swift` file, find the line:

    let vaultId = "vaultId"

and replace `vaultId` with your organization
 <a href="https://www.verygoodsecurity.com/docs/terminology/nomenclature#vault" target="_blank">vault id</a>. 
 
### Step 5 

Run the application and try to order some Very Spacy Food.</br>

#### When on Add Credit Card Data sceen

You can use test credit card data to make the order, e.x.:

``` swift

/// Cardholder Name 
Joe Business

/// Card Number   
4111111111111111

/// Exp. Date  
11/22

/// CVC code
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
- <a href="https://verygoodsecurity.github.io/vgs-collect-ios/" target="_blank">VGSCollectSDK API References</a> 
- <a href="https://github.com/verygoodsecurity/vgs-collect-ios" target="_blank">VGSCollectSDK GitHub Repo</a> 
- <a href="http://cocoapods.org/pods/VGSCollectSDK" target="_blank">CocoaPods</a> 
