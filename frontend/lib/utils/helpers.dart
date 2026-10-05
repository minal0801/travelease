import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
String money(num v) => _inr.format(v);
String dateFmt(DateTime? d) => d == null ? '-' : DateFormat('dd MMM yyyy').format(d.toLocal());

class Breakpoints {
  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < 700;
  static bool isTablet(BuildContext c) { final w = MediaQuery.of(c).size.width; return w >= 700 && w < 1100; }
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 1100;
  static int gridCols(BuildContext c, {int desktop = 4}) => isMobile(c) ? 1 : (isTablet(c) ? 2 : desktop);
}

Color statusColor(String s) {
  switch (s) {
    case 'Confirmed': return Colors.green;
    case 'Pending': return Colors.orange;
    case 'Cancelled': return Colors.red;
    default: return Colors.blueGrey;
  }
}
