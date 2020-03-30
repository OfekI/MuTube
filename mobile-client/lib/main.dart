import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mutube/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: Scaffold(
        appBar: AppBar(
          title: Text('MuTube'),
          backgroundColor: Colors.amber,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () => AuthService.googleSignIn(),
                color: Colors.white,
                textColor: Colors.black,
                child: Text('Log In with Google'),
              ),
              MaterialButton(
                onPressed: () => AuthService.signOut(),
                color: Colors.red,
                textColor: Colors.black,
                child: Text('Log Out'),
              ),
              StreamBuilder(
                stream: AuthService.isLoading,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Stream Error',
                      style: TextStyle(color: Colors.red),
                    );
                  } else {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text(
                          'Press Log In',
                          style: TextStyle(color: Colors.black),
                        );
                      case ConnectionState.waiting:
                        return Text(
                          'Awaiting Data',
                          style: TextStyle(color: Colors.blue),
                        );
                      case ConnectionState.active:
                        return Text(
                          'Loading: ${snapshot.data}',
                          style: TextStyle(color: Colors.green),
                        );
                      case ConnectionState.done:
                        return Text(
                          'Loading: ${snapshot.data} (closed)',
                          style: TextStyle(color: Colors.black),
                        );
                    }
                  }
                  return null;
                },
              ),
              StreamBuilder(
                stream: AuthService.user,
                builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
                  if (snapshot.hasError)
                    return Text('Error in user stream');
                  else if (snapshot.hasData) {
                    return Text('${snapshot.data.displayName}');
                  } else
                    return Text('no data');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
