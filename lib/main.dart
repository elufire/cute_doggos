import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cute_doggos/height.dart';
import 'package:cute_doggos/weight.dart';
import 'package:cute_doggos/DogBreed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
//import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final color = Color(0xFFec2356);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doggies',
      theme: ThemeData(
        primaryColor: color,
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'SulphurPoint'
        )
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Widget _appBarTitle = new Text("Cute Doggos");
  var _dogList = [];
  bool _loadingInProgress;
  var _puppies = [["assets/minpin.jpeg", "assets/pomeranian2.jpg", "assets/goldenretriever.jpg"], ["assets/pomeranian2.jpg", "assets/minpin.jpeg", "assets/goldenretriever.jpg"]];//new List.generate(1, (_) => new List(3)).add("assets/pomeranian.jpg");//<String>[["assets/pomeranian.jpg", "minpin.jpeg", "goldenretriever.jpg"]];
  final TextEditingController _filter = new TextEditingController();
  Icon _searchIcon = new Icon(Icons.search);
  static const platform = MethodChannel("flutter.native/helper");
  String _responseFromNativeCode = 'Waiting for Response...';
  Future<void> responseFromNativeCode() async {
    String response = "";
    try {
      final String result = await platform.invokeMethod('helloFromNativeCode');
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _responseFromNativeCode = response;
    });
  }

  Future<void> callDogApi(String search) async {
    String response = "";
    List<DogBreed> dogBreeds;
    try {
      _loadingInProgress = true;
      final String result = await platform.invokeMethod("getDogData", search);
      response = result;
      print("The response from search is: $response");
      //List<Map> dogMaps = json.decode(result);
      //var dogsResponse = json.decode(result);
      //print("dog API response after decode: $dogsResponse");
      dogBreeds = (json.decode(result) as List).map((dogMap)=> DogBreed.fromJsonMap(dogMap)).toList();
      //print("Response from native code to Flutter dog name: ${dogBreeds[0].name}");
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _dogList = dogBreeds;
      _loadingInProgress = false;
    });
  }

  void triggerSearch(String searchValue){
    setState(() {
      _loadingInProgress = true;
      callDogApi(searchValue);
    });
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          style: TextStyle(color: Colors.white),
          onSubmitted: (newValue){triggerSearch(newValue);},
          onChanged: (newValue){

          },
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search, color: Colors.white,),
              hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white)
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Cute Doggos');
//          filteredNames = names;
        _filter.clear();
      }
    });
  }

