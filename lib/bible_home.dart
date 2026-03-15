import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
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
    'Genesis': 'ఆదికాండము', 'Exodus': 'నిర్గమకాండము', 'Leviticus': 'లేవీయకాండము', 'Numbers': 'సంఖ్యాకాండము', 
    'Deuteronomy': 'ద్వితీయోపదేశకాండము', 'Joshua': 'యెహోషువ', 'Judges': 'న్యాయాధిపతులు', 'Ruth': 'రూతు', 
    '1 Samuel': '1 సమూయేలు', '2 Samuel': '2 సమూయేలు', '1 Kings': '1 రాజులు', '2 Kings': '2 రాజులు',
    '1 Chronicles': '1 దినవృత్తాంతములు', '2 Chronicles': '2 దినవృత్తాంతములు', 'Ezra': 'ఎజ్రా',
    'Nehemiah': 'నెహెమ్యా', 'Esther': 'ఎస్తేరు', 'Job': 'యోబు', 'Psalms': 'కీర్తనల గ్రంథము', 
    'Proverbs': 'సామెతలు', 'Ecclesiastes': 'ప్రసంగి', 'Song of Solomon': 'పరమగీతములు', 'Song of Songs': 'పరమగీతములు', 
    'Isaiah': 'యెషయా', 'Jeremiah': 'యిర్మీయా', 'Lamentations': 'విలాపవాక్యములు', 'Ezekiel': 'యెహెజ్కేలు',
    'Daniel': 'దానియేలు', 'Hosea': 'హోషేయ', 'Joel': 'యోవేలు', 'Amos': 'ఆమోసు', 'Obadiah': 'ఓబద్యా', 
    'Jonah': 'యోనా', 'Micah': 'మీకా', 'Nahum': 'నహూము', 'Habakkuk': 'హబక్కూకు', 'Zephaniah': 'జెఫన్యా', 
    'Haggai': 'హగ్గయి', 'Zechariah': 'జెకర్యా', 'Malachi': 'మలాకీ', 'Matthew': 'మత్తయి సువార్త', 
    'Mark': 'మార్కు సువార్త', 'Luke': 'లూకా సువార్త', 'John': 'యోహాను సువార్త', 'Acts': 'అపొస్తలుల కార్యములు',
    'Romans': 'రోమీయులకు', '1 Corinthians': '1 కొరింథీయులకు', '2 Corinthians': '2 కొరింథీయులకు',
    'Galatians': 'గలతీయులకు', 'Ephesians': 'ఎఫెసీయులకు', 'Philippians': 'ఫిలిప్పీయులకు',
    'Colossians': 'కొలస్సీయులకు', '1 Thessalonians': '1 థెస్సలొనీకయులకు', '2 Thessalonians': '2 థెస్సలొనీకయులకు',
    '1 Timothy': '1 తిమోతికి', '2 Timothy': '2 తిమోతికి', 'Titus': 'తీతుకు', 'Philemon': 'ఫిలేమోనుకు', 
    'Hebrews': 'హెబ్రీయులకు', 'James': 'యాకోబు', '1 Peter': '1 పేతురు', '2 Peter': '2 పేతురు', 
    '1 John': '1 యోహాను', '2 John': '2 యోహాను', '3 John': '3 యోహాను', 'Jude': 'యూదా', 'Revelation': 'ప్రకటన గ్రంథము',
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
            style: GoogleFonts.balooTammudu2(color: goldText, fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
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
            book: selectedBook!,
            chapter: selectedChapter!,
            initialVerse: initialVerse,
            teluguBookName: getTeluguName(selectedBook!.bname),
          ),
        ),
      );
    }
  }

  void _openSearchScreen() {
    if (allBooks.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleSearchScreen(
            allBooks: allBooks,
            teluguBookNames: teluguBookNames,
            currentBook: selectedBook,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Header overlap fix: Removed Scaffold AppBar, using SafeArea + Custom Container
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (Will not merge with Parent Home Page Header)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  Text(
                    'W   O   G',
                    style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 24, letterSpacing: 2.0),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _openSearchScreen,
                      ),
                      const Icon(Icons.light_mode_outlined, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            
            FutureBuilder<List<BibleBook>>(
              future: futureBibleBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(child: Center(child: CircularProgressIndicator(color: goldText)));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Expanded(child: Center(child: Text('డేటా లోడ్ అవ్వలేదు.', style: GoogleFonts.balooTammudu2(color: Colors.white))));
                }

                return Expanded(
                  child: Column(
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
                            // Books Column
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
                                          style: GoogleFonts.balooTammudu2(
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
                            // Chapters Column
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
                                          style: GoogleFonts.balooTammudu2(
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
                            // Verses Column
                            Expanded(
                              flex: 2,
                              child: selectedChapter == null ? const SizedBox() : ListView.builder(
                                itemCount: selectedChapter!.verses.length,
                                itemBuilder: (context, index) {
                                  final verse = selectedChapter!.verses[index];
                                  final isSelected = selectedVerse?.vnumber == verse.vnumber;
                                  return InkWell(
                                    onTap: () {
                                      setState(() { selectedVerse = verse; });
                                      _openReadingScreen(verse);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: Text(
                                          verse.vnumber,
                                          style: GoogleFonts.balooTammudu2(
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class BibleReadingScreen extends StatefulWidget {
  final BibleBook book;
  final Chapter chapter;
  final Verse initialVerse;
  final String teluguBookName;

  const BibleReadingScreen({
    super.key, required this.book, required this.chapter, required this.initialVerse, required this.teluguBookName,
  });

  @override
  State<BibleReadingScreen> createState() => _BibleReadingScreenState();
}

class _BibleReadingScreenState extends State<BibleReadingScreen> {
  final Map<String, GlobalKey> verseKeys = {};
  Set<Verse> selectedVerses = {}; // బహుళ వచనాల ఎంపిక కోసం (Multiple Selection)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(widget.initialVerse.vnumber);
    });
  }

  void _scrollToVerse(String vnumber) {
    final key = verseKeys[vnumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut, alignment: 0.15);
    }
  }

  void _toggleSelection(Verse verse) {
    setState(() {
      if (selectedVerses.contains(verse)) {
        selectedVerses.remove(verse);
      } else {
        selectedVerses.add(verse);
      }
    });
  }

  void _shareSelected() {
    if (selectedVerses.isEmpty) return;
    List<Verse> sortedVerses = selectedVerses.toList()..sort((a, b) => int.parse(a.vnumber).compareTo(int.parse(b.vnumber)));
    String text = "${widget.teluguBookName} ${widget.chapter.cnumber}\n\n";
    text += sortedVerses.map((v) => "${v.vnumber}. ${v.text}").join("\n");
    text += "\n\n-- shared by WORLD OF GOD App";
    Share.share(text);
    setState(() { selectedVerses.clear(); });
  }

  void _bookmarkSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('బుక్‌మార్క్ సేవ్ చేయబడింది!', style: GoogleFonts.balooTammudu2(color: Colors.black)),
        backgroundColor: const Color(0xFFE5A853),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() { selectedVerses.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    bool isSelectionMode = selectedVerses.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: isSelectionMode ? const Color(0xFF1E1E1E) : Colors.black,
        leading: isSelectionMode 
            ? IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() { selectedVerses.clear(); }))
            : const BackButton(color: Colors.white),
        title: Text(
          isSelectionMode ? '${selectedVerses.length} ఎంచుకోబడ్డాయి' : '${widget.teluguBookName} ${widget.chapter.cnumber}', 
          style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853), fontSize: 22),
        ),
        actions: isSelectionMode ? [
          IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white), onPressed: _bookmarkSelected),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: _shareSelected),
        ] : [],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: widget.chapter.verses.length,
        itemBuilder: (context, index) {
          final verse = widget.chapter.verses[index];
          verseKeys[verse.vnumber] ??= GlobalKey();
          bool isSelected = selectedVerses.contains(verse);

          return GestureDetector(
            onLongPress: () => _toggleSelection(verse),
            onTap: () {
              if (isSelectionMode) _toggleSelection(verse);
            },
            child: Container(
              key: verseKeys[verse.vnumber],
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: isSelected
                  ? BoxDecoration(color: const Color(0xFFE5A853).withOpacity(0.2), border: const Border(left: BorderSide(color: Color(0xFFE5A853), width: 4)))
                  : const BoxDecoration(border: Border(left: BorderSide(color: Colors.transparent, width: 4))),
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.balooTammudu2(fontSize: 18, color: const Color(0xFFE0E0E0), height: 1.7),
                  children: [
                    TextSpan(
                      text: '${verse.vnumber}  ',
                      style: GoogleFonts.balooTammudu2(
                        fontSize: 15, fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFFE5A853) : const Color(0xFFE5A853).withOpacity(0.7),
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

// ------------------- SEARCH SCREEN -------------------
class SearchResultItem {
  final BibleBook book;
  final Chapter chapter;
  final Verse verse;
  SearchResultItem(this.book, this.chapter, this.verse);
}

class BibleSearchScreen extends StatefulWidget {
  final List<BibleBook> allBooks;
  final Map<String, String> teluguBookNames;
  final BibleBook? currentBook;

  const BibleSearchScreen({super.key, required this.allBooks, required this.teluguBookNames, this.currentBook});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  String searchQuery = "";
  String searchFilter = "పూర్తి బైబిల్"; 
  BibleBook? specificBookFilter;
  
  List<SearchResultItem> allResults = [];
  
  // Results Filtering Dropdowns
  BibleBook? resultFilterBook;
  Chapter? resultFilterChapter;

  final List<String> filterOptions = ['పూర్తి బైబిల్', 'పాత నిబంధన', 'క్రొత్త నిబంధన', 'ప్రస్తుత పుస్తకం', 'నిర్దిష్ట పుస్తకం'];

  void _performSearch() {
    allResults.clear();
    resultFilterBook = null;
    resultFilterChapter = null;
    if (searchQuery.trim().isEmpty) {
      setState(() {});
      return;
    }

    int startIndex = 0;
    int endIndex = widget.allBooks.length - 1;

    if (searchFilter == 'పాత నిబంధన') { endIndex = 38; } 
    else if (searchFilter == 'క్రొత్త నిబంధన') { startIndex = 39; } 
    else if (searchFilter == 'ప్రస్తుత పుస్తకం' && widget.currentBook != null) {
      startIndex = widget.allBooks.indexOf(widget.currentBook!);
      endIndex = startIndex;
    } else if (searchFilter == 'నిర్దిష్ట పుస్తకం' && specificBookFilter != null) {
      startIndex = widget.allBooks.indexOf(specificBookFilter!);
      endIndex = startIndex;
    }

    for (int i = startIndex; i <= endIndex; i++) {
      if (i < 0 || i >= widget.allBooks.length) continue;
      final book = widget.allBooks[i];
      for (var chapter in book.chapters) {
        for (var verse in chapter.verses) {
          if (verse.text.contains(searchQuery)) {
            allResults.add(SearchResultItem(book, chapter, verse));
          }
        }
      }
    }
    setState(() {});
  }

  List<SearchResultItem> get filteredResults {
    return allResults.where((res) {
      if (resultFilterBook != null && res.book != resultFilterBook) return false;
      if (resultFilterChapter != null && res.chapter != resultFilterChapter) return false;
      return true;
    }).toList();
  }

  List<BibleBook> get booksInResults {
    final books = <BibleBook>{};
    for (var r in allResults) { books.add(r.book); }
    return books.toList();
  }

  List<Chapter> get chaptersInResults {
    if (resultFilterBook == null) return [];
    final chapters = <Chapter>{};
    for (var r in allResults.where((x) => x.book == resultFilterBook)) { chapters.add(r.chapter); }
    return chapters.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('శోధన (Search)', style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853))),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Input & Main Filter
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  style: GoogleFonts.balooTammudu2(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'పదాలను వెతకండి...',
                    hintStyle: GoogleFonts.balooTammudu2(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    suffixIcon: IconButton(icon: const Icon(Icons.search, color: Color(0xFFE5A853)), onPressed: _performSearch),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => searchQuery = val,
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF1E1E1E),
                        value: searchFilter,
                        style: GoogleFonts.balooTammudu2(color: Colors.white),
                        decoration: const InputDecoration(filled: true, fillColor: Color(0xFF1E1E1E), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                        items: filterOptions.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (val) {
                          setState(() { searchFilter = val!; if (val != 'నిర్దిష్ట పుస్తకం') specificBookFilter = null; });
                        },
                      ),
                    ),
                    if (searchFilter == 'నిర్దిష్ట పుస్తకం') ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<BibleBook>(
                          dropdownColor: const Color(0xFF1E1E1E),
                          hint: Text('పుస్తకం', style: GoogleFonts.balooTammudu2(color: Colors.grey)),
                          style: GoogleFonts.balooTammudu2(color: Colors.white),
                          decoration: const InputDecoration(filled: true, fillColor: Color(0xFF1E1E1E), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                          value: specificBookFilter,
                          items: widget.allBooks.map((b) => DropdownMenuItem(value: b, child: Text(widget.teluguBookNames[b.bname] ?? b.bname, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) => setState(() => specificBookFilter = val),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          
          // Result Selection Filters (Book > Chapter > Verse options to filter results)
          if (allResults.isNotEmpty)
            Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<BibleBook>(
                      isExpanded: true, dropdownColor: Colors.black,
                      hint: Text('పుస్తకం ఎంచుకోండి', style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853))),
                      value: resultFilterBook,
                      items: [
                        DropdownMenuItem<BibleBook>(value: null, child: Text('అన్ని పుస్తకాలు', style: GoogleFonts.balooTammudu2(color: Colors.white))),
                        ...booksInResults.map((b) => DropdownMenuItem(value: b, child: Text(widget.teluguBookNames[b.bname] ?? b.bname, style: GoogleFonts.balooTammudu2(color: Colors.white))))
                      ],
                      onChanged: (val) => setState(() { resultFilterBook = val; resultFilterChapter = null; }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<Chapter>(
                      isExpanded: true, dropdownColor: Colors.black,
                      hint: Text('అధ్యాయం', style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853))),
                      value: resultFilterChapter,
                      items: [
                        DropdownMenuItem<Chapter>(value: null, child: Text('అన్ని', style: GoogleFonts.balooTammudu2(color: Colors.white))),
                        ...chaptersInResults.map((c) => DropdownMenuItem(value: c, child: Text('అధ్యా ${c.cnumber}', style: GoogleFonts.balooTammudu2(color: Colors.white))))
                      ],
                      onChanged: (val) => setState(() => resultFilterChapter = val),
                    ),
                  ),
                ],
              ),
            ),
          
          // Results List
          Expanded(
            child: filteredResults.isEmpty
                ? Center(child: Text(searchQuery.isEmpty ? 'వెతకడం ప్రారంభించండి' : 'ఫలితాలు లేవు', style: GoogleFonts.balooTammudu2(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final res = filteredResults[index];
                      final tName = widget.teluguBookNames[res.book.bname] ?? res.book.bname;
                      return ListTile(
                        title: Text('$tName ${res.chapter.cnumber}:${res.verse.vnumber}', style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853), fontWeight: FontWeight.bold)),
                        subtitle: Text(res.verse.text, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BibleReadingScreen(
                            book: res.book, chapter: res.chapter, initialVerse: res.verse, teluguBookName: tName,
                          )));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
