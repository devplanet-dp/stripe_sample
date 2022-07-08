import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:stripe_sample_app/services/stripe_service.dart';
import 'package:stripe_sample_app/ui/screens/checkout_screen.dart';
import 'package:stripe_sample_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Sample'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SelectionCard(
                title: 'Pay to driver',
                onTapped: () => _doPaymentToDriver(context)),
            const SizedBox(
              height: 10,
            ),
            _SelectionCard(
                title: 'Register driver',
                onTapped: () => _registerDriver(context)),
            const SizedBox(
              height: 10,
            ),
            // _SelectionCard(
            //     title: 'Test deeplink',
            //     onTapped: () => _openLink()),
          ],
        ),
      ),
    );
  }

  _openLink()async{
    var url = "https://stripe-connect-backend-omega.vercel.app/register-mobile?result=success";
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch URL';
  }
  _registerDriver(BuildContext context) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Please wait...',
      progressBgColor: Colors.transparent,
    );
    try {
      CreateAccountResponse response =
          await StripeBackendService.createSellerAccount();
      pd.close();
      await canLaunch(response.url)
          ? await launch(response.url)
          : throw 'Could not launch URL';
    } catch (e) {
      print(e.toString());
      pd.close();
    }
  }

  _doPaymentToDriver(BuildContext context) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Please wait...',
      progressBgColor: Colors.transparent,
    );
    try {
      CheckoutSessionResponse response =
          await StripeBackendService.payForDriver(
        driver: Driver(DRIVER_ACCOUNT_ID, 'test_driver'),
        price: '150',
      );
      pd.close();
      String sessionId = response.session['id'];
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (_) => CheckoutPage(sessionId: sessionId),
        ))
            .then((value) {
          if (value == 'success') {
            Get.showSnackbar(const GetSnackBar(
              title: 'Success',
              message: 'Payment Successful',
              overlayColor: Colors.green,
            ));
          } else if (value == 'cancel') {
            Get.showSnackbar(const GetSnackBar(
              title: 'Error',
              message: 'Payment Failed or Cancelled',
              overlayColor: Colors.red,
            ));
          }
        });
      });
    } catch (e) {
      print(e.toString());
      pd.close();
    }
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onTapped;

  const _SelectionCard({Key? key, required this.title, required this.onTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTapped,
      label: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
