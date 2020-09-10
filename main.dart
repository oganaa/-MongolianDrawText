import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import './row.dart';
import './word.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> points = <Offset>[];
  ScrollController _scrollController = new ScrollController();
  List<Offset> delete = <Offset>[]; // delete lines
  List<Roww> display = [];
  double contextWidth=0;
  Color newColor=Colors.white;
  double rowHeight = 0;
  int curRow = 0;
  int indexWord = 0;
  int oneColumnLength = 1;
  int allColumnLength = 1;
  bool rightPosiotion;
  //final Container sketchArea =
  @override
  void initState() {
    super.initState();
    display.add(new Roww());
    curRow = 0;
    rightPosiotion = true;
  }
  void saveToImage(List<Offset> _points) async {
    if(points.length==0){
      return ;
    }
    else {
      double wid = 82.0; //(Sketcher.maxX - Sketcher.minX);
      double hei = (Sketcher.maxY - Sketcher.minY);
      double wordHei = hei;
      double wordWid = wid;
      int wi = wordWid.ceil();
      int he = wordHei.ceil();
      wid = wid; //-5;
      hei = hei; //(AppBar().preferredSize.height);
      double translateWidth = 60.0; //Sketcher.minX;
      double translateHeight = Sketcher.minY;
/*    print('Sketcher maxY = ${Sketcher.maxY}');
    print('Sketcher minY = ${Sketcher.minY}');
    print('Sketcher maxX = ${Sketcher.maxX}');
    print('Sketcher minX = ${Sketcher.minX}');
    print('translateHeight=${translateHeight}');
    print('translateWidth=${translateWidth}');*/
      print('width,hei== $wid $hei');
      final recorder = new ui.PictureRecorder();
      final canvas = new Canvas(recorder,
          new Rect.fromPoints(new Offset(0, 0), new Offset(wid, hei)));
      Paint paint = new Paint()
        ..strokeCap = StrokeCap.round
        ..color = Colors.black
        ..strokeWidth = 3.0;
      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(
              _points[i].translate(-translateWidth, -translateHeight),
              _points[i + 1].translate(-translateWidth, -translateHeight),
              paint);
          // print("dxt=${_points[i].translate(-translateWidth, -translateHeight).dx}dyt=${_points[i].translate(-translateWidth, -translateHeight).dy} ");
        }
      }
