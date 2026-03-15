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

  // Premium Colors
  final Color bgColor = const Color(0xFF121212); // Deep Black
  final Color surfaceColor = const Color(0xFF1E1E1E); // Dark Grey Surface
  final Color goldAccent = const Color(0xFFD4AF37); // Classic Gold
  final Color textPrimary = const Color(0xFFE0E0E0); // Soft White for reading

  final Map<String, String> teluguBookNames = {
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
    'Song of Songs': 'పరమగీతములు',
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
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        alignment: 0.15,
      );
    }
  }

  // డ్రాప్ డౌన్ కి ప్రీమియం లుక్ ఇచ్చే రీయూజబుల్ విడ్జెట్
  Widget _buildCustomDropdown({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'పరిశుద్ధ గ్రంథము',
          style: TextStyle(
            color: goldAccent,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: surfaceColor, height: 1.0),
        ),
      ),
      body: FutureBuilder<List<BibleBook>>(
        future: futureBibleBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: goldAccent));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('డేటా లోడ్ అవ్వలేదు. ఫైల్ చెక్ చేయండి.', style: TextStyle(color: textPrimary)));
          }

          return Column(
            children: [
              // --- Premium Top Bar ---
              Container(
                color: bgColor,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Row(
                  children: [
                    // 1. Book Dropdown
                    Expanded(
                      flex: 5,
                      child: _buildCustomDropdown(
                        child: DropdownButton<BibleBook>(
                          isExpanded: true,
                          dropdownColor: surfaceColor,
                          icon: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: 20),
                          value: selectedBook,
                          items: allBooks.map((book) {
                            return DropdownMenuItem(
                              value: book,
                              child: Text(
                                getTeluguName(book.bname),
                                style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500),
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
                    const SizedBox(width: 10),

                    // 2. Chapter Dropdown
                    Expanded(
                      flex: 3,
                      child: _buildCustomDropdown(
                        child: DropdownButton<Chapter>(
                          isExpanded: true,
                          dropdownColor: surfaceColor,
                          icon: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: 20),
                          value: selectedChapter,
                          hint: Text('అధ్యా', style: TextStyle(fontSize: 13, color: textPrimary)),
                          items: selectedBook?.chapters.map((chapter) {
                            return DropdownMenuItem(
                              value: chapter,
                              child: Text('అధ్యా ${chapter.cnumber}', style: TextStyle(fontSize: 14, color: textPrimary)),
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
                    const SizedBox(width: 10),

                    // 3. Verse Dropdown
                    Expanded(
                      flex: 3,
                      child: _buildCustomDropdown(
                        child: DropdownButton<Verse>(
                          isExpanded: true,
                          dropdownColor: surfaceColor,
                          icon: Icon(Icons.keyboard_arrow_down, color: goldAccent, size: 20),
                          value: selectedVerse,
                          hint: Text('వచనం', style: TextStyle(fontSize: 13, color: textPrimary)),
                          items: selectedChapter?.verses.map((verse) {
                            return DropdownMenuItem(
                              value: verse,
                              child: Text('వచనం ${verse.vnumber}', style: TextStyle(fontSize: 14, color: textPrimary)),
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
                  ],
                ),
              ),

              // --- Reading Area ---
              Expanded(
                child: selectedChapter == null
                    ? Center(child: Text('ఈ పుస్తకంలో అధ్యాయాలు లేవు', style: TextStyle(color: textPrimary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: selectedChapter!.verses.length,
                        itemBuilder: (context, index) {
                          final verse = selectedChapter!.verses[index];
                          verseKeys[verse.vnumber] ??= GlobalKey();
                          
                          bool isHighlighted = selectedVerse?.vnumber == verse.vnumber;

                          return Container(
                            key: verseKeys[verse.vnumber],
                            margin: const EdgeInsets.only(bottom: 16.0),
                            // హైలైట్ అయినప్పుడు ఎడమ వైపున ప్రొఫెషనల్ గోల్డ్ లైన్
                            decoration: isHighlighted
                                ? BoxDecoration(
                                    color: goldAccent.withOpacity(0.05),
                                    border: Border(left: BorderSide(color: goldAccent, width: 3)),
                                  )
                                : const BoxDecoration(
                                    border: Border(left: BorderSide(color: Colors.transparent, width: 3)),
                                  ),
                            padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: textPrimary, 
                                  height: 1.7, // చదవడానికి వీలుగా మంచి స్పేసింగ్
                                ),
                                children: [
                                  TextSpan(
                                    text: '${verse.vnumber}  ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isHighlighted ? goldAccent : goldAccent.withOpacity(0.7),
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
