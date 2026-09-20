import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/AlphaBetSelector.dart';
import 'package:amnban/widgets/reportTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class licanceSearcher extends StatefulWidget {
  const licanceSearcher({
    super.key,
    required this.rcontroller,
  });

  final reportController rcontroller;

  @override
  State<licanceSearcher> createState() => _licanceSearcherState();
}

class _licanceSearcherState extends State<licanceSearcher> {
  late final reportController rcontroller;

  @override
  void initState() {
    super.initState();
    rcontroller = widget.rcontroller;
    // Defer the reset to post-frame: clearing the shared TextEditingControllers
    // synchronously here notifies PlatePicked's ListenableBuilder while the
    // framework is still building the dialog -> "markNeedsBuild during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (rcontroller.firstTwoDigit.text.isNotEmpty) {
        rcontroller.firstTwoDigit.clear();
      }
      if (rcontroller.lastTwoDigit.text.isNotEmpty) {
        rcontroller.lastTwoDigit.clear();
      }
      if (rcontroller.threeDigit.text.isNotEmpty) {
        rcontroller.threeDigit.clear();
      }
      if (rcontroller.persianalhpabet.value.isNotEmpty) {
        rcontroller.persianalhpabet.value = '';
      }
      if (rcontroller.engishalphabet.value.isNotEmpty) {
        rcontroller.engishalphabet.value = '';
      }
      if (rcontroller.isArvand.value) {
        rcontroller.isArvand.value = false;
      }
      if (rcontroller.arvandDigit.text.isNotEmpty) {
        rcontroller.arvandDigit.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: EdgeInsets.all(12),
      width: 400,
      height: 200,
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            " اطلاعات پلاک را وارد کنید",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            height: 15,
          ),
          Obx(() => AnimatedCrossFade(
              firstChild: ReportTextField(
                width: 310,
                tcontroller: rcontroller.arvandDigit,
              ),
              secondChild: SeccondSearchBox(rcontroller: rcontroller),
              crossFadeState: rcontroller.isArvand.value
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 350))),
          // SeccondSearchBox(rcontroller: rcontroller),
          SizedBox(
            height: 10,
          ),
          IconButton(
              onPressed: () {
                rcontroller.isArvand.value = !rcontroller.isArvand.value;
              },
              icon: Icon(Icons.change_circle)),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 200,
            child: ElevatedButton(
                onPressed: _submit,
                child: Text("ثبت")),
          )
        ],
      ),
      decoration: BoxDecoration(
          color: purpule, borderRadius: BorderRadius.circular(15)),
    ));
  }

  void _submit() {
    if (rcontroller.isArvand.value) {
      rcontroller.pickerPlate.value =
          rcontroller.arvandDigit.text.trim();
    } else {
      // NOTE: engishalphabet is RxString — must use .value (previously
      // interpolated the Rx object itself: "Instance of RxString").
      rcontroller.pickerPlate.value =
          "${rcontroller.firstTwoDigit.text.trim()}${rcontroller.engishalphabet.value}${rcontroller.threeDigit.text.trim()}${rcontroller.lastTwoDigit.text.trim()}";
    }

    rcontroller.update();
    Navigator.pop(context);
  }
}

class SeccondSearchBox extends StatelessWidget {
  const SeccondSearchBox({
    super.key,
    required this.rcontroller,
  });

  final reportController rcontroller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        ReportTextField(width: 50, tcontroller: rcontroller.firstTwoDigit),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          height: 40,
          child: TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize:
                      0.47, // You can adjust the size of the bottom sheet
                  minChildSize: 0.3,
                  maxChildSize: 0.7,
                  expand: false,
                  builder: (context, scrollController) {
                    return Alphabetselector(
                      scrollController: scrollController,
                    );
                  },
                ),
              );
            },
            child: Obx(() => Text(
                  rcontroller.persianalhpabet.value == ''
                      ? "انتخاب حرف"
                      : rcontroller.persianalhpabet.value,
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        ReportTextField(width: 70, tcontroller: rcontroller.threeDigit),
        SizedBox(
          width: 10,
        ),
        Text(
          '/',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: 10,
        ),
        ReportTextField(width: 50, tcontroller: rcontroller.lastTwoDigit),
      ],
    );
  }
}
