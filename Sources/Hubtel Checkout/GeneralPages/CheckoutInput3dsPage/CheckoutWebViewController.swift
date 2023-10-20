//
//  CheckoutWebViewController.swift
//  
//
//  Created by Mark Amoah on 5/3/23.
//

import UIKit
import WebKit

enum CheckoutState{
    case startState
    case endState
}

public protocol PaymentFinishedDelegate: AnyObject{
    func checkStatus(value: PaymentStatus)
}



class CheckoutWebViewController: UIViewController {
    lazy var viewModel = CheckoutWebViewViewModel(delegate: self)
    var progress: UIAlertController?
    var makeEnrollment2: Bool = true
    
    static func openWebViewForPayment(parentController: UIViewController, setupResponse: Setup3dsResponse?, with authKey: String, delegate: PaymentFinishedDelegate?, usePresentation: Bool = false){
        let controller = CheckoutWebViewController()
        controller.setup3dsResponse = setupResponse
        controller.authKey = authKey
        controller.delegate = delegate
        controller.parentController = parentController
        if !usePresentation{
            controller.modalPresentationStyle = .overFullScreen
            
        }
        controller.presentationController?.delegate = ModalPresentationDelegate.shared
        parentController.present(controller, animated: true)
    }
    
    let redirect3dsCollectionSuccessUrl = "https://hubtelappproxy.hubtel.com/3ds/collection/Success/redirect/";
    let terminalOutputName = "console"
    var setup3dsResponse: Setup3dsResponse?
    var completion: ((CheckoutState, Bool)->())?
    var authKey: String?
    var makeEnrollment: Bool = false
    weak var delegate: PaymentFinishedDelegate?
    let salesId: String? = UserSetupRequirements.shared.salesID
    var parentController: UIViewController?
    
    
    lazy var titleLabelTextView: UILabel = {
        var view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        // Contacting your bank for additional verification
        let attributed = NSMutableAttributedString()
            .generic("Contacting your bank for additional verification\n", front: .systemFont(ofSize: 16, weight: .bold))
            .generic("You will have to provide a correct token to proceed.\nScroll to the bottom if you cannot see the CONTINUE button", front: .systemFont(ofSize: 14, weight: .regular))

        view.numberOfLines = 0
        view.attributedText = attributed
        view.textAlignment = .center
        return view
    }()
    
