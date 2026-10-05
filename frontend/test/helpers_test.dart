import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelease/utils/helpers.dart';

void main() {
  group('money()', () {
    test('formats INR currency correctly', () {
      expect(money(1000), '₹1,000');
    });

    test('formats zero correctly', () {
      expect(money(0), '₹0');
    });
  });

  group('dateFmt()', () {
    test('formats date correctly', () {
      final date = DateTime(2025, 4, 15);

      expect(dateFmt(date), '15 Apr 2025');
    });

    test('returns dash for null date', () {
      expect(dateFmt(null), '-');
    });
  });

  group('statusColor()', () {
    test('returns green for Confirmed', () {
      expect(statusColor('Confirmed'), Colors.green);
    });

    test('returns orange for Pending', () {
      expect(statusColor('Pending'), Colors.orange);
    });

    test('returns red for Cancelled', () {
      expect(statusColor('Cancelled'), Colors.red);
    });

    test('returns blueGrey for unknown status', () {
      expect(statusColor('Unknown'), Colors.blueGrey);
    });
  });
}
