import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Examen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> favorites = [];
  final codeUser = 'U201621873';
  final name = 'Patrick Zurita';
  final photo = 'images/photo.jpg';
  List<Map<String, String>> apiData = [];

  void addToFavorites(Map<String, String> item) {
    setState(() {
      favorites.add(item);
    });
  }

  void removeFromFavorites(int index) {
    setState(() {
      favorites.removeAt(index);
    });
  }

  String getUrl(String codeUser) {
    final lastDigit = getLastDigit(codeUser);
    final apiUrl = lastDigit % 2 == 0
        ? 'https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1000&api_key=DEMO_KEY'
        : 'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&start_date=2017-07-08&end_date=2017-12-10';
    return apiUrl;
  }

  int getLastDigit(String codeUser) {
    return int.parse(codeUser[codeUser.length - 1]);
  }

  Future<void> fetchApiData(String codeUser) async {
    final lastDigit = getLastDigit(codeUser);
    final apiUrl = getUrl(codeUser);
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        log('JY - data: $data');
        apiData = lastDigit % 2 == 0
            ? (data as List<dynamic>)
                .map((item) => {
                      'campo1': item['camera']['full_name'].toString(),
                      'campo2': item['earth_date'].toString(),
                      'campo3': item['img_src'].toString(),
                    })
                .toList()
            : (data as List<dynamic>)
                .map((item) => {
                      'campo1': item['title'].toString(),
                      'campo2': item['explanation'].toString(),
                      'campo3': item['copyright']?.toString() ?? 'N/A',
                    })
                .toList();
      });
    } else {
      throw Exception('Failed to load API data');
    }
  }

  @override
  void initState() {
    fetchApiData(codeUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mostrar'),
              Tab(text: 'Favoritos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            mostrarSection(),
            favoritosSection(),
          ],
        ),
      ),
    );
  }

  Widget mostrarSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(photo),
          ),
          const SizedBox(height: 10),
          Text(name),
          Text(codeUser),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(getUrl(codeUser)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (apiData.isNotEmpty) {
                addToFavorites(
                    apiData[0]); // Agrega el primer elemento de apiData
              }
            },
            child: const Text('Agregar a Favoritos'),
          ),
        ],
      ),
    );
  }

  Widget favoritosSection() {
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(favorites[index]['campo1']!),
          onDismissed: (direction) {
            removeFromFavorites(index);
          },
          background: Container(color: Colors.red),
          child: ListTile(
            title: Text(favorites[index]['campo1']!),
            subtitle: Text(
                '${favorites[index]['campo2']} - ${favorites[index]['campo3']}'),
          ),
        );
      },
    );
  }
}
