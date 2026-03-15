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

  final Map<String, GlobalKey> verseKeys = {};

  // బైబిల్ లోని 66 పుస్తకాల పేర్ల పూర్తి లిస్ట్ (English to Telugu Map)
  final Map<String, String> teluguBookNames = {
    // పాత నిబంధన (Old Testament)
    'Genesis': 'ఆదికాండము',
    'Exodus': 'నిర్గమకాండము',
    'Leviticus': 'లేవీయకాండము',
    'Numbers': 'సంఖ్యాకాండము',
    'Deuteronomy': 'ద్వితీయోపదేశకాండము',
    'Joshua': 'యెహోషువ',
    'Judges': 'న్యాయాధిపతులు',
    'Ruth': 'రూతు',
    '1 Samuel': '1 సమూయేలు',
    '2 Samuel': '2 సమూయేలు',
    '1 Kings': '1 రాజులు',
    '2 Kings': '2 రాజులు',
    '1 Chronicles': '1 దినవృత్తాంతములు',
    '2 Chronicles': '2 దినవృత్తాంతములు',
    'Ezra': 'ఎజ్రా',
    'Nehemiah': 'నెహెమ్యా',
    'Esther': 'ఎస్తేరు',
    'Job': 'యోబు',
    'Psalms': 'కీర్తనల గ్రంథము',
    'Proverbs': 'సామెతలు',
    'Ecclesiastes': 'ప్రసంగి',
    'Song of Solomon': 'పరమగీతములు',
    'Song of Songs': 'పరమగీతములు', // Some XMLs use this
    'Isaiah': 'యెషయా',
    'Jeremiah': 'యిర్మీయా',
    'Lamentations': 'విలాపవాక్యములు',
    'Ezekiel': 'యెహెజ్కేలు',
    'Daniel': 'దానియేలు',
    'Hosea': 'హోషేయ',
    'Joel': 'యోవేలు',
    'Amos': 'ఆమోసు',
    'Obadiah': 'ఓబద్యా',
    'Jonah': 'యోనా',
    'Micah': 'మీకా',
    'Nahum': 'నహూము',
    'Habakkuk': 'హబక్కూకు',
    'Zephaniah': 'జెఫన్యా',
    'Haggai': 'హగ్గయి',
    'Zechariah': 'జెకర్యా',
    'Malachi': 'మలాకీ',

    // క్రొత్త నిబంధన (New Testament)
    'Matthew': 'మత్తయి సువార్త',
    'Mark': 'మార్కు సువార్త',
    'Luke': 'లూకా సువార్త',
    'John': 'యోహాను సువార్త',
    'Acts': 'అపొస్తలుల కార్యములు',
    'Romans': 'రోమీయులకు',
    '1 Corinthians': '1 కొరింథీయులకు',
    '2 Corinthians': '2 కొరింథీయులకు',
    'Galatians': 'గలతీయులకు',
    'Ephesians': 'ఎఫెసీయులకు',
    'Philippians': 'ఫిలిప్పీయులకు',
    'Colossians': 'కొలస్సీయులకు',
    '1 Thessalonians': '1 థెస్సలొనీకయులకు',
    '2 Thessalonians': '2 థెస్సలొనీకయులకు',
    '1 Timothy': '1 తిమోతికి',
    '2 Timothy': '2 తిమోతికి',
    'Titus': 'తీతుకు',
    'Philemon': 'ఫిలేమోనుకు',
    'Hebrews': 'హెబ్రీయులకు',
    'James': 'యాకోబు',
    '1 Peter': '1 పేతురు',
    '2 Peter': '2 పేతురు',
    '1 John': '1 యోహాను',
    '2 John': '2 యోహాను',
    '3 John': '3 యోహాను',
    'Jude': 'యూదా',
    'Revelation': 'ప్రకటన గ్రంథము',
  };

  String getTeluguName(String englishName) {
    return teluguBookNames[englishName] ?? englishName;
  }

  @override
  void initState() {
    super.initState();
    futureBibleBooks = loadBibleData().then((books) {
      if (books.isNotEmpty) {
        setState(() {
          allBooks = books;
          selectedBook = books.first;
          if (selectedBook!.chapters.isNotEmpty) {
            selectedChapter = selectedBook!.chapters.first;
          }
        });
      }
      return books;
    });
  }

  void scrollToVerse(String vnumber) {
    final key = verseKeys[vnumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, 
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('పరిశుద్ధ గ్రంథము', style: TextStyle(color: Colors.amber)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<BibleBook>>(
        future: futureBibleBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('డేటా లోడ్ అవ్వలేదు. ఫైల్ చెక్ చేయండి.'));
          }

          return Column(
            children: [
              // --- Top Dropdown Menu (Book > Chapter > Verse) ---
              Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  children: [
                    // 1. Book Dropdown
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BibleBook>(
                            isExpanded: true,
                            dropdownColor: Colors.grey[900],
                            value: selectedBook,
                            items: allBooks.map((book) {
                              return DropdownMenuItem(
                                value: book,
                                child: Text(
                                  getTeluguName(book.bname),
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (BibleBook? newBook) {
                              if (newBook != null) {
                                setState(() {
                                  selectedBook = newBook;
                                  selectedChapter = newBook.chapters.isNotEmpty ? newBook.chapters.first : null;
                                  selectedVerse = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 2. Chapter Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Chapter>(
                            isExpanded: true,
                            dropdownColor: Colors.grey[900],
                            value: selectedChapter,
                            hint: const Text('అధ్యా', style: TextStyle(fontSize: 12)),
                            items: selectedBook?.chapters.map((chapter) {
                              return DropdownMenuItem(
                                value: chapter,
                                child: Text('అధ్యా ${chapter.cnumber}', style: const TextStyle(fontSize: 13, color: Colors.white)),
                              );
                            }).toList() ?? [],
                            onChanged: (Chapter? newChapter) {
                              if (newChapter != null) {
                                setState(() {
                                  selectedChapter = newChapter;
                                  selectedVerse = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 3. Verse Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Verse>(
                            isExpanded: true,
                            dropdownColor: Colors.grey[900],
                            value: selectedVerse,
                            hint: const Text('వచనం', style: TextStyle(fontSize: 12)),
                            items: selectedChapter?.verses.map((verse) {
                              return DropdownMenuItem(
                                value: verse,
                                child: Text('వచనం ${verse.vnumber}', style: const TextStyle(fontSize: 13, color: Colors.white)),
                              );
                            }).toList() ?? [],
                            onChanged: (Verse? newVerse) {
                              if (newVerse != null) {
                                setState(() {
                                  selectedVerse = newVerse;
                                });
                                scrollToVerse(newVerse.vnumber);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.amber),

              // --- Reading Area (Verses List) ---
              Expanded(
                child: selectedChapter == null
                    ? const Center(child: Text('ఈ పుస్తకంలో అధ్యాయాలు లేవు'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: selectedChapter!.verses.length,
                        itemBuilder: (context, index) {
                          final verse = selectedChapter!.verses[index];
                          
                          verseKeys[verse.vnumber] ??= GlobalKey();
                          bool isHighlighted = selectedVerse?.vnumber == verse.vnumber;

                          return Container(
                            key: verseKeys[verse.vnumber],
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: isHighlighted ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: isHighlighted ? Colors.amber.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.6),
                                children: [
                                  TextSpan(
                                    text: '${verse.vnumber}. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: isHighlighted ? Colors.amber : Colors.amber[700]
                                    ),
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
          );
        },
      ),
    );
  }
}
