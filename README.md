<p align="center"><a href="https://www.verygoodsecurity.com/"><img src="https://avatars0.githubusercontent.com/u/17788525" width="128" alt="VGS Logo"></a></p>
<p align="center"><b>vgs-stripe-ios-example</b></p>
<p align="center"><i>Integration of iOS app with VGS</i></p>

## Requirements
- XCode 9 or higher
- VGS [account](https://dashboard.verygoodsecurity.com/)
- Stripe [account](https://dashboard.stripe.com/register)
- Firebase [account](https://console.firebase.google.com/)

## VGS base setup
1. Go to [VGS-Dashboard](https://dashboard.verygoodsecurity.com), create a new organization, create a new vault.
2. Select your vault, copy vault id (e.g. tn1234567)

## Third-party services
1. Create account on Stripe
2. Generate Stripe sandbox API key (https://dashboard.stripe.com/account/apikeys)
3. Create Firebase project and create a database in `test mode`
4. Visit settings and copy `Project ID`.

## Run application
1. Clone repository and go to project directory
2. Open it in XCode
3. Open `vgs-stripe-ios-example/Config/Dev.xcconfig`
4. Substitute placeholders for following identifiers: `tenant_id`, `firebase_id`, `stripe_id_1`

## Secure inbound traffic with VGS
1. Go to VGS dashboard
2. Go to `Secure traffic` -> `Inbound`
3. Create a sample rule, ensure that `Upstream host` is set to `https://httpbin.verygoodsecurity.io`
4. Fill forms in app, submit payment data
5. Open VGS dashboard, go to `Logs`
6. Ensure that logger is recording payloads
7. Find the request with credit card data, click on it
8. Click on `Secure this payload`
9. Select fields, click `Secure`

## What is VGS?

_**Want to just jump right in?** Check out our [getting started
guide](https://www.verygoodsecurity.com/docs/getting-started)._

Very Good Security (VGS) allows you to enhance your security standing while
maintaining the utility of your data internally and with third-parties. As an
added benefit, we accelerate your compliance certification process and help you
quickly obtain security-related compliances that stand between you and your
market opportunities.

To learn more, visit us at https://www.verygoodsecurity.com/

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file
for details.