/*    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i], _points[i + 1], paint);
      }
    }*/
      /* double translateWidth=Sketcher.minX;
    double translateHeight=Sketcher.minY;
    canvas.translate(translateWidth, translateHeight);*/
      /* paint
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..strokeWidth = 3.0;
    canvas.drawLine(new Offset(Sketcher.minX, Sketcher.minY),new Offset(Sketcher.minX+wid, Sketcher.minY), paint);
    canvas.drawLine(new Offset(Sketcher.minX, Sketcher.minY),new Offset(Sketcher.minX, Sketcher.minY+hei), paint);
    canvas.drawCircle(new Offset(10, 10), 50, paint);
    paint
      ..strokeCap = StrokeCap.round
      ..color = Colors.blue
      ..strokeWidth = 3.0;
    canvas.drawLine(new Offset(Sketcher.minX, Sketcher.minY+hei),new Offset(Sketcher.minX+wid, Sketcher.minY+hei), paint);
    canvas.drawLine(new Offset(Sketcher.minX+wid, Sketcher.minY),new Offset(Sketcher.minX+wid, Sketcher.minY+hei), paint);
    */
      final picture = recorder.endRecording();
      /* (Sketcher.maxX - Sketcher.minX).ceil(),
    ((Sketcher.maxY - Sketcher.minY+(AppBar().preferredSize.height)).ceil())*/
      /*print('width= ${(Sketcher.maxX - Sketcher.minX).ceil()}');
    print('height= ${(Sketcher.maxY - Sketcher.minY).ceil()}');*/
      //final img = await picture.toImage(320,640);

      final img = await picture.toImage(wid.ceil() + 1, hei.ceil() + 1);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      if (rowHeight > context.size.height) {
        indexWord = 0;
        display.add(new Roww());
        curRow++;
        rowHeight = 0;
      }
      rowHeight = rowHeight + 42 * hei / wid;
      setState(() {
        display[curRow].words.add(
            new Word(wordHei, wordWid, pngBytes, indexWord));
        indexWord++;
        // print("indexWord=$indexWord");
      });
    }
    //print('sum=1 baganiin undur=${rowHeight}');
  }
  Widget drawWord(Word w) {
    //print('index=${w.index} Word = ${w.height} ${w.width}');
    return w != null && w.data != null
        ? Column(
            children: <Widget>[
              SizedBox(height: 20),
              new Image.memory(
                new Uint8List.view(w.data.buffer),
                height: w.height / 2,
                width: 42,
              ),
            ],
          )
        /*Container(
      alignment: Alignment.topLeft,
      //+(AppBar().preferredSize.height)
      height: (w.height.floor()*1.0),
      //64 * w.height / w.width,
      width: 64,

    )*/
        : Container();
  }
  Widget drawRow(List<Word> w1) {
    return w1 != null && w1.length > 0
        ? Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                height: MediaQuery.of(context).size.height/12*11-74,
                width: 64,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: w1.length,
                  itemBuilder: (context, i) {
                    return drawWord(w1[i]);
                  },
                ),
              )
            ],
          )
        : Container();
  }
  Widget sentenceDraw(){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    return Expanded(
      flex: 1,
      child: display != null && display.length > 0
          ? ListView.builder(
        controller:_scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: display.length,
        itemBuilder: (context, i) {
          return drawRow(display[i].words);
        },
      )
          : Container(),
    );
  }
  Widget deleteButton() {
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      //color: Colors.white,
      child: IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            points.clear();
            Sketcher.minY = 640;
            Sketcher.minX = 640;
            Sketcher.maxY = 0;
            Sketcher.maxX = 0;
           /* int j = 0;
            for (int i = delete.length - 2; i >= 0; i--) {
              j++;
              if (delete[i] == null) {
                break;
              }
              delete[i] = null;
            }
            delete.length = delete.length - j;
            points = delete;
            //    print(points.length);*/
          });
        },
      ),
    );
  }
  Widget newLineButton() {
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      //color: newColor,
      child: IconButton(
        //highlightColor:  Colors.grey,
        //hoverColor: Colors.grey,
        icon: Icon(Icons.subdirectory_arrow_left),
        onPressed: () {
          setState(() {
            //newColor =Colors.grey;
            //new Line
            indexWord = 0;
            display.add(new Roww());
            rowHeight = 0;
            curRow++;
          });
        },
      ),
    );
  }
  Widget addImageButton() {
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      child: IconButton(
          color: Colors.green,
        icon: Icon(Icons.check),
        onPressed: () {
          setState(() {
            saveToImage(points);
           // print("rowHeight=${rowHeight}");
           points.clear();
            Sketcher.minY = 640;
            Sketcher.minX = 640;
            Sketcher.maxY = 0;
            Sketcher.maxX = 0;
          });
        },
      ),
    );
  }
  Widget deleteImageButton() {
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      //color: Colors.white,
      child: IconButton(
        color: Colors.red,
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            print(display.length);
            print(display[display.length - 1].words.length);
            print(rowHeight);
            if(display.length>0){
              if(display[curRow].words.length>=1){
                //display[curRow].words.removeLast();
                rowHeight = rowHeight- (display[curRow].words.removeLast().height+2)/2;
                print('curRow======='+rowHeight.toString());
              }
              else{
                print('Mur hooson bna');
                if(curRow>0){
                  curRow--;
                  display.length=display.length-1;
                 double sumHei=0;
                    for(int j=0;j<display[curRow].words.length;j++){
                      sumHei=sumHei+display[curRow].words[j].height/2;
                    }
                  rowHeight=sumHei;
                    sumHei=0;
                }
                print('curRow======='+curRow.toString());
              }
            }
            else  {
              print(display.length.toString()+'1 ees urt baina');
            }
            for (int i = 0; i < display.length; i++) {
              print('row${i}=');
              if (display.length >= 1) {
                for (int j = display[i].words.length - 1; j >= 0; j--) {
                  print('a${j}');
                }
              }
            }
          });
        },
      ),
    );
  }
  Widget exitButton() {
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      //color: Colors.white,
      child: IconButton(
        color: Colors.black,
        iconSize: 20,
        icon: Icon(Icons.clear),
        onPressed: () {
        },
      ),
    );
  }
  Widget leftPositionButton() {
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      child: IconButton(
        color: Colors.blue,
        icon: Icon(Icons.arrow_left),
        onPressed: () {
          setState(() {
            rightPosiotion = !rightPosiotion;
          });
        },
      ),
    );
  }
  Widget rightPositionButton(){
    return Container(
      width: contextWidth!=0?contextWidth/5:40,
      child: IconButton(
        color: Colors.blue,
        icon: Icon(Icons.compare_arrows),
        onPressed: () {
          setState(() {
            rightPosiotion = !rightPosiotion;
          });
        },
      ),
    );
  }
  Widget gestureDetectorLeft(){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {

          RenderBox box = context.findRenderObject();
          Offset _localPosiotion =
          box.globalToLocal(details.globalPosition);
          _localPosiotion = _localPosiotion.translate(
              0, -(AppBar().preferredSize.height) - 25);
//             print('x=${_localPosiotion.dx}');
//                print('y = ${_localPosiotion.dy}');
        setState(() {
          points = List.from(points)
            ..add(_localPosiotion);
        });
      },
      onPanEnd: (DragEndDetails details) {
        points.add(null);
        delete = points;
      },
      child: Container(
        margin: EdgeInsets.all(1.0),
        alignment: Alignment.topLeft,
        color: Colors.white,
        child: CustomPaint(
          painter: Sketcher(points, width, height),
        ),
      ),
    );
  }
  Widget gestureDetectorRight(){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          RenderBox box = context.findRenderObject();
          Offset _localPosiotion =
          box.globalToLocal(details.globalPosition);
          _localPosiotion = _localPosiotion.translate(
              0 - (context.size.width / 2),
              -(AppBar().preferredSize.height) - 25);
          //   print('x=${_localPosiotion.dx}');
          //   print('y = ${_localPosiotion.dy}');
          points = List.from(points)
            ..add(_localPosiotion);
        });
      },
      onPanEnd: (DragEndDetails details) {
        points.add(null);
        delete = points;
      },
      child: Container(
        margin: EdgeInsets.all(1.0),
        alignment: Alignment.topLeft,
        color: Colors.white,
        child: CustomPaint(
          painter: Sketcher(points, width, height),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    contextWidth=MediaQuery.of(context).size.width/2;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sketcher'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 11,
              child:rightPosiotion
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  sentenceDraw(),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: gestureDetectorRight(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: gestureDetectorLeft(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sentenceDraw(),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[100],
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    exitButton(),
                    SizedBox(width: 60,),
                    deleteButton(),
                    addImageButton(),
                    deleteImageButton(),
                    newLineButton(),
                    rightPositionButton(),
                    //leftPositionButton(),
                  ],
                ),
              )
            ),
          ],
        )

      ),
    );
  }
}

