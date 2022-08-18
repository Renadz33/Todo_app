import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'db_model.dart';


class TodoListWidget extends StatefulWidget {
  const TodoListWidget({Key? key}) : super(key: key);

  @override
  State<TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {

  void showToast(){
    Fluttertoast.showToast(
      msg: errMessage,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 5,
      fontSize: 15,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Widget build(BuildContext context){
    return FutureBuilder(
      builder: ((context, snapshot) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: showAlertDialog,
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
            backgroundColor:const Color(0xff5F7161),
          ),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 65,),
                const Padding(
                  padding: EdgeInsets.only(left: 15,top: 10,bottom: 20),
                  child: Text('Tasks',style: TextStyle(color: Color(0xff5F7161),fontSize: 22,fontWeight: FontWeight.bold),),
                ),
                Column(
                  children: childern,
                ),

              ]),

        );
      }),
      future: query(),
    );

  }
  final dbhelper = Databasehelper.instance;
  final todoController = TextEditingController();
  bool validated = false;
  String errMessage = "";
  String todoedited = "";
  List<Widget> childern = []; //list have all tasks
  var myTodos = [];

  //insert to database
  void addTodo() async {
    Map<String, dynamic> todo = {
      Databasehelper.columnName: todoedited,
    };
    final id = await dbhelper.insert(todo);
    // print(id);
    Navigator.of(context,rootNavigator: true).pop();
    todoedited = "";
    setState(() {
      validated = false;
      errMessage = "";
    });
  }
  // every alerDialog have shape, title, and content
  void showAlertDialog() {
    //to make textfield empty in the next task
    todoController.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text("What do you want to do?",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Color(0xff5F7161)),),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    cursorColor: const Color(0xff5F7161),
                    controller: todoController,
                    autofocus: true,
                    onChanged: (value) {
                      todoedited = value;
                    },
                    style: const TextStyle(fontSize: 17.0,color: Color(0xff5F7161)),
                    decoration: const InputDecoration(
                      focusedBorder:  UnderlineInputBorder(borderSide:  BorderSide(color: Color(0xff5F7161))),

                    ),
                  ),
                  const SizedBox(height: 5,),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xffD0C9C0),
                    ),
                    onPressed: (){
                      if (todoController.text.isEmpty) {
                        setState(() {
                          showToast();
                          errMessage = "Can't Be Empty";
                          validated = true;
                        });
                      } else if (todoController.text.length > 200) {
                        setState(() {
                          showToast();
                          errMessage = "Too Many Characters";
                          validated = true;
                        });
                      } else {
                        addTodo();
                      }
                    },
                    child:const Text('Done',style: TextStyle(fontSize: 17,color: Color(0xff5F7161)),),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<bool> query() async {
    myTodos = [];
    childern = [];
    //make query then make foreach for data and then add them to myTodos
    var allTodos = await dbhelper.queryAll();
    allTodos?.forEach((todo) {
      myTodos.add(todo.toString());
      childern.add(
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Card(
              color: Color(0xffD0C9C0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 5.0,
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Container(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  trailing: GestureDetector(
                      onTap: (){
                        dbhelper.deleteTodo(todo['id']); //delet item based on id
                        setState(() {});},
                      child: Icon(Icons.close)),
                  title: Text(
                    todo['todo'], // Value
                    style: const TextStyle(fontSize: 19.0,color: Color(0xff5F7161)),
                  ),
                  onLongPress: () {

                  },
                ),
              ),
            ),
          ));
    });
    return Future.value(true);
  }


}

//


