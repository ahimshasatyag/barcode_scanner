import 'package:flutter/material.dart';

import '../../../warehouse/transaction/transaction.dart';

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key, this.transactionBloc});

  final TransactionBloc? transactionBloc;

  @override
  Widget build(BuildContext context) {
    return TransactionListPage(bloc: transactionBloc);
  }
}
