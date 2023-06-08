import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String appName = '';
String appType = '';
String appLink = '';
String username = '';
void main() {
  username = 'APP STORE';
  runApp(const MyApp());
}

Future<PostgreSQLResult> entries() async {
  var client = PostgreSQLConnection("localhost", 5432, "postgres",
      username: "postgres", password: "123", useSSL: false);
  await client.open();
  PostgreSQLResult a = (await client.query("SELECT * FROM apps"));
  await client.close();
  return a;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Store',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: username),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 204, 204, 204),
                    backgroundColor: Color.fromARGB(255, 62, 16, 70)),
                child: const Text('Log in to Existing Account'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Login(title: username)));
                }),
            Text(
              ' ',
            ),
            TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 204, 204, 204),
                    backgroundColor: Color.fromARGB(255, 62, 16, 70)),
                child: const Text('Create New Account'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Create(title: username)));
                }),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String password = '';
  String hasFailed = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Go Back'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                var client = PostgreSQLConnection("localhost", 5432, "postgres",
                    username: "postgres", password: "123", useSSL: false);
                await client.open();
                PostgreSQLResult a = (await client.query(
                    "SELECT userType FROM users WHERE username = '$username' AND pass = '$password'"));

                await client.close();
                if (a.any((row) => row.contains(2))) {
                  print('success');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminScreen(
                            title: username,
                          )));
                } else if (a.any((row) => row.contains(1))) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DevScreen(
                            title: username,
                          )));
                } else if (a.any((row) => row.contains(0))) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ClientScreen(
                            title: username,
                          )));
                } else {
                  print('fail');
                  hasFailed =
                      'Something went wrong - try inputting your information again or maybe just give up lol';
                  setState(() {});
                }
              },
              child: Text(
                'Login',
                textScaleFactor: 2,
              ),
            ),
            Text(hasFailed,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ))
          ],
        ),
      ),
    );
  }
}

class Create extends StatefulWidget {
  const Create({super.key, required this.title});
  final String title;

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  String username = '';
  String password = '';
  String hasFailed = '';
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Go Back'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return _selectedIndex == 0 ? Colors.blue : Colors.grey;
                      },
                    ),
                  ),
                  child: Text(
                    'Client',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return _selectedIndex == 1 ? Colors.blue : Colors.grey;
                      },
                    ),
                  ),
                  child: Text(
                    'Developer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return _selectedIndex == 2 ? Colors.blue : Colors.grey;
                      },
                    ),
                  ),
                  child: Text(
                    'Admin',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Text(
              '',
              textScaleFactor: 0.5,
            ),
            ElevatedButton(
              onPressed: () async {
                var client = PostgreSQLConnection("localhost", 5432, "postgres",
                    username: "postgres", password: "123", useSSL: false);
                await client.open();
                await client.query(
                    "INSERT INTO users (username, pass, userType) VALUES ('$username', '$password', $_selectedIndex)");
                PostgreSQLResult a = (await client.query(
                    "SELECT userType FROM users WHERE username = '$username' AND pass = '$password'"));
                // Close the connection

                await client.close();

                // Check the user role
                if (a.any((row) => row.contains(2))) {
                  print('success');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminScreen(
                            title: username,
                          )));
                } else if (a.any((row) => row.contains(1))) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DevScreen(
                            title: username,
                          )));
                } else if (a.any((row) => row.contains(0))) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ClientScreen(
                            title: username,
                          )));
                } else {
                  print('fail');
                  hasFailed =
                      'Something went wrong - try inputting your information again or maybe just give up lol';
                  setState(() {});
                }
              },
              child: Text(
                'Create Account',
                textScaleFactor: 2,
              ),
            ),
            Text(hasFailed,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ))
          ],
        ),
      ),
    );
  }
}

class DevScreen extends StatefulWidget {
  const DevScreen({super.key, required this.title});
  final String title;
  @override
  _DevScreenState createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> {
  bool deletefunction = false;
  var c = Color.fromARGB(255, 202, 202, 202);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: TextButton(
            child: Text(
              'Delete an App',
              style: TextStyle(
                  color: c, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            onPressed: () {
              if (deletefunction) {
                setState(() {
                  deletefunction = false;
                  c = Color.fromARGB(255, 202, 202, 202);
                });
              } else {
                setState(() {
                  deletefunction = true;
                  c = Colors.red;
                });
              }
            },
          )),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<List<dynamic>>(
          future: entries(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  var row = snapshot.data![index];
                  return ListTile(
                    title: Center(
                        child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            color: Colors.lightBlueAccent,
                            child: TextButton(
                                child: Text(
                                  row[0].toString(),
                                  textScaleFactor: 2,
                                ),
                                onPressed: () async {
                                  if (deletefunction) {
                                    var client = PostgreSQLConnection(
                                        "localhost", 5432, "postgres",
                                        username: "postgres",
                                        password: "123",
                                        useSSL: false);
                                    await client.open();
                                    String x = row[0].toString();
                                    print(x);
                                    var a = row[2].toString();
                                    await client.close();
                                    if (a == username) {
                                      print('booyah');
                                      var client = PostgreSQLConnection(
                                          "localhost", 5432, "postgres",
                                          username: "postgres",
                                          password: "123",
                                          useSSL: false);
                                      await client.open();
                                      await client.query(
                                          "DELETE FROM apps WHERE appname = '$x'");
                                      await client.close();
                                    }
                                    setState(() {
                                      deletefunction = false;
                                      c = Color.fromARGB(255, 202, 202, 202);
                                    });
                                  } else {
                                    var client = PostgreSQLConnection(
                                        "localhost", 5432, "postgres",
                                        username: "postgres",
                                        password: "123",
                                        useSSL: false);
                                    launchUrl(Uri.parse(row[3].toString()));
                                    await client.open();
                                    String x = row[0].toString();
                                    print(x);
                                    await client.query(
                                        "UPDATE apps SET downloads = downloads + 1 WHERE appname = '$x'");
                                    await client.close();
                                    setState(() {});
                                  }
                                }))),
                    subtitle: Text(
                      (row[1].toString() +
                          ', ' +
                          row[2].toString() +
                          ', ' +
                          row[4].toString() +
                          ' Downloads'),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddingScreen()));
          },
          child: Text('UPLOAD NEW APP')),
    );
  }
}

