import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stripe_sample_app/utils/constants.dart';

const String stripeKey =
    'pk_test_51JJLFfLduuinRJdeTT6oCf4fNrSPikjxusFtlhP1exrlISv4FxA5m6jou0ORKvf0B2eY3McPHb4Nsj9d2ke9Cjb900H5LQ0t31';
const String stripeSecret =
    'sk_test_51JJLFfLduuinRJde1YqubUENUxxeP2t4O5EDt5i8cTT0dDeCqwyIbYPip0eofoW4SUdqxF0foiUYXdBIxxBuJxNk00OCxwcObt';

class StripeTransactionResponse {
  String message;
  bool success;

  StripeTransactionResponse({required this.message, required this.success});
}

class CreateAccountResponse {
  late String url;
  late bool success;

  CreateAccountResponse(String url, bool success) {
    this.url = url;
    this.success = success;
  }
}

class CheckoutSessionResponse {
  late Map<String, dynamic> session;

  CheckoutSessionResponse(Map<String, dynamic> session) {
    this.session = session;
  }
}

class Driver {
  late String accountId;
  late String title;
  String currency = 'usd';

  Driver(String id, String title) {
    accountId = id;
    this.title = title;
  }
}

class StripeBackendService {
  static String apiBase = '$BACKEND_HOST/api/stripe';
  static String createAccountUrl =
      '${StripeBackendService.apiBase}/account?mobile=true';
  static String checkoutSessionUrl =
      '${StripeBackendService.apiBase}/checkout-session?mobile=true';
  static Map<String, String> headers = {'Content-Type': 'application/json'};

  static Future<CreateAccountResponse> createSellerAccount() async {
    var url = Uri.parse(StripeBackendService.createAccountUrl);
    var response = await http.get(url, headers: StripeBackendService.headers);
    Map<String, dynamic> body = jsonDecode(response.body);
    return CreateAccountResponse(body['url'], true);
  }

  static Future<CheckoutSessionResponse> payForDriver(
      {required Driver driver, required String price}) async {

    var url = StripeBackendService.checkoutSessionUrl +
        "&account_id=${driver.accountId}&amount=$price&title=${driver.title}&quantity=1&currency=${driver.currency}";
    Uri parsedUrl = Uri.parse(url);
    var response =
        await http.get(parsedUrl, headers: StripeBackendService.headers);
    Map<String, dynamic> body = jsonDecode(response.body);
    return CheckoutSessionResponse(body['session']);
  }
}
