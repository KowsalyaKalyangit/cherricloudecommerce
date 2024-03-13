import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
 
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/Screen/PrivacyPolicy/Privacy_Policy.dart';
import 'package:eshop_multivendor/Screen/PushNotification/PushNotificationService.dart';
import 'package:eshop_multivendor/widgets/ButtonDesing.dart';
import 'package:eshop_multivendor/widgets/appLogo.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
 
import 'package:sms_autofill/sms_autofill.dart';

import '../Screen/NoInterNetWidget/NoInterNet.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/SendOtp.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../Helper/ApiBaseHelper.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/authenticationProvider.dart';
import '../../Provider/otp_validate.dart';
import '../../Provider/productDetailProvider.dart';
import '../../repository/systemRepository.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/snackbar.dart';
 
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/validation.dart';
 

 
 String currentText='';
 String? otp;
class OtpValidatePage extends StatefulWidget {
   final Widget? classType;
  final bool isPop;
  final bool? isRefresh;

  const OtpValidatePage({Key? key, this.classType, required this.isPop, this.isRefresh})
      : super(key: key);
   

  @override
  State<OtpValidatePage> createState() => _OtpValidatePageState();
}

class _OtpValidatePageState extends State<OtpValidatePage>  with TickerProviderStateMixin {
   bool acceptTnC = false;
  bool? googleLogin, appleLogin;
  AnimationController? buttonController;
  Animation? buttonSqueezeanimation;
  String? countryName;
  bool isShowPass = true;
  // final otpcontroller =
  //     TextEditingController(text: isDemoApp ? '1212121212' : null);
  FocusNode? passFocus, monoFocus = FocusNode();
  final passwordController =
      TextEditingController(text: isDemoApp ? '12345678' : null);
  bool socialLoginLoading = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    // SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    buttonController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    // SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    

    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork1();
    }
  }
  
  
  saveAndNavigate(var getdata) async {
    SettingProvider settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    settingProvider.saveUserDetail(
      getdata[ID],
      getdata[USERNAME],
      getdata[EMAIL],
      getdata[MOBILE],
      getdata[CITY],
      getdata[AREA],
      getdata[ADDRESS],
      getdata[PINCODE],
      getdata[LATITUDE],
      getdata[LONGITUDE],
      getdata[IMAGE],
      getdata[TYPE],
      getdata[REFERCODE],
      getdata[OTP],
      context,
    );
    Future.delayed(Duration.zero, () {
      PushNotificationService(context: context).setDeviceToken(
          clearSessionToken: true, settingProvider: settingProvider);
    });
   //setToken();
    offFavAdd().then(
      (value) async {
        db.clearFav();
        context.read<FavoriteProvider>().setFavlist([]);
        List cartOffList = await db.getOffCart();
        if (singleSellerOrderSystem && cartOffList.isNotEmpty) {
          forLoginPageSingleSellerSystem = true;
          offSaveAdd().then(
            (value) {
              clearYouCartDialog();
            },
          );
        } else {
          offCartAdd().then(
            (value) {
              db.clearCart();
              offSaveAdd().then(
                (value) {
                  db.clearSaveForLater();
                  if (widget.isPop) {
                    if (widget.isRefresh != null) {
                      Navigator.pop(context, 'refresh');
                    } else {
                      context.read<HomePageProvider>().getFav(context);
                      context
                          .read<CartProvider>()
                          .getUserCart(save: '0', context: context);

                      Future.delayed(const Duration(seconds: 2))
                          .whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    }
                  } else {
                    Dashboard.dashboardScreenKey = GlobalKey();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                widget.classType ??
                                Dashboard(
                                  key: Dashboard.dashboardScreenKey,
                                )),
                        (route) => false);
                  }
                  /*  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (r) => false,
                  ); */
                },
              );
            },
          );
        }
      },
    );
  }

  
  Future<void> checkNetwork1() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context.read<AuthenticationProvider>().getLoginotpData().then(
          (
            value,
          ) async {
            bool error = value['error'];
            String? errorMessage = value['message'];
            await buttonController!.reverse();
            if (!error) {
              setSnackbar(errorMessage!, context);
              var getdata = value['data'][0];
              
              print(getdata);
        
              saveAndNavigate(getdata);
            } else {
              setSnackbar(errorMessage!, context);
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
        },
      );
    }
  }


  clearYouCartDialog() async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    circularBorderRadius5,
                  ),
                ),
              ),
              title: Text(
                getTranslated(context,
                    'Your cart already has an items of another seller would you like to remove it ?'),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: textFontSize16,
                  fontFamily: 'ubuntu',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath('appbarCart'),
                        colorFilter: const ColorFilter.mode(
                            colors.primary, BlendMode.srcIn),
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                          Routes.pop(context);
                          db.clearSaveForLater();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (r) => false);
                        },
                      ),
                      TextButton(
                        child: Text(
                          getTranslated(context, 'Clear Cart'),
                          style: const TextStyle(
                            color: colors.primary,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          if (context.read<UserProvider>().userId != '') {
                            context.read<UserProvider>().setCartCount('0');
                            context
                                .read<ProductDetailProvider>()
                                .clearCartNow(context)
                                .then(
                              (value) async {
                                if (context
                                        .read<ProductDetailProvider>()
                                        .error ==
                                    false) {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage ==
                                      'Data deleted successfully') {
                                  } else {
                                    setSnackbar(
                                        context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage,
                                        context);
                                  }
                                } else {
                                  setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                      context);
                                }
                                Routes.pop(context);
                                await offCartAdd();
                                db.clearSaveForLater();
                                Dashboard.dashboardScreenKey = GlobalKey();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (r) => false,
                                );
                              },
                            );
                          } else {
                            Routes.pop(context);
                            db.clearSaveForLater();
                            Dashboard.dashboardScreenKey = GlobalKey();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

 

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          if (getdata['message'] == 'One of the product is out of stock.') {
            homePageSingleSellerMessage = true;
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
          SAVE_LATER: '1'
        };
        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  
   
   

   
  

   

  loginBtn() {
    return Center(
      child: Consumer<AuthenticationProvider>(
        builder: (context, value, child) {
          return AppBtn(
            title: getTranslated(context, 'SIGNIN_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              FocusScope.of(context).unfocus();
              if (passFocus != null) {
                passFocus!.unfocus();
              }
              if (monoFocus != null) {
                monoFocus!.unfocus();
              }
              validateAndSubmit();
            },
          );
        },
      ),
    );
  }

   

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  _setFav(String pid) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: pid
        };
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
          setSnackbar(msg!, context);
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }
  //   Widget getLogo() {
  //   return Container(
  //     alignment: Alignment.center,
  //     padding: const EdgeInsets.only(top: 10),
  //     child: const AppLogo(),
  //   );
  // }
 setMobileNo() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: textFontSize13),
       // keyboardType: TextInputType.number,
       // controller: context.read<AuthenticationProvider>().otpcontroller,
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
       // maxLength: 15,
       // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counter: const SizedBox(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 5,
          ),
          hintText: getTranslated(
            context,
            'MOBILEHINT_LBL',
          ),
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13),
          fillColor: Theme.of(context).colorScheme.lightWhite,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
        ),
        validator: (val) => StringValidation.validateOtpCode(
            val!,
            getTranslated(context, 'E'),
            getTranslated(context, '')),
        onSaved: (String? value) {
          context.read<AuthenticationProvider>().setEmail(value);
        },
      ),
    );
  }
  monoVarifyText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 60.0,
      ),
      child: Text(
        getTranslated(context, 'MOBILE_NUMBER_VARIFICATION'),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize23,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  otpText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL'),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  mobText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5.0),
      child: Text(
        '',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
      padding: const EdgeInsets.only(top: 30,left:20,right: 20),
      child: PinFieldAutoFill(
        decoration: BoxLooseDecoration(
            textStyle: TextStyle(
                fontSize: textFontSize20,
                color: Theme.of(context).colorScheme.fontColor),
            radius: const Radius.circular(circularBorderRadius4),
            gapSpace: 15,
            bgColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.lightWhite.withOpacity(0.4)),
            strokeColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.fontColor.withOpacity(0.2))),
            currentCode:otp,
        codeLength: 5,
        onCodeChanged: ( String ?code) {
           context.read<AuthenticationProvider>().otppara = code;
        },
        onCodeSubmitted: (String? code) {
      context.read<AuthenticationProvider>().otppara=code;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 23,
                  right: 23,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formkey,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                                     //getLogo(),
            monoVarifyText(),
            otpText(),
            mobText(),
            //setMobileNo(),
            otpLayout(),
            SizedBox(height: 20,),
           

                          
                          loginBtn(),
                          
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                      if (socialLoginLoading)
                        Positioned.fill(
                          child: Center(
                              child: DesignConfiguration.showCircularProgress(
                                  socialLoginLoading, colors.primary)),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }
}