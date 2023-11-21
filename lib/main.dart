 import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:thiran_task2/Github.dart';
import 'package:getwidget/getwidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thiran Github Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Thiran Github Task'),
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
  PagingController pagingController = PagingController(firstPageKey : 1);
  //final List<int> _data =  List.generate(0, (index) => index);
  int pageSize = 1;
  late List<Github> githubData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    githubAPICall();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  // void loadData() {
  //   if(dataController.position.pixels == dataController.position.maxScrollExtent) {
  //     setState(() {
  //       _data.addAll(List.generate(10, (index) => _data.length + index));
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => pagingController.refresh()),
        child: PagedListView(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate(
              animateTransitions: true,
              newPageProgressIndicatorBuilder: (context) => const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 7.0,
                  ),
                ),
              ),
              transitionDuration: const Duration(milliseconds: 5000),
              // itemBuilder: (context,item,index) =>  ListTile(
              //   shape:  RoundedRectangleBorder(
              //     side: BorderSide(color: Colors.black, width: 1),
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   title: Text(githubData[index].name.toString()),
              //   subtitle: Text(githubData[index].description.toString()),
              // )
              //
              itemBuilder: (context,item,index) =>  GFListTile(
                titleText: githubData[index].name.toString(),
                subTitleText: 'Username: ${githubData[index].owner?.username.toString()} Stars: ${githubData[index].stars}',
                description: Text(githubData[index].description.toString()),
                avatar: Image.network(githubData[index].owner!.avatar.toString(),width:60,height:60)
              ),
          ),
        ),
      )
    );
  }


  Future<void> githubAPICall() async {
    try {
      http.Response response = await http.get(Uri.parse("https://api.github.com/search/repositories?q=created:>2022-04-29&sort=stars&order=desc&per_page=60"), headers: {"Content-Type": "application/json"});
      dynamic res = jsonDecode(response.body);
      final parsed = (res['items'] as List).cast<Map<String, dynamic>>();
      List<Github> dataList = parsed.map<Github>((e) => Github.fromJson(e)).toList();
      setState(() {
        githubData = dataList;
      });
    } catch(e) {
        print("service issue");
    }
  }

  Future<void> fetchPage(int pageKey) async {

    await Future.delayed(Duration(milliseconds:10000));
    try {
      //final newItems = List.generate(20, (index) => pageSize + index);
      List<Github> data = [];
      for(int i = (pageKey * 10);i < (pageKey * 10) + 10;i++) {
        data.add(githubData[i]);
      }

      //final isLastPage = newItems.length < pageSize;
      if(pageKey == 5) {
          pagingController.appendLastPage(data);
      } else {
          final nextPageKey = pageKey + 1;
          pagingController.appendPage(data, nextPageKey);
      }
      setState(() {
        pageSize += 20;
      });
    } catch (error) {
      pagingController.error = error;
    }
  }

  // Widget buildDataView() {
  //
  // }
}
