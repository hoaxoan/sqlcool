import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import 'dialogs.dart';

class _PageSelectBlocState extends State<PageSelectBloc> {
  SelectBloc bloc;
  StreamSubscription _changefeed;

  @override
  void initState() {
    // declare the query
    this.bloc = SelectBloc(table: "items", orderBy: 'name', reactive: true);
    // listen for changes in the database
    _changefeed = db.changefeed.listen((change) {
      print("CHANGE IN THE DATABASE:");
      print("Change type: ${change.changeType}");
      print("Number of items impacted: ${change.value}");
      print("Query: ${change.query}");
    });
    super.initState();
  }

  @override
  void dispose() {
    _changefeed.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sqlcool"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => insertItemDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Map>>(
          stream: bloc.items,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              // the select query has not found anything
              if (snapshot.data.length == 0) {
                return Center(
                  child: Text(
                      "No data. Use the + in the appbar to insert an item"),
                );
              }
              // the select query has results
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var item = snapshot.data[index];
                    return ListTile(
                      title: GestureDetector(
                        child: Text(item["name"]),
                        onTap: () => updateItemDialog(context, item["name"]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.grey,
                        onPressed: () =>
                            deleteItemDialog(context, item["name"], item["id"]),
                      ),
                    );
                  });
            } else {
              // the select query is still running
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

class PageSelectBloc extends StatefulWidget {
  @override
  _PageSelectBlocState createState() => _PageSelectBlocState();
}
