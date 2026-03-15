import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // షేర్ ఫీచర్ కోసం
import 'bible_data.dart';
import 'bible_search.dart';

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
        decoration: BoxDecoration(color: headerBoxColor, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(text, style: GoogleFonts.balooTammudu2(color: goldText, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  void _openReadingScreen(Verse initialVerse) {
    if (selectedBook != null && selectedChapter != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleReadingScreen(
            book: selectedBook!, chapter: selectedChapter!, initialVerse: initialVerse, teluguBookName: getTeluguName(selectedBook!.bname),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.black, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        title: Text('W   O   G', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 24, letterSpacing: 2.0)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white), 
            onPressed: () {
              if (allBooks.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BibleSearchScreen(
                      allBooks: allBooks, currentBook: selectedBook, getTeluguName: getTeluguName,
                    ),
                  ),
                );
              }
            }
          ),
          IconButton(icon: const Icon(Icons.light_mode_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      
      body: FutureBuilder<List<BibleBook>>(
        future: futureBibleBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: goldText));
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('డేటా లోడ్ అవ్వలేదు.', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16)));

          return Column(
            children: [
              Container(
                color: bgColor, padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildTopSelectionBox(getTeluguName(selectedBook?.bname ?? ""), flex: 4), const SizedBox(width: 12),
                    _buildTopSelectionBox(selectedChapter?.cnumber ?? "", flex: 2), const SizedBox(width: 12),
                    _buildTopSelectionBox(selectedVerse?.vnumber ?? "", flex: 2),
                  ],
                ),
              ),
              Divider(height: 1, color: dividerColor, thickness: 1),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ListView.builder(
                        itemCount: allBooks.length,
                        itemBuilder: (context, index) {
                          final book = allBooks[index];
                          final isSelected = selectedBook?.bname == book.bname;
                          return InkWell(
                            onTap: () => setState(() { selectedBook = book; selectedChapter = book.chapters.isNotEmpty ? book.chapters.first : null; selectedVerse = selectedChapter?.verses.isNotEmpty == true ? selectedChapter!.verses.first : null; }),
                            child: Container(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(getTeluguName(book.bname), style: GoogleFonts.balooTammudu2(fontSize: 16, color: isSelected ? goldText : greyText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)))),
                          );
                        },
                      ),
                    ),
                    Container(width: 1, color: dividerColor),
                    Expanded(
                      flex: 2,
                      child: selectedBook == null ? const SizedBox() : ListView.builder(
                        itemCount: selectedBook!.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = selectedBook!.chapters[index];
                          final isSelected = selectedChapter?.cnumber == chapter.cnumber;
                          return InkWell(
                            onTap: () => setState(() { selectedChapter = chapter; selectedVerse = chapter.verses.isNotEmpty ? chapter.verses.first : null; }),
                            child: Container(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(chapter.cnumber, style: GoogleFonts.balooTammudu2(fontSize: 16, color: isSelected ? goldText : greyText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)))),
                          );
                        },
                      ),
                    ),
                    Container(width: 1, color: dividerColor),
                    Expanded(
                      flex: 2,
                      child: selectedChapter == null ? const SizedBox() : ListView.builder(
                        itemCount: selectedChapter!.verses.length,
                        itemBuilder: (context, index) {
                          final verse = selectedChapter!.verses[index];
                          final isSelected = selectedVerse?.vnumber == verse.vnumber;
                          return InkWell(
                            onTap: () { setState(() => selectedVerse = verse); _openReadingScreen(verse); },
                            child: Container(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(verse.vnumber, style: GoogleFonts.balooTammudu2(fontSize: 16, color: isSelected ? goldText : greyText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)))),
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
        decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: dividerColor, width: 1))),
        child: BottomNavigationBar(
          backgroundColor: Colors.black, type: BottomNavigationBarType.fixed, currentIndex: 1,
          selectedItemColor: Colors.white, unselectedItemColor: greyText,
          selectedLabelStyle: GoogleFonts.balooTammudu2(fontSize: 10), unselectedLabelStyle: GoogleFonts.balooTammudu2(fontSize: 10),
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

// --- READING SCREEN WITH MULTI-SELECT & SHARE ---
class BibleReadingScreen extends StatefulWidget {
  final BibleBook book;
  final Chapter chapter;
  final Verse initialVerse;
  final String teluguBookName;

  const BibleReadingScreen({super.key, required this.book, required this.chapter, required this.initialVerse, required this.teluguBookName});

  @override
  State<BibleReadingScreen> createState() => _BibleReadingScreenState();
}

class _BibleReadingScreenState extends State<BibleReadingScreen> {
  final Map<String, GlobalKey> verseKeys = {};
  Set<String> selectedVerses = {}; // మల్టిపుల్ వచనాలు సెలెక్ట్ చేసుకోవడానికి

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToVerse(widget.initialVerse.vnumber));
  }

  void _scrollToVerse(String vnumber) {
    final key = verseKeys[vnumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut, alignment: 0.15);
    }
  }

  void _shareSelectedVerses() {
    if (selectedVerses.isEmpty) return;
    
    // వచనాలను ఆర్డర్ లో షేర్ చేయడానికి సార్టింగ్
    List<Verse> versesToShare = widget.chapter.verses.where((v) => selectedVerses.contains(v.vnumber)).toList();
    versesToShare.sort((a, b) => int.parse(a.vnumber).compareTo(int.parse(b.vnumber)));

    List<String> shareLines = versesToShare.map((v) => "${v.vnumber}. ${v.text}").toList();
    String shareText = "పరిశుద్ధ గ్రంథము నుండి:\n${widget.teluguBookName} ${widget.chapter.cnumber}\n\n${shareLines.join('\n')}\n\n- WOG App";
    
    Share.share(shareText);
    setState(() => selectedVerses.clear()); // షేర్ చేసాక సెలెక్షన్ క్యాన్సిల్ అవుతుంది
  }

  @override
  Widget build(BuildContext context) {
    bool isMultiSelectMode = selectedVerses.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          isMultiSelectMode ? '${selectedVerses.length} ఎంచుకోబడ్డాయి' : '${widget.teluguBookName} ${widget.chapter.cnumber}', 
          style: GoogleFonts.balooTammudu2(color: isMultiSelectMode ? Colors.white : const Color(0xFFE5A853), letterSpacing: 1.0, fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
        actions: isMultiSelectMode
            ? [
                IconButton(icon: const Icon(Icons.share, color: Color(0xFFE5A853)), onPressed: _shareSelectedVerses),
                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => selectedVerses.clear())),
              ]
            : null,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: widget.chapter.verses.length,
        itemBuilder: (context, index) {
          final verse = widget.chapter.verses[index];
          verseKeys[verse.vnumber] ??= GlobalKey();
          
          bool isHighlighted = verse.vnumber == widget.initialVerse.vnumber && !isMultiSelectMode;
          bool isSelected = selectedVerses.contains(verse.vnumber);

          return GestureDetector(
            onLongPress: () {
              setState(() {
                if (isSelected) selectedVerses.remove(verse.vnumber);
                else selectedVerses.add(verse.vnumber);
              });
            },
            onTap: () {
              if (isMultiSelectMode) {
                setState(() {
                  if (isSelected) selectedVerses.remove(verse.vnumber);
                  else selectedVerses.add(verse.vnumber);
                });
              }
            },
            child: Container(
              key: verseKeys[verse.vnumber],
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: isSelected || isHighlighted
                  ? BoxDecoration(
                      color: const Color(0xFFE5A853).withOpacity(0.15),
                      border: const Border(left: BorderSide(color: Color(0xFFE5A853), width: 4)),
                    )
                  : const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.transparent, width: 4)),
                    ),
              padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.balooTammudu2(fontSize: 18, color: const Color(0xFFE0E0E0), height: 1.7),
                  children: [
                    TextSpan(
                      text: '${verse.vnumber}  ',
                      style: GoogleFonts.balooTammudu2(
                        fontSize: 15, fontWeight: FontWeight.bold,
                        color: isSelected || isHighlighted ? const Color(0xFFE5A853) : const Color(0xFFE5A853).withOpacity(0.7),
                      ),
                    ),
                    TextSpan(text: verse.text),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
