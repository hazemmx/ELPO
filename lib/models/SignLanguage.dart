import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignLanguageSymbol {
  final String title;
  final String image;
  final String description;

  SignLanguageSymbol({
    required this.title,
    required this.image,
    required this.description,
  });
}

List<SignLanguageSymbol> symbols = [
  // SignLanguageSymbol(
  //   title: "I",
  //   image: "assets/img/IinSign.jpg",
  //   description: "Gesture of the letter 'I' in sign language.",
  // ),
  // SignLanguageSymbol(
  //   title: "Want",
  //   image: "assets/img/wantinSign.jpg",
  //   description: "Gesture of the word 'Want' in sign language.",
  // ),
  // SignLanguageSymbol(
  //   title: "to",
  //   image: "assets/img/toinSign.jpg",
  //   description: "Gesture of the word 'to' in sign language.",
  // ),
  // SignLanguageSymbol(
  //   title: "Say",
  //   image: "assets/img/sayinSign.jpg",
  //   description: "Gesture of the word 'Say' in sign language.",
  // ),
  // SignLanguageSymbol(
  //   title: "Thank",
  //   image: "assets/img/thankinSign.jpg",
  //   description: "Gesture of the word 'Thank' in sign language.",
  // ),
  // SignLanguageSymbol(
  //   title: "You",
  //   image: "assets/img/youinSign.jpg",
  //   description: "Gesture of the word 'You' in sign language.",
  // ),
];
Future<void> fetchandSet() async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    // remove in the release
    email: 'h@gmail.com',
    password: '123456',
  );

  final CollectionReference symbolsCollection =
      FirebaseFirestore.instance.collection("lan");

  List<SignLanguageSymbol> loadedSymbols = [];

  QuerySnapshot querySnapshot = await symbolsCollection.get();
  print(querySnapshot.docs.length);

  for (int i = 0; i < querySnapshot.docs.length; i++) {
    DocumentSnapshot doc = querySnapshot.docs[i];

    String imageDownloadUrl = await FirebaseStorage.instance
        .ref(doc[
            'image']) // Assuming the 'image' field is a path to the image in storage
        .getDownloadURL();

    loadedSymbols.add(SignLanguageSymbol(
      description: doc['description'] ?? '',
      image: imageDownloadUrl, // Use the download URL instead of the path
      title: doc['title'] ?? '',
    ));

    print(loadedSymbols[i].title);
  }

  print("Success if above isn't null");
  symbols = loadedSymbols;
}
// Add more symbols as needed

Future<List<SignLanguageSymbol>> searchSymbols(String sentence) async {
  if (symbols.isEmpty) {
    print("Empty reached search");
    await fetchandSet();
  }

  List<SignLanguageSymbol> matchedSymbols = [];
  List<String> words = sentence.split(' ');

  for (String word in words) {
    for (SignLanguageSymbol symbol in symbols) {
      if (symbol.title.toLowerCase() == word.toLowerCase()) {
        matchedSymbols.add(symbol);
        break;
      }
    }
  }

  return matchedSymbols;
}
