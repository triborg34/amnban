import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Alphabetselector extends StatelessWidget {
  ScrollController scrollController;
  Alphabetselector({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'انتخاب حرف پلاک',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: plateAlphabet.length,
              itemBuilder: (context, index) {
                final letter = plateAlphabet.values.toList()[index];

                return GestureDetector(
                  onTap: () {
                 
                    Get.find<reportController>().persianalhpabet.value = letter;
                    Get.find<reportController>().engishalphabet.value = plateAlphabet.keys.toList()[index];
                    
                   Navigator.pop(context);
                    
                      
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