class Sketcher extends CustomPainter {
  final List<Offset> points;
   double width;
   double height;
  Sketcher(this.points, this.width, this.height);

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return oldDelegate.points != points;
  }

  static double maxY = 0;
  static double maxX = 0;
  static double minY = 640;
  static double minX = 640;

/*  minX=points[0].dx;
  maxX=points[0].dx;
  maxY=points[0].dy;
  minY=points[0].dy;*/
  static Offset maxTsegY;
  static Offset maxTsegX;
  static Offset minTsegY;
  static Offset minTsegX;
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null &&
          points[i + 1] != null &&
          points[i].dx >1 &&
          points[i].dx <width/2 &&
          points[i+1].dx <width/2 &&
          points[i].dy < height/12*11-75 &&
          points[i+1].dy < height/12*11-75 &&
          points[i + 1].dx >1) {
        canvas.drawLine(points[i], points[i + 1], paint);
        if (points[i].dy > maxY) {
          maxY = points[i].dy;
          maxTsegY = new Offset(points[i].dx, maxY);
        }
        if (points[i].dx > maxX) {
          maxX = points[i].dx;
          maxTsegX = new Offset(maxX, points[i].dy);
        }
        if (points[i].dy < minY) {
          minY = points[i].dy;
          minTsegY = new Offset(points[i].dx, minY);
        }
        if (points[i].dx < minX) {
          minX = points[i].dx;
          minTsegX = new Offset(minX, points[i].dy);
        }
      }
    }
    var heightt=height-AppBar().preferredSize.height-25;
//    print('maxY=${maxY}');
//    print('maxX=${maxX}');
//    print('minY=${minY}');
//    print('minX=${minX}');
    paint
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    canvas.drawLine(new Offset(101, 0), new Offset(101, heightt/12*11), paint);
    paint
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;
    canvas.drawLine(new Offset(142, 0), new Offset(142, heightt/12*11), paint);
    canvas.drawLine(new Offset(60, 0), new Offset(60, heightt/12*11), paint);
    //    print('niit undur='+height.toString());
    paint
      ..color = Colors.grey[200]
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;
    canvas.drawRect(new Rect.fromPoints(new Offset(0, 0), new Offset(60,heightt-heightt/12)), paint);
    canvas.drawRect(new Rect.fromPoints(new Offset(142, 0), new Offset(width/2,heightt-heightt/12)), paint);
  }
}
