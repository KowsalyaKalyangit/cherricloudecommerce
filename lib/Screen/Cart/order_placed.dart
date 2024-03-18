import 'dart:async';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/Cart/Widget/bankTransferContentWidget.dart';
import 'package:eshop_multivendor/widgets/networkAvailablity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Helper/String.dart';
import '../Language/languageSettings.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart/order_placed.dart';
import 'package:eshop_multivendor/Screen/WebView/instamojo_webview.dart';
import 'package:eshop_multivendor/repository/paymentMethodRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
//import 'package:paytm/paytm.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Model.dart';
import '../../Model/Section_Model.dart';
import '../../Model/User.dart';
import '../../Provider/paymentProvider.dart';
import '../../Provider/productListProvider.dart';
import '../../Provider/promoCodeProvider.dart';
import '../../repository/cartRepository.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/simmerEffect.dart';
import '../../widgets/snackbar.dart';
import '../Dashboard/Dashboard.dart';
import '../Language/languageSettings.dart';
import '../Manage Address/Manage_Address.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../Payment/Payment.dart';
import '../StripeService/Stripe_Service.dart';
import '../WebView/PaypalWebviewActivity.dart';
import '../WebView/midtransWebView.dart';
import 'Widget/attachPrescriptionImageWidget.dart';
import 'Widget/bankTransferContentWidget.dart';
import 'Widget/cartIteamWidget.dart';
import 'Widget/cartListIteamWidget.dart';
import 'Widget/confirmDialog.dart';
import 'Widget/noIteamCartWidget.dart';
import 'Widget/orderSummeryWidget.dart';
import 'Widget/paymentWidget.dart';
import 'Widget/saveLaterIteamWidget.dart';
import 'Widget/setAddress.dart';

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({Key? key}) : super(key: key);

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Column(
        children: [
          TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        context.read<CartProvider>().placeOrder = true;
                        context.read<CartProvider>().isPromoValid = false;
                      },
                    );
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'DONE'),
                    style: const TextStyle(
                      color: colors.primary,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    
                   // Routes.pop(context);
                    if (context.read<CartProvider>().payMethod ==
                        getTranslated(context, 'BANKTRAN')) {
                      bankTransfer();
                    } else {
                      placeOrder('');
                    }
                  },
                )
        ],
      ),
    );
  }
   void bankTransfer() {
    showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(circularBorderRadius5))),
              content: const GetBankTransferContent(),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        context.read<CartProvider>().placeOrder = true;
                      },
                    );
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'DONE'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    Routes.pop(context);

                    context.read<CartProvider>().setProgress(true);

                    //placeOrder('');
                  },
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }
   Future<void> placeOrder(String? tranId) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);
      List<SectionModel> tempCartListForTestCondtion =
          context.read<CartProvider>().cartList;
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context.read<CartProvider>().cartList;
      for (SectionModel sec in cartList) {
        varientId =
            varientId != null ? '$varientId,${sec.varientId!}' : sec.varientId;
        quantity = quantity != null ? '$quantity,${sec.qty!}' : sec.qty;
      }

      String? payVia;
      if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'COD_LBL')) {
        payVia = 'COD';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYPAL_LBL')) {
        payVia = 'PayPal';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYUMONEY_LBL')) {
        payVia = 'PayUMoney';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'RAZORPAY_LBL')) {
        payVia = 'RazorPay';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PHONEPE_LBL')) {
        payVia = 'phonepe';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYSTACK_LBL')) {
        payVia = 'Paystack';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'FLUTTERWAVE_LBL')) {
        payVia = 'Flutterwave';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'STRIPE_LBL')) {
        payVia = 'Stripe';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYTM_LBL')) {
        payVia = 'Paytm';
      } else if (context.read<CartProvider>().payMethod == 'Wallet') {
        payVia = 'Wallet';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'BANKTRAN')) {
        payVia = 'bank_transfer';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'MidTrans')) {
        payVia = 'midtrans';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'My Fatoorah')) {
        payVia = 'my fatoorah';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'instamojo_lbl')) {
        payVia = 'instamojo';
      }
      var request = http.MultipartRequest('POST', placeOrderApi);
      request.headers.addAll(headers);

      try {
        request.fields[USER_ID] = context.read<UserProvider>().userId!;
        request.fields[MOBILE] = mob;
        request.fields[PRODUCT_VARIENT_ID] = varientId!;
        request.fields[QUANTITY] = quantity!;
        request.fields[TOTAL] =
            context.read<CartProvider>().oriPrice.toString();
        request.fields[FINAL_TOTAL] =
            context.read<CartProvider>().totalPrice.toString();
        request.fields[DEL_CHARGE] =
            context.read<CartProvider>().deliveryCharge.toString();
        request.fields[TAX_PER] =
            context.read<CartProvider>().taxPer.toString();
        request.fields[PAYMENT_METHOD] = payVia!;
        if (tempCartListForTestCondtion[0].productType != 'digital_product') {
          request.fields[ADD_ID] = context.read<CartProvider>().selAddress!;
          if (context.read<CartProvider>().isTimeSlot!) {
            request.fields[DELIVERY_TIME] =
                context.read<CartProvider>().selTime ?? 'Anytime';
            request.fields[DELIVERY_DATE] =
                context.read<CartProvider>().selDate ?? '';
          }
        }

        if (tempCartListForTestCondtion[0].productType == 'digital_product') {
          request.fields['email'] =
              context.read<CartProvider>().emailController.text;
        }
        request.fields[ISWALLETBALUSED] =
            context.read<CartProvider>().isUseWallet! ? '1' : '0';
        request.fields[WALLET_BAL_USED] =
            context.read<CartProvider>().usedBalance.toString();
        request.fields[ORDER_NOTE] =
            context.read<CartProvider>().noteController.text;

        if (context.read<CartProvider>().isPromoValid!) {
          request.fields[PROMOCODE] = context.read<CartProvider>().promocode!;
          request.fields[PROMO_DIS] =
              context.read<CartProvider>().promoAmt.toString();
        }

        if (context.read<CartProvider>().payMethod ==
            getTranslated(context, 'COD_LBL')) {
          request.fields[ACTIVE_STATUS] = PLACED;
        } else if (tempCartListForTestCondtion[0].productType ==
            'digital_product') {
          // request.fields[ACTIVE_STATUS] = DELIVERD;
        } else {
          if (context.read<CartProvider>().payMethod ==
              getTranslated(context, 'PHONEPE_LBL')) {
            request.fields[ACTIVE_STATUS] = 'draft';
          } else {
            request.fields[ACTIVE_STATUS] = WAITING;
          }
        }

        if (context.read<CartProvider>().prescriptionImages.isEmpty) {
          for (var i = 0;
              i < context.read<CartProvider>().prescriptionImages.length;
              i++) {
            final mimeType = lookupMimeType(
                context.read<CartProvider>().prescriptionImages[i].path);

            var extension = mimeType!.split('/');

            var pic = await http.MultipartFile.fromPath(
              DOCUMENT,
              context.read<CartProvider>().prescriptionImages[i].path,
              contentType: MediaType('image', extension[1]),
            );

            request.files.add(pic);
          }
        }
        var response = await request.send();
        print('request fields****${request.fields}');
        print('response statuscode****${response.statusCode}');
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        context.read<CartProvider>().placeOrder = true;
        if (response.statusCode == 200) {
          var getdata = json.decode(responseString);
          print('getdata response place order****$getdata');
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            String orderId = getdata['order_id'].toString();
             
              context.read<UserProvider>().setCartCount('0');
              
             // Routes.navigateToOrderSuccessScreen(context);
             
          } else {
            setSnackbar(msg!, context);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          context.read<CartProvider>().checkoutState!(
            () {
              context.read<CartProvider>().placeOrder = true;
            },
          );
        }
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }
}