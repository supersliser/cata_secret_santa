import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CATA Secret Santa',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final promptController = TextEditingController();
  final emailController = TextEditingController();

  bool emailSuccess = true; 
  bool nameSuccess = true; 

  bool loggedIn = false;
  bool userAdded = false;

  Future<http.Response> getUsers() async {
    return await http
        .get(Uri.parse('https://api.jsonbin.io/v3/b/673a7dfcacd3cb34a8aa3089'));
  }

  Future<void> addUser() async {
    String name = nameController.text;
    String prompt = promptController.text;
    String email = emailController.text;
    if (name.isEmpty || email.isEmpty) {
      return;
    }
    List<dynamic> users = [];
    List<dynamic> prompts = [];
    List<dynamic> emails = [];
    var temp = await getUsers();
    var data = jsonDecode(temp.body)['record'];
    users = data['users'];
    prompts = data['prompts'];
    emails = data['email'];
    users.add(name);
    prompts.add(prompt);
    emails.add(email);
        setState(() {
      userAdded = true;
    });
    http.put(
      Uri.parse('https://api.jsonbin.io/v3/b/673a7dfcacd3cb34a8aa3089'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Master-Key':
            r"$2a$10$8B24A50wKzRmmFYROMEYgeXIoLOQwuWEpRz6AafZLeWBAJOxrwSLC",
        'X-Access-Key':
            r"$2a$10$zsqFi1oye8X3pF1UKbAUC.hb34/YEhvi2iDLbN5Xc7MNwb3rcWdOq",
      },
      body: jsonEncode(<String, List<dynamic>>{
        'email': emails,
        'users': users,
        'prompts': prompts
      }),
    );
    return;
  }

  Future<List<dynamic>> getSecretSanta() async {
    int currentUser = 0;
    List<dynamic> users = [];
    List<dynamic> prompts = [];
    List<dynamic> emails = [];
    List<dynamic> usersGotSanta = [];
    List<dynamic> usersUsedForSanta = [];

    var temp = await getUsers();
    var data = jsonDecode(temp.body)['record'];
    users = data['users'];
    prompts = data['prompts'];
    emails = data['email'];
    usersGotSanta = data['usersGotSanta'];
    usersUsedForSanta = data['usersUsedForSanta'];

    for (int i = 0; i < users.length; i++) {
      if (emails[i] == emailController.text) {
        currentUser = i;
        break;
      }
    }

    int santaUser = -1;

    if (!usersGotSanta.contains(currentUser)) {
      usersGotSanta.add(currentUser);
      while (usersUsedForSanta.contains(santaUser) ||
          santaUser == currentUser ||
          santaUser == -1) {
        santaUser = Random().nextInt(users.length);
      }
      usersUsedForSanta.add(santaUser);
    } else {
      return [null, null, 0];
    }

    return [users[santaUser], prompts[santaUser], 1];
  }

  Future<void> login() async {
    var users = await getUsers();
    var data = jsonDecode(users.body)['record'];
    if (data['email'].contains(emailController.text)) {
      loggedIn = true;
    }
    setState(() => loggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Welcome to BUNCCACATAL5 Secret Santa"),
      ),
      body: DateTime.now().month == 12
          ? !loggedIn
              ? Center(
                  child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(), labelText: 'Email', errorText: emailController.text.isEmpty ? 'Email is required' : null),
                    ),
                    ElevatedButton(
                        onPressed: () async => login(),
                        child: const Text("Login"))
                  ],
                ))
              : FutureBuilder(
                  future: getSecretSanta(),
                  builder: (context, snapshot) => Center(
                      child: snapshot.data![2] == 1
                          ? Column(
                              children: [
                                Text(
                                    "Your Secret Santa is: ${snapshot.data![0]}\n\nYour Secret Santa's Prompt is: ${snapshot.data![1]}"),
                                Text(
                                    "Please make sure to take a screenshot of this as this data will not be saved"),
                                Text(
                                    "*its not saved as this means that even Tom cannot access it*"),
                              ],
                            )
                          : Center(
                              child: Text(
                                  "You have already been assigned a Secret Santa, if you have lost this info then please hate yourself coz now we have to start the process all over again"))))
          : !userAdded ? Center(
              child: FutureBuilder(
              future: null,
              builder: (context, snapshot) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      onChanged: (value) => setState(() {
                        if (value.isEmpty) {
                          emailSuccess = false;
                        } else {
                          emailSuccess = true;
                        }
                      }),
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email'
                        , errorText: !emailSuccess! ? 'Email is required' : null
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      onChanged: (value) => setState(() {
                        if (value.isEmpty) {
                          nameSuccess = false;
                        } else {
                          nameSuccess = true;
                        }
                      }),
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Name',
                        errorText: !nameSuccess! ? 'Name is required' : null
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      controller: promptController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Prompt (optional)'
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: addUser, child: const Text("Submit")),
                ],
              ),
            )) : Center(child: Text("User Added")),
    );
  }
}
