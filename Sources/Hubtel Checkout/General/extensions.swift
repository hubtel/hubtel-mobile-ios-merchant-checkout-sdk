//
//  File.swift
//  
//
//  Created by Mark Amoah on 5/29/23.
//

import Foundation
import UIKit


typealias AnalyticsItem = [String: String]
typealias AnalyticsItemClone = [String: Any]

class ProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIViewController{
    
    func showProgress(isCancellable:Bool = true, cancelCallback:(()->Void)? = nil) -> UIAlertController {
        let indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView.startAnimating()
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        customView.addSubview(indicatorView)
        indicatorView.center = customView.center
        let label = UILabel()
        label.text = "Please Wait"
        label.font = FontManager.getAppFont(size: .m3, weight: .bold)
        label.sizeToFit()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        customView.frame.origin = CGPoint(x: 110, y: 10)
        label.frame.origin = CGPoint(x: 270/2 - (label.frame.width / 2), y: 54)
        alert.view.addSubview(customView)
        alert.view.addSubview(label)
        let progressViewController = ProgressViewController()
        progressViewController.preferredContentSize.height = 100
        alert.setValue(progressViewController, forKey: "contentViewController")
        if isCancellable {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                cancelCallback?()
            }))
        }
        
        self.present(alert, animated: true)
        
        return alert
    }
    
    func showAlert(with title: String="", message: String = "", handler: ((UIAlertAction)->())? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


extension String{
    func getExpiryInfo()->(month:String, year:String)?{
        guard self.contains("/") else {return nil}
        let splitExpiry = self.split(separator: "/")
        let expiryYear = "20" + splitExpiry[1]
        let expiryMonth = String(splitExpiry[0])
        return (expiryMonth, expiryYear)
    }
    
    func shouldNotContainumbers()->Bool{
        let numbers = Set("0123456789")
        if (self.filter {numbers.contains($0)}).count > 0 {
                   return false
               }
        return true
    }
    
    func generateFormattedPhoneNumber()->Self{
        if self.hasPrefix("0"){
            return "233" + self.dropFirst()
        }
        return self
    }
    
    func wordCased()->String{
        return self.split(separator: "_").compactMap {
                    $0.capitalized
                }
                .joined(separator: " ")
    }
    
    
    func pascalize(separator:String = "_")->String{
        let words = self.components(separatedBy: separator)
        let firstLetter = self.prefix(1).lowercased()
        let pascal = "\(firstLetter)\((words.map ({ $0.capitalized }).reduce("",+)).dropFirst())"
        return pascal
    }
    
    func getEventType() ->AppEventType {
        if self.contains("__view__") {
            return .view
        }
        
        if self.contains("__tap__") {
            return .tap
        }
        return .other
    }
    
    
    
}

extension Double {
    func roundValue(toPlaces places:Int = 4) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        
    }
}

extension UserDefaults{
    func decodeTheData<T:NSObject & NSCoding>(forKey key: String)->T?{
        guard let data = self.object(forKey: key) as? Data else {return nil}
        let myUnarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data)
        return myUnarchivedData
    }
}


extension NSMutableAttributedString {
    
    @discardableResult func generic(_ text:String,front: UIFont,color:UIColor = .black,otherAttributes : [NSAttributedString.Key:AnyObject] = [:]) -> NSMutableAttributedString {
        var attrs = [NSAttributedString.Key: AnyObject]()
        attrs[NSAttributedString.Key.font] = front
        attrs[NSAttributedString.Key.foregroundColor] = color
        for  (key , value) in  otherAttributes {
            attrs[key] = value
        }
        let smallString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(smallString)
        return self
    }

}
extension UIViewController{
    var alertWidth: CGFloat{
        return UIScreen.main.bounds.width - 10
    }
    var alertHeight: CGFloat{
        return 150
    }
}


extension CheckoutViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: 30))
        label.text = PaymentOptions.providerOptions[row].providerName
        label.text = Array(PaymentOptions.options.keys)[row]
        label.sizeToFit()
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Array(PaymentOptions.options.keys).count
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    
}


extension UIButton {
    func loadingIndicator(_ show: Bool, name: String) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            indicator.alpha = 1
            indicator.color = .black
            self.setTitle("", for: .normal)
//            let buttonHeight = self.bounds.height
//            let buttonWidth = self.bounds.size.width
//            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            self.setTitle(name, for: .normal)
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}


extension UIImageView{
    
    func setImage(with imageString: String){
        if #available(iOS 13.0, *) {
            image = UIImage(named: imageString, in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        }else{
         image = UIImage(named: imageString)
        }
    }
    
    
}

extension AnalyticsItem{
    func pascalKeys() -> AnalyticsItem {
        var item : AnalyticsItem = [:]
        
        for (key,value) in self {
            item[key.pascalize(separator: " ")] = value
        }
        return item
    }
}



    extension Array {
        func getSafely(index: Int) -> Element? {
            guard index >= 0, index < endIndex else {
                return nil
            }

            return self[index]
        }
    }

extension String{
    func getPaymentChannelString()->String{
        switch self{
        case "vodafone-gh":
            return "Vodafone Ghana"
        case "mtn-gh":
            return "MTN Mobile Money"
        case "tigo-gh":
            return "Airtel Tigo"
        default:
            return ""
        }
    }
}



extension UIImageView {
    func downloadImage(from urlString: String, contentMode: UIView.ContentMode = .scaleAspectFit, completion: ((UIImage?) -> Void)? = nil) {
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion?(nil)
            return
        }

        // Create a URLSession task to download the image data
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for errors
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }

            // Ensure we have data and can create an image from it
            if let data = data, let image = UIImage(data: data) {
                // Update the image view on the main thread
                DispatchQueue.main.async {
                    self.image = image
                    self.contentMode = contentMode
                    completion?(image)
                }
            } else {
                print("Invalid data or unable to create image from data.")
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }.resume()
    }
}

