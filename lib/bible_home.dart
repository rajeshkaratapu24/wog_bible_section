import 'package:flutter/material.dart';
import 'bible_data.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  late Future<List<BibleBook>> futureBibleBooks;
  
  List<BibleBook> allBooks = [];
  BibleBook? selectedBook;
  Chapter? selectedChapter;
  Verse? selectedVerse;

  final Color bgColor = const Color(0xFF121212); 
  final Color headerBoxColor = const Color(0xFF1E1E1E); 
  final Color goldText = const Color(0xFFE5A853); 
  final Color greyText = const Color(0xFF7A7A7A); 
  final Color dividerColor = const Color(0xFF2A2A2A); 

  final Map<String, String> teluguBookNames = {
    'Genesis': 'ఆదికాండము', 'Exodus': 'నిర్గమకాండము', 'Leviticus': 'లేవీయకాండము',
    'Numbers': 'సంఖ్యాకాండము', 'Deuteronomy': 'ద్వితీయోపదేశకాండము', 'Joshua': 'యెహోషువ',
    'Judges': 'న్యాయాధిపతులు', 'Ruth': 'రూతు', '1 Samuel': '1 సమూయేలు',
    '2 Samuel': '2 సమూయేలు', '1 Kings': '1 రాజులు', '2 Kings': '2 రాజులు',
    '1 Chronicles': '1 దినవృత్తాంతములు', '2 Chronicles': '2 దినవృత్తాంతములు', 'Ezra': 'ఎజ్రా',
    'Nehemiah': 'నెహెమ్యా', 'Esther': 'ఎస్తేరు', 'Job': 'యోబు',
    'Psalms': 'కీర్తనల గ్రంథము', 'Proverbs': 'సామెతలు', 'Ecclesiastes': 'ప్రసంగి',
    'Song of Solomon': 'పరమగీతములు', 'Song of Songs': 'పరమగీతములు', 'Isaiah': 'యెషయా',
    'Jeremiah': 'యిర్మీయా', 'Lamentations': 'విలాపవాక్యములు', 'Ezekiel': 'యెహెజ్కేలు',
    'Daniel': 'దానియేలు', 'Hosea': 'హోషేయ', 'Joel': 'యోవేలు',
    'Amos': 'ఆమోసు', 'Obadiah': 'ఓబద్యా', 'Jonah': 'యోనా',
    'Micah': 'మీకా', 'Nahum': 'నహూము', 'Habakkuk': 'హబక్కూకు',
    'Zephaniah': 'జెఫన్యా', 'Haggai': 'హగ్గయి', 'Zechariah': 'జెకర్యా',
    'Malachi': 'మలాకీ', 'Matthew': 'మత్తయి సువార్త', 'Mark': 'మార్కు సువార్త',
    'Luke': 'లూకా సువార్త', 'John': 'యోహాను సువార్త', 'Acts': 'అపొస్తలుల కార్యములు',
    'Romans': 'రోమీయులకు', '1 Corinthians': '1 కొరింథీయులకు', '2 Corinthians': '2 కొరింథీయులకు',
    'Galatians': 'గలతీయులకు', 'Ephesians': 'ఎఫెసీయులకు', 'Philippians': 'ఫిలిప్పీయులకు',
    'Colossians': 'కొలస్సీయులకు', '1 Thessalonians': '1 థెస్సలొనీకయులకు', '2 Thessalonians': '2 థెస్సలొనీకయులకు',
    '1 Timothy': '1 తిమోతికి', '2 Timothy': '2 తిమోతికి', 'Titus': 'తీతుకు',
    'Philemon': 'ఫిలేమోనుకు', 'Hebrews': 'హెబ్రీయులకు', 'James': 'యాకోబు',
    '1 Peter': '1 పేతురు', '2 Peter': '2 పేతురు', '1 John': '1 యోహాను',
    '2 John': '2 యోహాను', '3 John': '3 యోహాను', 'Jude': 'యూదా',
    'Revelation': 'ప్రకటన గ్రంథము',
  };

  String getTeluguName(String englishName) {
    return teluguBookNames[englishName] ?? englishName;
  }

  @override
  void initState() {
    super.initState();
    futureBibleBooks = loadBibleData().then((books) {
      if (mounted && books.isNotEmpty) {
        setState(() {
          allBooks = books;
          selectedBook = books.first;
          if (selectedBook!.chapters.isNotEmpty) {
            selectedChapter = selectedBook!.chapters.first;
            if (selectedChapter!.verses.isNotEmpty) {
              selectedVerse = selectedChapter!.verses.first;
            }
          }
        });
      }
      return books;
    });
  }

  Widget _buildTopSelectionBox(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: headerBoxColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: goldText, fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _showVerseDialog(Verse verse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: headerBoxColor,
          title: Text(
            '${getTeluguName(selectedBook?.bname ?? "")} ${selectedChapter?.cnumber}:${verse.vnumber}',
            style: TextStyle(color: goldText),
          ),
          content: SingleChildScrollView(
            child: Text(
              verse.text,
              style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: goldText)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        title: const Text('W   O   G', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2.0)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.light_mode_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      
      body: FutureBuilder<List<BibleBook>>(
        future: futureBibleBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: goldText));
          } else if (snapshot.hasError) {
            // ఎర్రర్ ఉంటే స్క్రీన్ మీద చూపిస్తుంది
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('డేటా లోడ్ అవ్వలేదు.', style: TextStyle(color: Colors.white)));
          }

          return Column(
            children: [
              Container(
                color: bgColor,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    _buildTopSelectionBox(getTeluguName(selectedBook?.bname ?? ""), flex: 4),
                    const SizedBox(width: 12),
                    _buildTopSelectionBox(selectedChapter?.cnumber ?? "", flex: 2),
                    const SizedBox(width: 12),
                    _buildTopSelectionBox(selectedVerse?.vnumber ?? "", flex: 2),
                  ],
                ),
              ),
              
              Divider(height: 1, color: dividerColor, thickness: 1),

              Expanded(
                child: Row(
                  children: [
                    // --- BOOKS COLUMN ---
                    Expanded(
                      flex: 4,
                      child: ListView.builder(
                        itemCount: allBooks.length,
                        itemBuilder: (context, index) {
                          final book = allBooks[index];
                          final isSelected = selectedBook?.bname == book.bname;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedBook = book;
                                selectedChapter = book.chapters.isNotEmpty ? book.chapters.first : null;
                                selectedVerse = selectedChapter?.verses.isNotEmpty == true ? selectedChapter!.verses.first : null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  getTeluguName(book.bname),
                                  style: TextStyle(
                                    fontSize: 16, color: isSelected ? goldText : greyText,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(width: 1, color: dividerColor),

                    // --- CHAPTERS COLUMN ---
                    Expanded(
                      flex: 2,
                      child: selectedBook == null ? const SizedBox() : ListView.builder(
                        itemCount: selectedBook!.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = selectedBook!.chapters[index];
                          final isSelected = selectedChapter?.cnumber == chapter.cnumber;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedChapter = chapter;
                                selectedVerse = chapter.verses.isNotEmpty ? chapter.verses.first : null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  chapter.cnumber,
                                  style: TextStyle(
                                    fontSize: 16, color: isSelected ? goldText : greyText,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(width: 1, color: dividerColor),

                    // --- VERSES COLUMN ---
                    Expanded(
                      flex: 2,
                      child: selectedChapter == null ? const SizedBox() : ListView.builder(
                        itemCount: selectedChapter!.verses.length,
                        itemBuilder: (context, index) {
                          final verse = selectedChapter!.verses[index];
                          final isSelected = selectedVerse?.vnumber == verse.vnumber;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedVerse = verse;
                              });
                              _showVerseDialog(verse); // వచనం చదవడానికి పాపప్
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  verse.vnumber,
                                  style: TextStyle(
                                    fontSize: 16, color: isSelected ? goldText : greyText,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black, border: Border(top: BorderSide(color: dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black, type: BottomNavigationBarType.fixed, currentIndex: 1,
          selectedItemColor: Colors.white, unselectedItemColor: greyText,
          selectedFontSize: 10, unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_outlined)), label: 'HOME'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.menu_book)), label: 'BIBLE'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.music_note_outlined)), label: 'SONGS'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.album_outlined)), label: 'TRACK'),
          ],
        ),
      ),
    );
  }
}
