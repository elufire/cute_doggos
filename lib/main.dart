import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cute_doggos/DogBreed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

import 'package:flutter/widgets.dart';

const SEARCH_DOGS = "SEARCH_DOGS";
const GET_ALL_DOGS = "GET_ALL_DOGS";
const DOGS_STREAM = "DOGS_STREAM"

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
  static const stream = const EventChannel(DOGS_STREAM);
  StreamSubscription _dogsSubscription = null;
  Widget _appBarTitle = new Text("Cute Doggos");
  var _dogList = [];
  bool _loadingInProgress;
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

  Future<void> searchDogApi(String search) async {
    String response = "";
    List<DogBreed> dogBreeds;
    try {
      _loadingInProgress = true;
      final String result = await platform.invokeMethod(SEARCH_DOGS, search);
      response = result;
      print("The response from search is: $response");
      dogBreeds = (json.decode(result) as List).map((dogMap)=> DogBreed.fromJsonMap(dogMap)).toList();
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _dogList = dogBreeds;
      _loadingInProgress = false;
    });
  }

  Future<void> allDogApi() async {
    String response = "";
    List<DogBreed> dogBreeds;
    try {
      _loadingInProgress = true;
      final String result = await platform.invokeMethod(GET_ALL_DOGS);
      response = result;
      print("The response from search is: $response");
      dogBreeds = (json.decode(result) as List).map((dogMap)=> DogBreed.fromJsonMap(dogMap)).toList();
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _dogList = dogBreeds;
      _loadingInProgress = false;
    });
  }

  void enableDogs() {
    if(_dogsSubscription != null) {
      _dogsSubscription = stream.receiveBroadcastStream().listen(updateDogs);
    }
  }

  void updateDogs(dogs) {
    debugPrint("Dogs $dogs");
    setState(() {
      _dogList = dogs;
      _loadingInProgress = false;
    });
  }

  void disableDogs() {
    if(_dogsSubscription != null) {
      _dogsSubscription.cancel();
      _dogsSubscription = null
    }
  }

  void triggerSearch(String searchValue){
    setState(() {
      _loadingInProgress = true;
//      searchDogApi(searchValue);
    });
  }

  void allDogsTapped(){
    setState(() {
      _loadingInProgress = true;
      allDogApi();
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

  @override
  void initState() {
    super.initState();
    _loadingInProgress = false;
    enableDogs();
  }

  @override
  void dispose() {
    super.dispose();
    disableDogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
//        leading: IconButton(icon: _searchIcon, onPressed: (){
//          _searchPressed();
//        }),
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(icon: _searchIcon, onPressed: (){
          _searchPressed();
          }),
          // action button
//          IconButton(
//            icon: Icon(Icons.done_outline),
//            onPressed: () {
//              print("Checkmark clicked");
//            },
//          ),
//          // action button
//          IconButton(
//            icon: Icon(Icons.access_time),
//            onPressed: () {
//              print("Clock clicked");
//            },
//          ),
//          PopupMenuButton<String>(
//            onSelected: _menuChoiceSelected,
//            itemBuilder: (BuildContext context) {
//              return menuItems.map((String choice) {
//                return PopupMenuItem<String>(
//                  value: choice,
//                  child: Text(choice),
//                );
//              }).toList();
//            },
//          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(leading: Image.asset("assets/images/dog_prints.png",
              width: 30,
              height: 30,),
              title: Text("All Breeds"),
              onTap: (){
                allDogsTapped();
                Navigator.pop(context);
              },
            ),
            Container(
              padding: const EdgeInsets.only(left: 20),
              child: Text("Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700
                ),
              ),
            ),
            ListTile(leading: Image.asset("assets/images/dog_breed.png",
              width: 30,
              height: 30,),
              title: Text("Breed Groups"),
            ),
            ListTile(leading: Image.asset("assets/images/dog_house.png",
              width: 30,
              height: 30,),
              title: Text("Size"),
            ),
            ListTile(leading: Image.asset("assets/images/dog_lifespan.png",
              width: 30,
              height: 30,),
              title: Text("Lifespan"),
            ),
            ListTile(leading: Image.asset("assets/images/dog_bowl.png",
              width: 30,
              height: 30,),
              title: Text("About"),
            ),
            ListTile(leading: Image.asset("assets/images/dog_bone.png",
              width: 30,
              height: 30,),
              title: Text("Donate"),
            ),
//            ListTile(leading: ImageIcon(AssetImage("dog_breed.png"))),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    if(_loadingInProgress){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } //else if(!_loadingInProgress) {
//      return new Center(
//        child: Text("Welcome to Cute Doggos Encyclopedia",
//        style: TextStyle(color: Color(0xededed),
//          fontWeight: FontWeight.w300,
//          fontSize: 26),),
//      );
//    }
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildDogCards(passedPuppy)
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
          child: Column(
            children: <Widget>[
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
            child: Row(
              children: <Widget>[
                Text("Breed group: ",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                    )),
                Text(secondDogBreed.breed_group)
              ]
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Text("Height: ",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                    )),
                Text("${secondDogBreed.height
                    .imperial} inches, ${secondDogBreed.height.metric} cms")
              ],
            )
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Text("Lifespan: ",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                    )),
                Text(secondDogBreed.life_span)
              ],
            )
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
              child: Text(
                  "Temperament and Behavior: ",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16
                  )),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(secondDogBreed.temperament)
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Text("Weight: ",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                    )),
                Text("${secondDogBreed.weight
                    .imperial} pounds, ${secondDogBreed.weight.metric} kgs")
              ],
            )
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
    );
  }

  void _menuChoiceSelected(String selected){
    print("The menuItem selected was $selected");

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

        });
  }

  Widget _buildRow(List<DogBreed> passedPuppy){
    return
      Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildDogCards(passedPuppy)
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
                child: Column(
                  children: <Widget>[
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



