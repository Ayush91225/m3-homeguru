import 'package:flutter/material.dart';

enum TxType { topUp, sessionDebit, refund }

extension TxTypeLabel on TxType {
  String get label => switch (this) {
        TxType.topUp        => 'Paid on Platform',
        TxType.sessionDebit => 'Paid from Escrow',
        TxType.refund       => 'Refunded to Escrow',
      };

  IconData get icon => switch (this) {
        TxType.topUp        => Icons.add_card_outlined,
        TxType.sessionDebit => Icons.school_outlined,
        TxType.refund       => Icons.undo_rounded,
      };

  bool get isCredit => this == TxType.topUp || this == TxType.refund;
}

class WalletTx {
  final String id;
  final TxType type;
  final double amount;
  final DateTime date;
  final String tutorName;
  final String subject;
  final String description;
  final String? invoiceNumber;
  final int? sessionCount;

  const WalletTx({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.tutorName,
    required this.subject,
    required this.description,
    this.invoiceNumber,
    this.sessionCount,
  });
}

final kMockTutors = ['Priya Sharma', 'Vikram Singh', 'Ananya Reddy', 'Rajesh Kumar', 'Meera Patel'];

final kMockTxs = <WalletTx>[
  WalletTx(id: 'tx001', type: TxType.topUp,        amount: 4999,  date: DateTime(2025, 6, 1),  tutorName: 'Priya Sharma',  subject: 'Mathematics', description: '100 sessions booked with Priya Sharma',  invoiceNumber: 'INV-2025-001', sessionCount: 100),
  WalletTx(id: 'tx002', type: TxType.sessionDebit, amount: 49.99, date: DateTime(2025, 6, 3),  tutorName: 'Priya Sharma',  subject: 'Mathematics', description: 'Session #1 completed — Algebra Basics'),
  WalletTx(id: 'tx003', type: TxType.sessionDebit, amount: 49.99, date: DateTime(2025, 6, 5),  tutorName: 'Priya Sharma',  subject: 'Mathematics', description: 'Session #2 completed — Quadratic Equations'),
  WalletTx(id: 'tx004', type: TxType.refund,       amount: 49.99, date: DateTime(2025, 6, 7),  tutorName: 'Priya Sharma',  subject: 'Mathematics', description: 'Session #3 cancelled by tutor'),
  WalletTx(id: 'tx005', type: TxType.topUp,        amount: 2499,  date: DateTime(2025, 6, 8),  tutorName: 'Vikram Singh',  subject: 'Physics',     description: '50 sessions booked with Vikram Singh',   invoiceNumber: 'INV-2025-002', sessionCount: 50),
  WalletTx(id: 'tx006', type: TxType.sessionDebit, amount: 49.98, date: DateTime(2025, 6, 10), tutorName: 'Vikram Singh',  subject: 'Physics',     description: 'Session #1 completed — Kinematics'),
  WalletTx(id: 'tx007', type: TxType.sessionDebit, amount: 49.98, date: DateTime(2025, 6, 12), tutorName: 'Vikram Singh',  subject: 'Physics',     description: 'Session #2 completed — Newton\'s Laws'),
  WalletTx(id: 'tx008', type: TxType.topUp,        amount: 1499,  date: DateTime(2025, 6, 14), tutorName: 'Ananya Reddy',  subject: 'Chemistry',   description: '30 sessions booked with Ananya Reddy',   invoiceNumber: 'INV-2025-003', sessionCount: 30),
  WalletTx(id: 'tx009', type: TxType.refund,       amount: 49.98, date: DateTime(2025, 6, 15), tutorName: 'Vikram Singh',  subject: 'Physics',     description: 'Session #3 cancelled — tutor unavailable'),
  WalletTx(id: 'tx010', type: TxType.sessionDebit, amount: 49.97, date: DateTime(2025, 6, 17), tutorName: 'Ananya Reddy',  subject: 'Chemistry',   description: 'Session #1 completed — Periodic Table'),
  WalletTx(id: 'tx011', type: TxType.sessionDebit, amount: 49.97, date: DateTime(2025, 6, 19), tutorName: 'Ananya Reddy',  subject: 'Chemistry',   description: 'Session #2 completed — Chemical Bonding'),
  WalletTx(id: 'tx012', type: TxType.topUp,        amount: 999,   date: DateTime(2025, 6, 20), tutorName: 'Rajesh Kumar',  subject: 'Biology',     description: '20 sessions booked with Rajesh Kumar',   invoiceNumber: 'INV-2025-004', sessionCount: 20),
  WalletTx(id: 'tx013', type: TxType.sessionDebit, amount: 49.95, date: DateTime(2025, 6, 22), tutorName: 'Rajesh Kumar',  subject: 'Biology',     description: 'Session #1 completed — Cell Structure'),
  WalletTx(id: 'tx014', type: TxType.refund,       amount: 49.97, date: DateTime(2025, 6, 23), tutorName: 'Ananya Reddy',  subject: 'Chemistry',   description: 'Session #3 cancelled by learner'),
  WalletTx(id: 'tx015', type: TxType.sessionDebit, amount: 49.95, date: DateTime(2025, 6, 25), tutorName: 'Rajesh Kumar',  subject: 'Biology',     description: 'Session #2 completed — Photosynthesis'),
];
