import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_diary/add_page.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({
    super.key,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  Directory? directory;
  String filePath = '';
  String fileName = 'zzxx.json';

  dynamic myList = const Text(
    '준비',
    style: TextStyle(fontSize: 100),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPath().then((value) {
      showList();
    });
  }

  Future<void> getPath() async {
    directory = await getApplicationDocumentsDirectory();
    //서포트 디렉토리는 모든 플렛폼에서 지원
    if (directory != null) {
      filePath = '${directory!.path}/$fileName';
      print(filePath);
    }
  }

  Future<void> showList() async {
    try {
      var file = File(filePath);
      if (file.existsSync()) {
        setState(() {
          myList = FutureBuilder(
            future: file.readAsString(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var dataList = jsonDecode(snapshot.data!) as List<dynamic>;
                return ListView.separated(
                    itemBuilder: (context, index) {
                      var data = dataList[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['title']),
                        subtitle: Text(data['contents']),
                        trailing: const Icon(Icons.delete),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: dataList.length);
              } else {
                return const CircularProgressIndicator();
              }
            },
          );
        });
      } else {
        print('암것도 없어용');
      }
    } catch (e) {
      print('errer');
    }
  }

  deleteFile() {
    try {
      var file = File(filePath);
      file.delete();
      setState(() {});
    } catch (e) {
      print('delete error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: showList, child: const Text('조회')),
              ElevatedButton(onPressed: deleteFile, child: const Text('삭제'))
            ],
          ),
          Expanded(child: myList)
        ]),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(filePath: filePath),
              ),
            ); //context 화면 순서 관리,
            if (result == "ok") {
              showList();
            }
          },
          child: const Icon(
            Icons.add_circle_outline,
            size: 40,
          )),
    );
  }
}