//ADMIN ACCOUNT STUFF
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.title});
  final String title;
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool deletefunction = false;
  var c = Color.fromARGB(255, 202, 202, 202);
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: TextButton(
              child: Text(
                'Delete an App',
                style: TextStyle(
                    color: c, fontWeight: FontWeight.bold, fontSize: 24),
              ),
              onPressed: () {
                if (deletefunction) {
                  setState(() {
                    deletefunction = false;
                    c = Color.fromARGB(255, 202, 202, 202);
                  });
                } else {
                  setState(() {
                    deletefunction = true;
                    c = Colors.red;
                  });
                }
              },
            )),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<dynamic>>(
            future: entries(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    var row = snapshot.data![index];
                    return ListTile(
                      title: Center(
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.lightBlueAccent,
                              child: TextButton(
                                  child: Text(
                                    row[0].toString(),
                                    textScaleFactor: 2,
                                  ),
                                  onPressed: () async {
                                    if (deletefunction) {
                                      var client = PostgreSQLConnection(
                                          "localhost", 5432, "postgres",
                                          username: "postgres",
                                          password: "123",
                                          useSSL: false);
                                      await client.open();
                                      String x = row[0].toString();
                                      print(x);
                                      await client.query(
                                          "DELETE FROM apps WHERE appname = '$x'");
                                      await client.close();
                                      setState(() {
                                        deletefunction = false;
                                        c = Color.fromARGB(255, 202, 202, 202);
                                      });
                                    } else {
                                      var client = PostgreSQLConnection(
                                          "localhost", 5432, "postgres",
                                          username: "postgres",
                                          password: "123",
                                          useSSL: false);
                                      launchUrl(Uri.parse(row[3].toString()));
                                      await client.open();
                                      String x = row[0].toString();
                                      print(x);
                                      await client.query(
                                          "UPDATE apps SET downloads = downloads + 1 WHERE appname = '$x'");
                                      await client.close();
                                      setState(() {});
                                    }
                                  }))),
                      subtitle: Text(
                        (row[1].toString() +
                            ', ' +
                            row[2].toString() +
                            ', ' +
                            row[4].toString() +
                            ' Downloads'),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}

//END ADMIN ACCOUNT STUFF
class AddingScreen extends StatefulWidget {
  @override
  _AddingScreenState createState() => _AddingScreenState();
}

class _AddingScreenState extends State<AddingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Cancel')),
        body: Center(
          child: Column(
            children: [
              Card(
                  color: Color.fromARGB(255, 170, 131, 177),
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                              onChanged: (value) {
                                setState(() {
                                  appName = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'App Name',
                              )),
                          TextField(
                              onChanged: (value) {
                                setState(() {
                                  appType = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'App Category',
                              )),
                          TextField(
                              onChanged: (value) {
                                setState(() {
                                  appLink = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Github Link for App',
                              )),
                        ],
                      ))),
              TextButton(
                  onPressed: () async {
                    var client = PostgreSQLConnection(
                        "localhost", 5432, "postgres",
                        username: "postgres", password: "123", useSSL: false);
                    await client.open();
                    await client.query(
                        "INSERT INTO apps VALUES ('$appName', '$appType', '$username', '$appLink', 0)");
                    // Close the connection
                    await client.close();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DevScreen(
                              title: '',
                            )));
                  },
                  child: Text('Upload App'))
            ],
          ),
        ));
  }
}

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key, required this.title});
  final String title;
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('Log Out')),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<dynamic>>(
            future: entries(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    var row = snapshot.data![index];
                    return ListTile(
                      title: Center(
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.lightBlueAccent,
                              child: TextButton(
                                  child: Text(
                                    row[0].toString(),
                                    textScaleFactor: 2,
                                  ),
                                  onPressed: () async {
                                    var client = PostgreSQLConnection(
                                        "localhost", 5432, "postgres",
                                        username: "postgres",
                                        password: "123",
                                        useSSL: false);
                                    launchUrl(Uri.parse(row[3].toString()));
                                    await client.open();
                                    String x = row[0].toString();
                                    print(x);
                                    await client.query(
                                        "UPDATE apps SET downloads = downloads + 1 WHERE appname = '$x'");
                                    await client.close();
                                    setState(() {});
                                  }))),
                      subtitle: Text(
                        (row[1].toString() +
                            ', ' +
                            row[2].toString() +
                            ', ' +
                            row[4].toString() +
                            ' Downloads'),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