//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _responseFromNativeCode = response;
//    });
//  }

  @override
  void initState() {
    super.initState();
    _loadingInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    //responseFromNativeCode();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        leading: IconButton(icon: _searchIcon, onPressed: (){
          _searchPressed();
        }),
        title: _appBarTitle,
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.done_outline),
            onPressed: () {
              print("Checkmark clicked");
            },
          ),
          // action button
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              print("Clock clicked");
            },
          ),
          // overflow menu
          PopupMenuButton<String>(
            onSelected: _menuChoiceSelected,
            itemBuilder: (BuildContext context) {
              return menuItems.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _buildBody(),

//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildBody(){
    if(_loadingInProgress){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }
    else{
      return _buildPuppies();
    }
  }

  void _menuChoiceSelected(String selected){
    print("The menuItem selected was $selected");

    if(selected == "All Dog Breeds"){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllBreedsRoute()),
      );
    }

  }

  List<String> menuItems = const <String>[
    "All Dog Breeds",
    "Yorkies",
    "Hounds"
  ];

  Widget _buildPuppies() {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: (_dogList.length/3).ceil(),
        itemBuilder: (context, i) {
        List<DogBreed> tempList = new List();
            //if (i.isOdd) return Divider(); /*2*/
          //if(i<=_dogList.length){
            //final index = i % 2;
        tempList.add(_dogList[i*3]);
        if((i*3+1) < _dogList.length){
          tempList.add(_dogList[i*3+1]);
        }
        if((i*3+2) < _dogList.length){
          tempList.add(_dogList[i*3+2]);
        }

            return Container(
              padding: EdgeInsets.only(bottom: 12.0),
                child: _buildRow(tempList)
            );
          //}

        });
  }

  Widget _buildRow(List<DogBreed> passedPuppy){
    return
      Row(
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildDogCards(passedPuppy)//<Widget>[
//        Expanded(
//          child: InkWell(
//            onTap: (){
//              print("Card pressed!");
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => SecondRoute()),
//              );
//            },
//          child: Card(
//            clipBehavior: Clip.hardEdge,
//
////                mainAxisSize: MainAxisSize.min,
//
//          child: Column(
//            children: <Widget>[
//            //Text('Deliver features faster', textAlign: TextAlign.center),
//              AspectRatio(
//                aspectRatio: 1,
//
//                child: Image.asset("assets/minpin.jpeg", fit: BoxFit.fill),
//              ),
//              Container(
//                padding: EdgeInsets.all(5.0),
//              child: Text(passedPuppy[0].name, textAlign: TextAlign.center,
//                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightGreen.withOpacity(0.9)),
//              ),
//              ),
//            ],
//
//          )
//            ),
//          ),
//        ),
//
//        Expanded(
//          child: InkWell(
//            onTap: (){
//              print("Card pressed!");
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => SecondRoute()),
//              );
//            },
//
//          child: Card(
//            clipBehavior: Clip.hardEdge,
//            child: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  //Text('Deliver features faster', textAlign: TextAlign.center),
//                  AspectRatio(
//                    aspectRatio: 1,
//
//                    child: Image.asset("assets/minpin.jpeg", fit: BoxFit.fill),
//                  ),
//            Container(
//                padding: EdgeInsets.all(5.0),
//                  child: Text(passedPuppy[1].name, textAlign: TextAlign.center,
//                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightGreen.withOpacity(0.9)),
//                  ),
//            ),
//                ]
//            ),
//          ),
//          ),
//        ),
//        Expanded(
//        child: InkWell(
//          onTap: (){
//            print("Card pressed!");
//            Navigator.push(
//              context,
//              MaterialPageRoute(builder: (context) => SecondRoute()),
//            );
//            },
//          child: Card(
//            clipBehavior: Clip.hardEdge,
//            child: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  //Text('Deliver features faster', textAlign: TextAlign.center),
//                  AspectRatio(
//                    aspectRatio: 1,
//
//                    child: Image.asset("assets/minpin.jpeg", fit: BoxFit.fill),
//                  ),
//            Container(
//                padding: EdgeInsets.all(5.0),
//                  child: Text(passedPuppy[2].name, textAlign: TextAlign.center,
//                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightGreen.withOpacity(0.9)),
//                  ),
//            ),
//                ]
//            ),
//          ),
//        ),
//        ),
//      ],
    );
  }

  List<Widget> _buildDogCards(List<DogBreed> puppies){
    List<Widget> cardList = new List();
    var textSize;
    var aspectRatio;
    if(puppies.length == 1){
      textSize = 20.0;
          aspectRatio = 2.0;
    }
    else if(puppies.length == 2){
      textSize = 16.0;
      aspectRatio = 1.5;
    }
    else{
      textSize = 12.0;
      aspectRatio = 1.0;
    }

    puppies.forEach((dog) =>
        cardList.add(Expanded(
          child: InkWell(
            onTap: (){
              print("Card pressed!");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondRoute(secondDogBreed: dog,)),
              );
            },
          child: Card(
            clipBehavior: Clip.hardEdge,

//                mainAxisSize: MainAxisSize.min,

          child: Column(
            children: <Widget>[
            //Text('Deliver features faster', textAlign: TextAlign.center),
              AspectRatio(
                aspectRatio: aspectRatio,
                child: Image.network(dog.imageUrl, fit: BoxFit.fill),
              ),
              Container(
                padding: EdgeInsets.all(5.0),
              child: Text(dog.name, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightGreen.withOpacity(0.9),
                    fontSize: textSize),
              ),
              ),
            ],

          )
            ),
          ),
        )
      )
    );
    return cardList;
  }

}

