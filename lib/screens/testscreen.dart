import 'package:flutter/material.dart';

class TestScreens extends StatefulWidget {
  TestScreens({super.key});

  @override
  State<TestScreens> createState() => _TestScreensState();
}

class _TestScreensState extends State<TestScreens> {
  List a = ['1', '2'];

  List b = [100, 25];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              b[0]=b[0]+10;
              setState(() {
                
              });
            }, child: Text("data")),
            Spacer(),
            Container(
              color: Colors.black,
              width: 500,
              height: 500,
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                            child: Center(child: Text(b[0].toString()),),
                          duration: Duration(milliseconds: 350),
                          width: 50,
                          height: b[0],
                          color: Colors.red,
                        ),
                          Text(a[1],style: TextStyle(color: Colors.black,fontSize: 16),)
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Center(child: Text(b[0].toString()),),
                          width: 50,
                          height: b[1],
                          color: Colors.blue,
                        ),
                        Text(a[0],style: TextStyle(color: Colors.green),)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
