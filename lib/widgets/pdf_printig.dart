import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/receipt_pdf.dart';
import 'package:flutter/material.dart';

class PdfPrintig extends StatelessWidget {
  const PdfPrintig({
    super.key,
    required this.kcontroller,
    required this.dcontroller,
  });

  final knowPersonController kcontroller;
  final databaseController dcontroller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () =>
            printReceipt(dcontroller.tableContect.value, kcontroller),
        icon: Icon(Icons.print),
      ),
    );
  }
}