class SecondRoute extends StatelessWidget {
  final DogBreed secondDogBreed;
  SecondRoute({Key key, @required this.secondDogBreed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(secondDogBreed.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        shrinkWrap: false,
        children: <Widget>[
          Center(
              child: CachedNetworkImage(
                  imageUrl: secondDogBreed.imageUrl, fit: BoxFit.fill)
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
                children: <Widget>[
                  Text("Bred for: ",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      )),
                  Text("${secondDogBreed.bred_for}"),
                ]
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Breed group: ${secondDogBreed.breed_group}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Height: ${secondDogBreed.height
                .imperial} inches, ${secondDogBreed.height.metric} cms",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      )),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Lifespan: ${secondDogBreed.life_span}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      )),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "Temperament and Behavior: ${secondDogBreed.temperament}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      )),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Weight: ${secondDogBreed.weight
                .imperial} pounds, ${secondDogBreed.weight.metric} kgs",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      )),
          ),
        ],
      ),
    );
  }
}

class AllBreedsRoute extends StatefulWidget {
  AllBreedsState createState() => AllBreedsState();

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("All Breeds"),
//      ),
//      body: Center(
//        child: RaisedButton(
//          onPressed: () {
//            Navigator.pop(context);// Navigate back to first route when tapped.
//          },
//          child: Text('Go back!'),
//        ),
//      ),
//    );
//  }
}

class AllBreedsState extends State<AllBreedsRoute>{
  var _dogList = [];
  @override
  Widget build(BuildContext context) {
    //responseFromNativeCode();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("All Dog Breeds"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.done_outline),
            onPressed: () {
              print("Checkmark clicked");
            },
          ),
          // action button
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              print("Clock clicked");
            },
          ),
          // overflow menu
          PopupMenuButton<String>(
            onSelected: _menuChoiceSelected,
            itemBuilder: (BuildContext context) {
              return menuItems.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _buildPuppies(),

//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _menuChoiceSelected(String selected){
    print("The menuItem selected was $selected");

//    if(selected == "All Dog Breeds"){
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => AllBreedsRoute()),
//      );
//    }

  }

  List<String> menuItems = const <String>[
    "All Dog Breeds",
    "Yorkies",
    "Hounds"
  ];

  Widget _buildPuppies() {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: (_dogList.length/3).ceil(),
        itemBuilder: (context, i) {
          List<DogBreed> tempList = new List();
          //if (i.isOdd) return Divider(); /*2*/
          //if(i<=_dogList.length){
          //final index = i % 2;
          tempList.add(_dogList[i*3]);
          if((i*3+1) < _dogList.length){
            tempList.add(_dogList[i*3+1]);
          }
          if((i*3+2) < _dogList.length){
            tempList.add(_dogList[i*3+2]);
          }

          return Container(
              padding: EdgeInsets.only(bottom: 12.0),
              child: _buildRow(tempList)
          );
          //}

        });
  }

  Widget _buildRow(List<DogBreed> passedPuppy){
    return
      Row(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildDogCards(passedPuppy)//<Widget>[
      );
  }

  List<Widget> _buildDogCards(List<DogBreed> puppies){
    List<Widget> cardList = new List();
    var textSize;
    var aspectRatio;
    if(puppies.length == 1){
      textSize = 20.0;
      aspectRatio = 2.0;
    }
    else if(puppies.length == 2){
      textSize = 16.0;
      aspectRatio = 1.5;
    }
    else{
      textSize = 12.0;
      aspectRatio = 1.0;
    }

    puppies.forEach((dog) =>
        cardList.add(Expanded(
          child: InkWell(
            onTap: (){
              print("Card pressed!");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondRoute()),
              );
            },
            child: Card(
                clipBehavior: Clip.hardEdge,

//                mainAxisSize: MainAxisSize.min,

                child: Column(
                  children: <Widget>[
                    //Text('Deliver features faster', textAlign: TextAlign.center),
                    AspectRatio(
                      aspectRatio: aspectRatio,
                      child: CachedNetworkImage(imageUrl:dog.imageUrl, fit: BoxFit.fill),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(dog.name, textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightGreen.withOpacity(0.9),
                            fontSize: textSize),
                      ),
                    ),
                  ],

                )
            ),
          ),
        )
        )
    );
    return cardList;
  }
}



