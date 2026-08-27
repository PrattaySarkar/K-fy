import 'package:intl/intl.dart';

abstract final class Money {
  static const supportedCodes = ['USD', 'EUR', 'GBP', 'INR'];

  static String symbol(String currencyCode) {
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  static String format(double amount, String currencyCode) {
    return NumberFormat.simpleCurrency(name: currencyCode).format(amount);
  }
}
