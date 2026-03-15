import 'package:flutter/material.dart';
import 'bible_data.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  late Future<List<BibleBook>> futureBibleBooks;

  @override
  void initState() {
    super.initState();
    futureBibleBooks = loadBibleData(); // యాప్ ఓపెన్ అవ్వగానే XML లోడ్ అవుతుంది
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('పరిశుద్ధ గ్రంథము'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<BibleBook>>(
        future: futureBibleBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('బైబిల్ డేటా లోడ్ అవ్వలేదు. ఫైల్ చెక్ చేయండి.'));
          }

          final books = snapshot.data!;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber[700],
                    child: Text(book.bnumber, style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(book.bname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                  onTap: () {
                    // బుక్ క్లిక్ చేసినప్పుడు చాప్టర్స్ స్క్రీన్ కి వెళ్తుంది
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// చాప్టర్స్ మరియు వచనాలు చూపించే స్క్రీన్
class ChapterScreen extends StatefulWidget {
  final BibleBook book;
  const ChapterScreen({super.key, required this.book});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  int selectedChapterIndex = 0; // డీఫాల్ట్ గా 1వ అధ్యాయం చూపిస్తుంది

  @override
  Widget build(BuildContext context) {
    final chapters = widget.book.chapters;
    final currentChapter = chapters.isNotEmpty ? chapters[selectedChapterIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.bname),
      ),
      body: Column(
        children: [
          // చాప్టర్స్ నంబర్స్ (హారిజాంటల్ స్క్రోల్)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final isSelected = selectedChapterIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedChapterIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber[700] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        chapters[index].cnumber,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey),
          
          // సెలెక్ట్ చేసిన చాప్టర్ లోని వచనాలు
          Expanded(
            child: currentChapter == null
                ? const Center(child: Text('ఈ అధ్యాయంలో వచనాలు లేవు'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: currentChapter.verses.length,
                    itemBuilder: (context, index) {
                      final verse = currentChapter.verses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
                            children: [
                              TextSpan(
                                text: '${verse.vnumber}. ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                              TextSpan(text: verse.text),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
