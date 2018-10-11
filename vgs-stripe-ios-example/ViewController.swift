//
//  ViewController.swift
//  vgs-stripe-ios-example
//
//  Created by andrew.slepakurov on 10/8/18.
//  Copyright © 2018 Very Good Security. All rights reserved.
//

import UIKit


class ViewController: UIViewController {


    //  Reverse
    @IBOutlet var creditCardName: UITextField!
    @IBOutlet var creditCardNumber: UITextField!
    @IBOutlet var creditCardExpiration: UITextField!
    @IBOutlet var creditCardCvv: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    //  Forward
    @IBOutlet var fCreditCardName: UITextField!
    @IBOutlet var fCreditCardNumber: UITextField!
    @IBOutlet var fCreditCardExpirationMonth: UITextField!
    @IBOutlet var fCreditCardExpirationYear: UITextField!
    @IBOutlet var fCreditCardCvv: UITextField!
    @IBOutlet weak var fSubmitButton: UIButton!

    var base64CredentialsReverse: String = "";
    var base64CredentialsForward: String = "";

    override func viewDidLoad() {
        super.viewDidLoad()
        let stripeReverseApi = ApiService.infoForKey("STRIPE_REVERSE_KEY")!
        let credentialData = "\(stripeReverseApi):".data(using: String.Encoding.utf8)!
        base64CredentialsReverse = credentialData.base64EncodedString(options: [])

        let stripeForwardApi = ApiService.infoForKey("STRIPE_FORWARD_KEY")!
        let fCredentialData = "\(stripeForwardApi):".data(using: String.Encoding.utf8)!
        base64CredentialsForward = fCredentialData.base64EncodedString(options: [])
        NSLog("Application loaded...")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        let tenantUrl = ApiService.infoForKey("PROXY_URL")!
        let schemaUrl = ApiService.infoForKey("PROXY_SCHEMA")!
        let stripeApiUrl = ApiService.infoForKey("STRIPE_URL")!
        if sender === submitButton {
            let httpBinUrl = ApiService.infoForKey("HTTPBIN_URL")!
            let expirationDateArr = creditCardExpiration.text!.split{$0 == "/"}
            let paramMap = ["card[number]": (creditCardNumber.text!), "card[exp_month]": String(expirationDateArr[0]), "card[exp_year]": String(expirationDateArr[1]), "card[cvc]": (creditCardCvv.text!)]
            ApiService.callPost(url: URL(string: schemaUrl + "://" + tenantUrl + httpBinUrl)!, params: paramMap,credentials: "", finish: finishPostTokenize)
            ApiService.callPost(url: URL(string: "https://api.stripe.com" + stripeApiUrl)!, params: paramMap, credentials: base64CredentialsReverse, finish: finishPostStripeToken)
        }
        if sender === fSubmitButton {
            let paramMap = ["card[number]": (fCreditCardNumber.text!), "card[exp_month]": (fCreditCardExpirationMonth.text!), "card[exp_year]": (fCreditCardExpirationYear.text!), "card[cvc]": (fCreditCardCvv.text!)]
            ApiService.callPostWithProxy(url: URL(string: "https://api.stripe.com" + stripeApiUrl)!, params: paramMap, credentials: base64CredentialsForward, finish: finishPrint)
        }
    }

    func finishPostTokenize(message: String, data: Data?) -> Void {
        if let json = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
            if let form = json["form"] as? [String: String] {
                DispatchQueue.main.async {
                    self.fCreditCardCvv.text = form["card[cvc]"]!
                    self.fCreditCardNumber.text = form["card[number]"]!
                    self.fCreditCardName.text = self.creditCardName.text
                    self.fCreditCardExpirationMonth.text = form["card[exp_month]"]!
                    self.fCreditCardExpirationYear.text = form["card[exp_year]"]!
                }
            }
        }
    }

    func finishPostStripeToken(message: String, data: Data?) -> Void {
        if let json = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
            let cardId = json["id"] as! String
            let paramMap = ["source": cardId, "amount": "100", "currency": "usd"]
            ApiService.callPost(url: URL(string: "https://api.stripe.com/v1/charges")!, params: paramMap, credentials: base64CredentialsReverse, finish: finishPostPay)
        }
    }

    func finishPostPay(message: String, data: Data?) {
        if let json = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
            let isPaid = json["paid"] as! Bool
            if isPaid {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Payment successful for card " + self.creditCardNumber.text!, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func finishPrint(message: String, data: Data?) {
        let bytes: Data = data!
        print(String(data: bytes, encoding: .utf8)!)
    }
}

