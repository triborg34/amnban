import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/detail_sheet.dart';
import 'package:flutter/material.dart';

/// Detail view of a single detection.
///
/// The content itself lives in [DetectionDetail] so the very same widget can
/// be presented as a bottom sheet (phones) or a side dialog (desktop).
class Detailedscreen extends StatelessWidget {
  Detailedscreen(
      {required this.selectedModel,
      required this.index,
      required this.kcontroller,
      required this.rec,
      super.key});

  databaseClass selectedModel;
  knowPersonController kcontroller;
  int index;
  List rec;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مشاهده و ویرایش اطلاعات پلاک'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: DetectionDetail(
        entry: selectedModel,
        rec: rec,
        kcontroller: kcontroller,
        index: index,
      ),
    );
  }
}