    lazy var webView: WKWebView = {
        let view  = WKWebView(frame: .zero, configuration: getWKWebViewConfiguration())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = FontManager.getAppFont(size: .m3)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelModal(_:)), for: .primaryActionTriggered)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabelTextView)
        view.addSubview(webView)
        view.addSubview(cancelButton)
        view.backgroundColor = .white
        view.alpha = 0
        setupConstraints()
        loadPage()
        title = Strings.confirmOrder
    }
    
    @objc func cancelModal(_ sender: UIButton){
        self.dismiss(animated: true)
    }
    
    
    func setupConstraints(){
        let cancelButtonConstraints = [cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16), cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)]
        NSLayoutConstraint.activate(cancelButtonConstraints)
        
        let titleTextViewConstraints = [titleLabelTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10), titleLabelTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10), titleLabelTextView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 16)]
        NSLayoutConstraint.activate(titleTextViewConstraints)
        let webViewConstraints = [webView.leadingAnchor.constraint(equalTo: view.leadingAnchor), webView.trailingAnchor.constraint(equalTo: view.trailingAnchor), webView.topAnchor.constraint(equalTo: titleLabelTextView.bottomAnchor), webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)]
        
        NSLayoutConstraint.activate(webViewConstraints)
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()
        userController.add(self, name: terminalOutputName)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        return configuration
    }
    
    func loadPage(){
        
        webView.loadHTMLString(makeHtmlString(accessToken: setup3dsResponse?.accessToken ?? ""), baseURL: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progress = self.showNetworkCallProgress(){
            self.dismiss(animated: true)
        }
        AnalyticsHelper.recordCheckoutEvent(event: .checkout3DsBrowserViewPage3DsBrowser)
    }
    
    func makeHtmlString(accessToken: String) -> String {
        return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta http-equiv="X-UA-Compatible" content="IE=edge">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title></title>
                </head>
                <body>
                <iframe id="cardinal_collection_iframe" name="collectionIframe" height="10" width="10"
                        style="display: none;">
                </iframe>
                <form id="cardinal_collection_form"
                      method="POST" target="collectionIframe"
                      action="https://centinelapi.cardinalcommerce.com/V1/Cruise/Collect">
                    <input id="cardinal_collection_form_input"
                           type="hidden" name="JWT"
                           value="\(accessToken)">
                </form>
                </body>
                <script>
                    window.onload = function () {
                        var cardinalCollectionForm = document.querySelector('#cardinal_collection_form');
                        if (cardinalCollectionForm) {
                         cardinalCollectionForm.submit();
                         }
                    }
                    
                    window.addEventListener("message", function (event) {
                        if (event.origin === "https://centinelapi.cardinalcommerce.com") {
                            console.log(event.data);
                            window.webkit.messageHandlers.console.postMessage(event.data);
                        }
                    }, false);
            </script>
        </html>
"""
    }
  

}


extension CheckoutWebViewController: WKScriptMessageHandler, WKNavigationDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "console" && (message.body as? String) == "https://cybersourcecallbacks.hubtel.com"{
//            showAlert(with: "Success", message: "Your payment is being processed. Click ok to check payment status") { action in
                self.dismiss(animated: true){
                    CheckTransactionStatusViewController.openTransactionHistory(navController: self.parentController?.navigationController, transactionId: self.setup3dsResponse?.clientReference ?? "", text: Strings.directDebitText,delegate: self.delegate)
                }
//            }
        }
        
        
        if message.name == "console"{
            webView.stopLoading()
            print("entering here")
            if makeEnrollment2{
                viewModel.makeEnrollment(with: setup3dsResponse?.transactionId ?? "")
            }
            makeEnrollment2 = false
        }
        
       
    }
    

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WKWebView : didFail",error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WKWebView : didFailProvisionalNavigation",error.localizedDescription)
    }
    
    
    
    
    func continueCheckout(withOrderId orderId: String, andhubtelReference reference: String, jwt: String, customData: String? = nil )->String{
        let htmlString = """
  
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta http-equiv="X-UA-Compatible" content="IE=edge" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title></title>
      <style>
        iframe {
          display: block;
          border: none;
          height: 100vh;
          width: 100vw;
        }
      </style>
    </head>
    <body>
      <div>
        <iframe name="step-up-iframe"></iframe>
        <form
          id="step_up_form"
          target="step-up-iframe"
          method="POST"
          action="https://centinelapi.cardinalcommerce.com/V2/Cruise/StepUp"
        >
          <input
            name="JWT"
            class="form-control"
            type="hidden"
            value="\(jwt)"
          />
          <input id="md-input" type="hidden" name="MD" />
          <button class="btn btn-success" style="display: none">Step up</button>
        </form>
      </div>
      <script type="text/javascript">
                window.onload = function() {
          let mdInput = document.querySelector("#md-input");
          mdInput.value = `\(customData ?? "")`
          window.addEventListener("message", function handler(event) {
            window.webkit.messageHandlers.console.postMessage(event.origin)
            if (event.origin === "https://cybersourcecallbacks.hubtel.com") {
              window.webkit.messageHandlers.myMessageHandlersss.postMessage("done with payment");
              this.removeEventListener("message", handler);
            }
          });
          let stepUpForm = document.querySelector("#step_up_form");
          if (stepUpForm) {
            stepUpForm.submit();
          }
        }
      </script>
    </body>
  </html>

  
  """;
        
    return htmlString
        
    }
    
}

extension CheckoutWebViewController: CheckOutWebViewDelegate{
    
    func showLoaderWhileMakingNetworkRequest() {
//        progress = showProgress(isCancellable: true)
    }
    
    func open3dsPage() {
        
        progress?.dismiss(animated: true){
            
            if self.viewModel.enrollmentResponse?.cardStatus == CardStatus.authSuccessFull.rawValue{
                self.dismiss(animated: true){
                    CheckTransactionStatusViewController.openTransactionHistory(navController: self.parentController?.navigationController, transactionId: self.setup3dsResponse?.clientReference ?? "", text: "Checking Payment Status",delegate: self.delegate)
                }
                
                
            }else{
                self.webView.alpha = 1
                self.view.alpha = 1
                self.webView.loadHTMLString(self.continueCheckout(withOrderId: "", andhubtelReference: "", jwt: self.viewModel.enrollmentResponse?.jwt ?? "", customData: self.viewModel.enrollmentResponse?.customData ?? "" ), baseURL: nil)
            }
        }
    }
    
    func showNetworkErrorMessage(message: String) {
        progress?.dismiss(animated: true){
            self.showAlert(with: "Error", message: message){ action in
                self.dismiss(animated: true)
                
            }
        }
    }
}
