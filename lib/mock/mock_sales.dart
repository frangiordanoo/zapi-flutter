import 'package:zapi/models/sale.dart';

/// Historial de ventas ficticio, usado por la pantalla de historial de
/// ventas del administrador (lib/features/admin/sales_history).
final List<Sale> mockSales = [
  Sale(id: 1001, date: DateTime(2026, 9, 27, 18, 42), itemsCount: 3, total: 6200, paymentMethod: 'Mercado Pago'),
  Sale(id: 1000, date: DateTime(2026, 9, 27, 17, 10), itemsCount: 1, total: 1700, paymentMethod: 'Tarjeta'),
  Sale(id: 999, date: DateTime(2026, 9, 27, 15, 55), itemsCount: 5, total: 9900, paymentMethod: 'Mercado Pago'),
  Sale(id: 998, date: DateTime(2026, 9, 27, 12, 20), itemsCount: 2, total: 4700, paymentMethod: 'Efectivo'),
  Sale(id: 997, date: DateTime(2026, 9, 26, 20, 5), itemsCount: 4, total: 8100, paymentMethod: 'Tarjeta'),
  Sale(id: 996, date: DateTime(2026, 9, 26, 13, 30), itemsCount: 1, total: 2500, paymentMethod: 'Mercado Pago'),
];
