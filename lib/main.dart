import 'dart:convert';
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
      title: 'Movies App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  int page = 1;
  late List<String> movieTitles;

  @override
  void initState() {
    super.initState();
    // Initialize movieTitles with an empty list
    movieTitles = <String>[];
    // Fetch data from API
    fetchData(page);
  }

  Future<void> fetchData(int page) async {
    final String apiUrl = 'https://yts.mx/api/v2/list_movies.json?limit=10&page=$page';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

      setState(() {
        final List<dynamic> moviesData = data["data"]['movies'];
        final List<Map<String, dynamic>> movies = List<Map<String, dynamic>>.from(moviesData.map((dynamic movie) {
          return movie as Map<String, dynamic>;
        }));
        movieTitles = List<String>.from(movies.map((Map<String, dynamic> movieMap) => movieMap['title'] as String));
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie List App', style: TextStyle(color: Colors.white)),
        // Set the background color to the whole screen
        backgroundColor: Colors.deepPurple.shade400,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            // Set the background gradient
            gradient: LinearGradient(
              colors: <Color>[Colors.deepPurple.shade50, Colors.deepPurple.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                // Display the movie titles in a ListView
                child: ListView.builder(
                  // Set the number of items in the list
                  itemCount: movieTitles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      // Display the movie title
                      title: Text(movieTitles[index], style: TextStyle(color: Colors.purple[900])),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // page logic
                  ElevatedButton(
                    onPressed: () {
                      if (page > 1) {
                        setState(() {
                          page--;
                          fetchData(page);
                        });
                      }
                    },
                    child: const Text('Previous Page'),
                  ),
                  Text('Page $page', style: TextStyle(color: Colors.purple[900])),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        page++;
                        fetchData(page);
                      });
                    },
                    child: const Text('Next Page'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
