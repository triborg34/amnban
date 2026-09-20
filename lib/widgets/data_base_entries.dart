import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_person.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Parses a stored plate like `12P34567` into person-dialog fields without
/// ever throwing RangeError on malformed plates.
Map<String, String> splitPlateSafe(String? plateNum) {
  final out = <String, String>{
    'ch': '',
    'fa': '',
    'first': '',
    'three': '',
    'last': '',
  };
  if (plateNum == null || plateNum.isEmpty) return out;
  try {
    final parts = plateNum.split(RegExp(r'[0-9]'));
    String ch = '';
    if (parts.length > 2) ch = parts[2].toString();
    if (ch.isNotEmpty && plateAlphabet.containsKey(ch)) {
      out['ch'] = ch;
      out['fa'] = plateAlphabet[ch] ?? '';
    }
    final digitParts = plateNum.split(RegExp(r'[a-zA-Z]'));
    if (digitParts.isNotEmpty) out['first'] = digitParts[0].toString();
    if (digitParts.length > 1) {
      final rest = digitParts[1].toString();
      if (rest.length >= 3) out['three'] = rest.substring(0, 3);
      if (rest.length >= 5) out['last'] = rest.substring(3, 5);
    }
  } catch (e) {
    appLog('splitPlate failed', e);
  }
  return out;
}

bool isEntryVisible(databaseClass e) {
  try {
    final plate = e.plateNum ?? '';
    if (plate.isEmpty) return false;
    if (e.isarvand == 'arvand') {
      return !plate.contains(latinLetters);
    }
    return convertToPersian(plate, alphabetP2)[0] != '-';
  } catch (_) {
    return false;
  }
}

class dataBaseEntries extends StatefulWidget {
  const dataBaseEntries({
    super.key,
    required this.dcontroller,
    required this.mController,
    required this.kcontroller,
  });

  final databaseController dcontroller;
  final mainPageConroller mController;
  final knowPersonController kcontroller;

  @override
  State<dataBaseEntries> createState() => _dataBaseEntriesState();
}

class _dataBaseEntriesState extends State<dataBaseEntries> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No nested SingleChildScrollView>Column>Expanded anymore (that pumped
    // an unbounded-height error and fought the inner list). Single ListView
    // with a footer button instead.
    return Obx(() {
      final entries = widget.dcontroller.entries;
      if (entries.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(5),
          height: 450,
          decoration: BoxDecoration(
              border: Border.all(color: purpule),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: widget.dcontroller.isLoadingMore.value
                ? const CircularProgressIndicator()
                : Text(
                    widget.dcontroller.loadError.value.isNotEmpty
                        ? widget.dcontroller.loadError.value
                        : 'رکوردی وجود ندارد',
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        );
      }
      // Filter once here instead of Visibility-per-row (which kept invalid
      // rows in itemCount/separators and built them anyway).
      final visible = entries.where(isEntryVisible).toList();
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: purpule),
            borderRadius: BorderRadius.circular(15)),
        height: 450,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index >= visible.length) return const SizedBox.shrink();
                  final entry = visible[index];
                  // Map back to the full-list index for selection.
                  final fullIndex =
                      entries.indexWhere((e) => e.id == entry.id);
                  return _EntryRow(
                    entry: entry,
                    fullIndex: fullIndex == -1 ? index : fullIndex,
                    dcontroller: widget.dcontroller,
                    mController: widget.mController,
                    kcontroller: widget.kcontroller,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: visible.length,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              width: 450,
              child: Obx(() => ElevatedButton(
                  style: TextButton.styleFrom(backgroundColor: purpule),
                  onPressed: widget.dcontroller.isLoadingMore.value
                      ? null
                      : () {
                          widget.dcontroller.inilazedPage =
                              widget.dcontroller.inilazedPage + 1;
                          widget.dcontroller.fetchFirstData(
                              widget.dcontroller.inilazedPage, 30);
                        },
                  child: widget.dcontroller.isLoadingMore.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "بار گزاری بیشتر",
                          style: TextStyle(color: Colors.white),
                        ))),
            )
          ],
        ),
      );
    });
  }

  bool isAllowed(int index) {
    final plate = widget.dcontroller.entries[index].plateNum;
    return widget.kcontroller.personFor(plate)?.role == 'مجاز';
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.fullIndex,
    required this.dcontroller,
    required this.mController,
    required this.kcontroller,
  });

  final databaseClass entry;
  final int fullIndex;
  final databaseController dcontroller;
  final mainPageConroller mController;
  final knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    final person = kcontroller.personFor(entry.plateNum);
    final isArvand = entry.isarvand == 'arvand';
    return InkWell(
      onTap: () {
        mController.isSelected.value = true;
        dcontroller.tableContect.value = entry;
        dcontroller.selectedIndex.value = fullIndex;
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            color: purpule, borderRadius: BorderRadius.circular(5)),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            SizedBox(
                width: 10.w,
                child: isArvand
                    ? ArvandPelak2(entry: entry)
                    : LicanceNumber(entry: entry)),
            const VerticalDivider(color: Colors.black),
            SizedBox(
              height: 48,
              child: Center(
                  child: SafeNetImage(
                url: pbFileUrlOf('database', entry.id, entry.imgpath),
                fit: BoxFit.fill,
                width: 10.w,
                height: 48,
              )),
            ),
            const VerticalDivider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 8.w,
                height: 50,
                child: person != null
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent),
                        child: Center(
                          child: Text(
                            person.name ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: person.role == 'مجاز'
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                          final plateNum =
                              (entry.plateNum ?? '').trim();
                          final parsed = splitPlateSafe(plateNum);
                          await showAdaptiveDialog(
                            context: context,
                            builder: (context) => add_or_edit_person(
                                name: '',
                                lastName: '',
                                carName: '',
                                firstTwoDigit: parsed['first'] ?? '',
                                threeDigit: parsed['three'] ?? '',
                                lastTwoDigit: parsed['last'] ?? '',
                                role: "مجاز",
                                arvandDigits:
                                    isArvand ? plateNum : '',
                                isArvand: isArvand,
                                isEdit: false,
                                index: fullIndex,
                                isDiscover: true,
                                engishAlphabet: parsed['ch'] ?? '',
                                persianAlhpabet: parsed['fa'] ?? '',
                                kcontroller: kcontroller),
                          );
                        },
                        hoverColor:
                            const Color.fromARGB(255, 29, 14, 55),
                        icon: const Icon(Icons.add_box_outlined),
                        color: Colors.white70,
                        iconSize: 36,
                      ),
              ),
            ),
            const VerticalDivider(color: Colors.black),
            Expanded(
                child: Center(
                    child: Text(
              Get.find<cameraController>().cameraNameFor(entry.rtpath),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ))),
            const VerticalDivider(color: Colors.black),
            SizedBox(
              width: 6.w,
              height: 50,
              child: IconButton(
                  onPressed: () async {
                    // Capture id first: the old code read
                    // cameras[index].id AFTER delete for the snackbar,
                    // using a stale index (RangeError).
                    final id = entry.id;
                    if (id == null || id.isEmpty) return;
                    try {
                      await pb.collection('database').delete(id);
                    } catch (e) {
                      appLog('delete database record failed', e);
                      if (context.mounted) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            const SnackBar(
                                content: Text('خطا در حذف رکورد')));
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
