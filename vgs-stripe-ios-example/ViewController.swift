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
    @IBOutlet weak var clearButton: UIButton!
    //  Forward
    @IBOutlet var fCreditCardName: UITextField!
    @IBOutlet var fCreditCardNumber: UITextField!
    @IBOutlet var fCreditCardExpirationMonth: UITextField!
    @IBOutlet var fCreditCardExpirationYear: UITextField!
    @IBOutlet var fCreditCardCvv: UITextField!

    var base64CredentialsReverse: String = ""
    var schemaUrl: String = ""
    var stripeBaseUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let stripeReverseApi = ApiService.infoForKey("STRIPE_REVERSE_KEY")!
        let credentialData = "\(stripeReverseApi):".data(using: String.Encoding.utf8)!
        base64CredentialsReverse = credentialData.base64EncodedString(options: [])
        schemaUrl = ApiService.infoForKey("URL_SCHEMA")!
        stripeBaseUrl = ApiService.infoForKey("STRIPE_BASE_URL")!
        NSLog("Application loaded...")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        let tenantUrl = ApiService.infoForKey("PROXY_URL")!
        let stripeTokenUrl = ApiService.infoForKey("STRIPE_TOKENS_URL")!
        if sender === submitButton {
            let httpBinUrl = ApiService.infoForKey("HTTPBIN_URL")!
            let expirationDateArr = creditCardExpiration.text!.split{$0 == "/"}
            let paramMap = ["card[number]": (creditCardNumber.text!), "card[exp_month]": String(expirationDateArr[0]), "card[exp_year]": String(expirationDateArr[1]), "card[cvc]": (creditCardCvv.text!)]
            ApiService.callPost(url: URL(string: schemaUrl + "://" + tenantUrl + httpBinUrl)!, payload: ApiService.getPostString(params: paramMap), finish: finishPostTokenize)
            ApiService.callPost(url: URL(string: schemaUrl + "://" + stripeBaseUrl + stripeTokenUrl)!, payload: ApiService.getPostString(params: paramMap), credentials: base64CredentialsReverse, finish: finishPostStripeToken)
        } else if sender === clearButton {
            self.creditCardName.text = ""
            self.creditCardNumber.text = ""
            self.creditCardExpiration.text = ""
            self.creditCardCvv.text = ""
            self.fCreditCardName.text = ""
            self.fCreditCardNumber.text = ""
            self.fCreditCardExpirationMonth.text = ""
            self.fCreditCardExpirationYear.text = ""
            self.fCreditCardCvv.text = ""
        }
    }

    private func finishPostTokenize(message: String, data: Data?) -> Void {
        if let json = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
            if let form = json["form"] as? [String: String] {
                DispatchQueue.main.async {
                    self.fCreditCardName.text = self.creditCardName.text
                    self.fCreditCardNumber.text = form["card[number]"]!
                    self.fCreditCardExpirationMonth.text = form["card[exp_month]"]!
                    self.fCreditCardExpirationYear.text = form["card[exp_year]"]!
                    self.fCreditCardCvv.text = form["card[cvc]"]!
                }
            }
        }
    }

    private func finishPostStripeToken(message: String, data: Data?) -> Void {
        if let json = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
            if let cardId = json["id"] as? String {
                let paramMap = ["source": cardId, "amount": "100", "currency": "usd"]
                let stripeChargeUrl = ApiService.infoForKey("STRIPE_CHARGES_URL")!
                ApiService.callPost(url: URL(string: schemaUrl + "://" + stripeBaseUrl + stripeChargeUrl)!, payload: ApiService.getPostString(params: paramMap), credentials: base64CredentialsReverse, finish: finishPostPay)
            } else {
                genericError()
            }
        } else {
            genericError()
        }
    }


    private func finishPostPay(message: String, data: Data?) {
        let firebaseUrl = ApiService.infoForKey("FIREBASE_URL")!
        if let json = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String: Any] {
            let isPaid = json["paid"] as! Bool
            if isPaid {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Payment successful for card " + self.creditCardNumber.text!, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let payload = "{\"credit_card_number\":\"\(self.fCreditCardNumber.text ?? "")\", \"credit_card_expiration_month\": \"\(self.fCreditCardExpirationMonth.text ?? "")\", " +
                        "\"credit_card_expiration_year\": \"\(self.fCreditCardExpirationYear.text ?? "")\", \"credit_card_cvv\": \"\(self.fCreditCardCvv.text ?? "")\", " +
                        "\"credit_card_name\": \"\(self.fCreditCardName.text ?? "")\", \"timestamp\" : " + String(Date().ticks) + "}"
                ApiService.callPost(url: URL(string: schemaUrl + "://" + firebaseUrl + "/credit_cards/" + self.fCreditCardNumber.text! + ".json")!, payload: payload, finish: finishPrint)
            }
        }
    }

    private func finishPrint(message: String, data: Data?) {
        let bytes: Data = data!
        print(String(data: bytes, encoding: .utf8)!)
    }

    private func genericError() {
        let alert = UIAlertController(title: "Error", message: "Payment failed for card " + self.creditCardNumber.text!, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Damn", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}