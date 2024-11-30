import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();
  // text controller for note input
  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docId}) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: TextField(
          controller:  textController,
        ),
        actions: [
          // button save
          ElevatedButton(
            onPressed: () {
              // add a new note
              if (docId == null) {
                firestoreService.addNote(textController.text);
              } else {
                // update note
                firestoreService.updateNote(docId, textController.text);
              }

              textController.clear();
              Navigator.of(context).pop();
            }, 
            child: const Text('Add')
          ),
        ],
        
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if we have data, get all the notes
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docId = document.id;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //update button
                      IconButton(
                        onPressed:() => openNoteBox(docId: docId),
                        icon: const Icon(Icons.settings),
                      ),
                      //delete button
                      IconButton(
                        onPressed:() => firestoreService.deleteNotes(docId),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),

                );
              },
            );


          } else {
            return const Text('no notes...');
          }
        },
      ),
    );
  }
}