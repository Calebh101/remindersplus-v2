import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localpkg/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // status: true means complete, false means incomplete

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int mode = 1;
  String view = "all";

  bool allowReorder = true;
  bool showLists = true;
  bool showIncompleteRemindersAtBottom = true;

  List<Map<String, dynamic>> mainData = [
    {
      "name": "Buy groceries",
      "status": false,
      "date": "11/30/2024",
      "time": 28145184
    },
    {
      "name": "Complete project report",
      "status": true,
      "date": "12/1/2024",
      "time": 28145244
    },
    {
      "name": "Walk the dog",
      "status": false,
      "date": "12/2/2024",
      "time": 28145304
    },
    {
      "name": "Call mom",
      "status": true,
      "date": "11/30/2024",
      "time": 28145184
    },
    {
      "name": "Fix the leaky faucet",
      "status": false,
      "date": "12/2/2024",
      "time": 28145304
    },
    {
      "name": "Read 10 pages of a book",
      "status": true,
      "date": "12/1/2024",
      "time": 28145244
    },
    {
      "name": "Prepare for presentation",
      "status": false,
      "date": "11/30/2024",
      "time": 28145184
    },
    {
      "name": "Schedule dentist appointment",
      "status": false,
      "date": "12/2/2024",
      "time": 28145304
    },
    {
      "name": "Water the plants",
      "status": true,
      "date": "11/30/2024",
      "time": 28145184
    },
    {
      "name": "Reply to emails",
      "status": true,
      "date": "12/1/2024",
      "time": 28145244
    },
    {
      "name": "Clean the kitchen",
      "status": false,
      "date": "12/2/2024",
      "time": 28145304
    },
    {
      "name": "Organize files",
      "status": true,
      "date": "12/1/2024",
      "time": 28145244
    },
    {
      "name": "Workout for 30 minutes",
      "status": false,
      "date": "12/2/2024",
      "time": 28145304
    },
    {
      "name": "Plan weekend trip",
      "status": true,
      "date": "11/30/2024",
      "time": 28145184,
      "list": "List 2"
    },
    {
      "name": "Check the car's oil level",
      "status": false,
      "date": "12/1/2024",
      "time": 28145244,
      "list": "List 1"
    }
  ];

  Map itemCache = {
    "builtin": {
      "today": {
        "items": [],
      },
      "tomorrow": {
        "items": [],
      },
      "complete": {
        "items": [],
      },
      "incomplete": {
        "items": [],
      },
    },
    "user": {},
  };

  List items = [];
  //List lists = [];
  List keys = [];
  List currentItems = [];

  int allItemCount = 0;
  int completeItemCount = 0;
  int incompleteItemCount = 0;
  int currentItemCount = 0;

  late String key;

  void initState() {
    init();
    super.initState();
  }

  void init() async {
    keys = getKeys();
    key = keys[0];
    items = mainData;

    refresh(items);
  }

  List getKeys() {
    List keysS = [];
    for (Map item in mainData) {
      if (item.containsKey("list")) {
        if (!keysS.contains(item["list"])) {
          keysS.add(item["list"]);
        }
      }
    }
    return keysS;
  }

  void initializeUserKey(String list) {
    if (!itemCache["user"].containsKey(list)) {
      itemCache["user"][list] = {};
      itemCache["user"][list]["items"] = [];
    }
  }

  bool separateItems(List items, DateTime now) {
    print("separating items: initializing");

    itemCache["builtin"]["complete"]["items"] = [];
    itemCache["builtin"]["incomplete"]["items"] = [];
    itemCache["builtin"]["today"]["items"] = [];
    itemCache["builtin"]["tomorrow"]["items"] = [];

    print("separating items: starting sort");

    try {
      for (var item in items) {
        if (item["status"]) {
          itemCache["builtin"]["complete"]["items"].add(item);
        } else {
          itemCache["builtin"]["incomplete"]["items"].add(item);
        }
        if (item["date"] == DateFormat('M/d/yyyy').format(now)) {
          itemCache["builtin"]["today"]["items"].add(item);
        } if (item["date"] == DateFormat('M/d/yyyy').format(now.add(Duration(days: 1)))) {
          itemCache["builtin"]["tomorrow"]["items"].add(item);
        }
        if (item.containsKey("list")) {
          initializeUserKey(item["list"]);
          itemCache["user"][item["list"]]["items"].add(item);
        }
      }

      print("separating items: sort successful");
      return true;
    } catch (e) {
      throw Exception("separating items: sort unsuccessful: $e");
    }
  }

  String getTextForView(String view) {
    String result = view;
    switch(view) {
      case "all":
        result = "All Reminders";
      case "complete":
        result = "Complete Reminders";
      case "incomplete":
        result = "Incomplete Reminders";
      case "today":
        result = "Due Today";
      case "tomorrow":
        result = "Due Tomorrow";
      default:
        result = view;
    }
    return result;
  }

  String formatTime(int minutes) {
    return DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(minutes * 60000));
  }

  void changeView(String newView) {
    setState(() {
      view = newView;
    });
  }

  void refresh(data) {
    print("refreshing...");
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('building...');
    DateTime now = DateTime.now();

    separateItems(items, now);
    initializeUserKey(view);
    keys = getKeys();

    currentItems = view != "all" 
    ? (itemCache["builtin"].containsKey(view) 
        ? itemCache["builtin"][view]["items"] 
        : itemCache["user"][view]["items"]
      ) 
    : mainData;

    allItemCount = mainData.length;
    currentItemCount = items.length;
    completeItemCount = itemCache["builtin"]["complete"]["items"].length;
    incompleteItemCount = itemCache["builtin"]["incomplete"]["items"].length;

    if (showIncompleteRemindersAtBottom) {
      items = itemCache["builtin"]["incomplete"]["items"] + itemCache["builtin"]["complete"]["items"];
    }

    print("building widgets...");
    return Scaffold(
      appBar: AppBar(
        title: Text(getTextForView(view)),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(FontAwesomeIcons.bars),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: () async {
              dynamic response = await editItem({"name": "", "status": false}, 2);
              if (response != null && !response.containsKey("invalid")) {
                int index = mainData.length;
                response = checkId(response);
                response["status"] ??= false;
                response["date"] ??= DateFormat('M/d/yyyy').format(DateTime.now());
                response["time"] ??= DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 60000;
                setAlertShortcut(1, index, response);
                print("adding item");
                mainData.add(response);
                refresh(mainData);
              } else {
                print("not adding item");
              }
            },
          ),
          IconButton(
            icon: Icon(mode == 1 ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.listCheck),
            onPressed: () {
              mode = mode == 1 ? 2 : 1;
              refresh(items);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("Lists", style: TextStyle(fontSize: 28)),
            SettingTitle(title: "Categories"),
            ListTile(
              leading: Icon(FontAwesomeIcons.listCheck),
              title: Text("All Reminders"),
              subtitle: Text("$allItemCount reminders"),
              onTap: () {
                changeView("all");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.squareCheck),
              title: Text("Complete"),
              subtitle: Text("$completeItemCount reminders"),
              onTap: () {
                changeView("complete");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.square),
              title: Text("Incomplete"),
              subtitle: Text("$incompleteItemCount reminders"),
              onTap: () {
                changeView("incomplete");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.calendarDay),
              title: Text("Today"),
              subtitle: Text(DateFormat('MMMM d').format(now)),
              onTap: () {
                changeView("today");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.calendarDays),
              title: Text("Tomorrow"),
              subtitle: Text(DateFormat('MMMM d').format(now.add(Duration(days: 1)))),
              onTap: () {
                changeView("tomorrow");
                Navigator.pop(context);
              },
            ),
            showLists ? Column(
              children: [
                SettingTitle(title: "Custom lists"),
                for (var item in keys)
                  ListTile(
                    title: Text(item),
                    leading: Icon(FontAwesomeIcons.listCheck),
                    onTap: () {
                      changeView(item);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ) : SizedBox.shrink(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            itemsBuilder(mode, items, "all", allowReorder, (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              refresh(items);
            }),
          ],
        ),
      ),
    );
  }

  Map checkId(Map item) {
    if (!item.containsKey("id")) {
      item["id"] = getId(item);
    }
    return item;
  }

  Map setAlertShortcut(int mode, int index, Map response) {
    response = checkId(response);
    int id = response["id"];

    response["alert"] =
      response.containsKey("alert")
        ? (response["alert"]
          ? setAlert(
            index,
            !response["alert"],
            id,
          )
          : setAlert(
            index,
            true,
            id,
          )
        )
      : setAlertShortcut(1, index, response);

    return response;
  }

  Future<bool> setAlert(int index, bool value, int id) async {
    if (value) {
      // TODO: implement set notification
    } else {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
    return true;
  }

  String getId(Map item) {
    return "${item["name"]}-${item["time"]}";
  }

  Future<String?> _showInputDialog(BuildContext context) async {
    final TextEditingController textEditingController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Your Input'),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(hintText: 'Type something here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog with no result
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(textEditingController.text); // Return the input
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<Map> editItem(reminder, int mode) async {
    print("edit reminder: initializing");

    final TextEditingController stringController =
        TextEditingController(text: reminder["name"]);

    String? _selectedDate = reminder.containsKey("date") ? reminder["date"] : null;
    DateTime _selectedDateObject;
    int? _selectedTime = reminder.containsKey("time") ? reminder["time"] : null;

    bool useValues = false;
    String? selectedItem = reminder.containsKey("list") ? reminder["list"] : "No list";
    String? customSelectedOption;

    List options = keys;
    options.add("No list");
    options.add("New list");

    print("edit reminder: starting");

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${mode == 1 ? "Edit" : "Add"} Reminder'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: stringController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  DropdownButton<String>(
                    value: selectedItem,
                    onChanged: (String? newValue) async {
                      if (newValue == "New list") {
                        String? result = await _showInputDialog(context);
                        if (result != null && result != "") {
                          selectedItem = newValue;
                          customSelectedOption = result;
                        }
                      } else {
                        selectedItem = newValue;
                      }
                      setState(() {});
                    },
                    items: keys.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  InkWell(
                    onTap: () async {
                      String defaultDate;
                      int defaultTime;

                      if (_selectedTime != null) {
                        defaultTime = _selectedTime!;
                      } else {
                        defaultTime = DateTime.now().hour * 60 + DateTime.now().minute;
                      }

                      if (_selectedDate != null) {
                        defaultDate = _selectedDate!;
                      } else {
                        DateTime dateTime = DateTime.now();
                        defaultDate = "${dateTime.month}/${dateTime.day}/${dateTime.year}";
                      }

                      // Correct format conversion
                      DateTime defaultDate2 = DateTime.parse("${defaultDate.split('/')[2]}-${defaultDate.split('/')[0].padLeft(2, '0')}-${defaultDate.split('/')[1].padLeft(2, '0')}");
                      print("defaultDate: $defaultDate, $defaultDate2");

                      print("defaultTime: $defaultTime");

                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: defaultDate2,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        DateTime dateTime = picked;
                        _selectedDateObject = picked;

                        setState(() {
                          _selectedDate = "${dateTime.month}/${dateTime.day}/${dateTime.year}";
                        });

                        final TimeOfDay? picked2 = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: (defaultTime ~/ 60) % 24, minute: defaultTime % 60),
                        );

                        if (picked2 != null && picked2 != _selectedTime) {
                          setState(() {
                            _selectedTime = _selectedDateObject.millisecondsSinceEpoch ~/ 60000 + (picked2.hour * 60 + picked2.minute);
                          });
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            "Date and Time${_selectedDate != null && _selectedTime != null ? ": $_selectedDate at ${formatTime(_selectedTime!)}" : ""}",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                useValues = false;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                useValues = true;
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (useValues) {
      print("edit reminder: using values");

      String name =
          stringController.text == '' ? reminder["name"] : stringController.text;

      reminder["name"] = name;
      reminder["status"] = false;
      if (selectedItem != "No list") {reminder["list"] = selectedItem == "New list" ? customSelectedOption : selectedItem;}
      if (_selectedDate != null) {reminder["date"] = _selectedDate;}
      if (_selectedTime != null) {reminder["time"] = _selectedTime;}
    } else {
      print("edit reminder: not using values");
      reminder = {"invalid": true};
    }

    print("edit reminder: complete");
    return reminder;
  }

  Widget itemsBuilder(int mode, List items, String name, bool showReorderHandles, ReorderCallback onReorder) {
    bool overrideShowReorderHandles = false;
    return ReorderableListView.builder(
      buildDefaultDragHandles: overrideShowReorderHandles,
      onReorder: onReorder,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        Map item = items[index];
        if (currentItems.contains(item)) {
          return Container(
            key: Key("$name$index"),
            padding: EdgeInsets.only(left: 6.0, right: 10.0, top: 4.0, bottom: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mode == 1) Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(item["status"] ? FontAwesomeIcons.squareCheck : FontAwesomeIcons.square),
                      onPressed: () {
                        items[index]["status"] = !items[index]["status"];
                        refresh(items);
                      },
                    ),
                  ],
                ) else Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(FontAwesomeIcons.trash),
                      style: ButtonStyle(
                        iconColor: WidgetStatePropertyAll(item["status"] ? Colors.blueAccent : Colors.redAccent),
                      ),
                      onPressed: () {
                        items.removeAt(index);
                        refresh(items);
                      },
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.penToSquare),
                      onPressed: () async {
                        Map response = await editItem(item, 1);
                        if(response != null && !response.containsKey("invalid")) {
                          setState(() {
                            items[index] = response;
                            refresh(items);
                          });
                        }
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${item.containsKey("date") ? item["date"] : "No date"} ${item.containsKey("time") ? "at ${formatTime(item["time"])}" : ""}",
                    ),
                  ],
                ),
                Spacer(),
                if (showReorderHandles && !overrideShowReorderHandles)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(FontAwesomeIcons.gripLines),
                  ),
              ],
            ),
          );
        } else {
          return SizedBox.shrink(
            key: Key("$name$index"),
          );
        }
      },
    );
  }

  Widget DrawerTitle({required String title}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }
}