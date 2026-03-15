import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // షేర్ ఫీచర్ కోసం
import 'bible_data.dart';
import 'bible_home.dart';

class BibleSearchScreen extends StatefulWidget {
  final List<BibleBook> allBooks;
  final BibleBook? currentBook; // ప్రస్తుత పుస్తకం కోసం
  final String Function(String) getTeluguName;

  const BibleSearchScreen({
    super.key,
    required this.allBooks,
    this.currentBook,
    required this.getTeluguName,
  });

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  String searchQuery = "";
  List<Map<String, dynamic>> allSearchResults = [];
  List<Map<String, dynamic>> displayedResults = [];
  bool isSearching = false;
  
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // --- Search Scope Variables ---
  String searchScope = 'పూర్తి బైబిల్';
  BibleBook? specificBookToSearch;

  // --- Result Filter Variables ---
  String? filterResultBookName;
  String? filterResultChapterNumber;

  // --- Multi-Selection Variables ---
  Set<int> selectedResultIndices = {};

  final List<String> scopeOptions = [
    'పూర్తి బైబిల్',
    'పాత నిబంధన',
    'క్రొత్త నిబంధన',
    'ప్రస్తుత పుస్తకంలో',
    'ఒక నిర్దిష్ట పుస్తకంలో'
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ఏ ఏ పుస్తకాల్లో వెతకాలో డిసైడ్ చేసే ఫంక్షన్
  List<BibleBook> get _booksToSearch {
    switch (searchScope) {
      case 'పాత నిబంధన':
        return widget.allBooks.where((b) => int.parse(b.bnumber) <= 39).toList();
      case 'క్రొత్త నిబంధన':
        return widget.allBooks.where((b) => int.parse(b.bnumber) >= 40).toList();
      case 'ప్రస్తుత పుస్తకంలో':
        return widget.currentBook != null ? [widget.currentBook!] : widget.allBooks;
      case 'ఒక నిర్దిష్ట పుస్తకంలో':
        return specificBookToSearch != null ? [specificBookToSearch!] : widget.allBooks;
      case 'పూర్తి బైబిల్':
      default:
        return widget.allBooks;
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        searchQuery = "";
        allSearchResults.clear();
        displayedResults.clear();
        selectedResultIndices.clear();
        isSearching = false;
        filterResultBookName = null;
        filterResultChapterNumber = null;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    List<Map<String, dynamic>> tempResults = [];
    final String lowerQuery = query.toLowerCase().trim();
    final booksToSearch = _booksToSearch;

    for (var book in booksToSearch) {
      for (var chapter in book.chapters) {
        for (var verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(lowerQuery)) {
            tempResults.add({
              'book': book,
              'chapter': chapter,
              'verse': verse,
            });
          }
        }
      }
    }

    setState(() {
      searchQuery = lowerQuery;
      allSearchResults = tempResults;
      filterResultBookName = null;
      filterResultChapterNumber = null;
      selectedResultIndices.clear();
      _applyResultFilters();
      isSearching = false;
    });
  }

  // సెర్చ్ రిజల్ట్స్ వచ్చాక వాటిలో ఫిల్టర్ చేయడానికి
  void _applyResultFilters() {
    setState(() {
      displayedResults = allSearchResults.where((result) {
        bool matchBook = filterResultBookName == null || result['book'].bname == filterResultBookName;
        bool matchChapter = filterResultChapterNumber == null || result['chapter'].cnumber == filterResultChapterNumber;
        return matchBook && matchChapter;
      }).toList();
      selectedResultIndices.clear(); // ఫిల్టర్ మారితే సెలెక్షన్ క్లియర్ అవుతుంది
    });
  }

  List<TextSpan> _getHighlightedText(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: GoogleFonts.balooTammudu2(
            backgroundColor: const Color(0xFFE5A853).withOpacity(0.3),
            color: const Color(0xFFE5A853),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = indexOfMatch + query.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return spans;
  }

  // షేర్ ఫంక్షన్
  void _shareSelectedVerses() {
    if (selectedResultIndices.isEmpty) return;
    
    List<String> versesToShare = [];
    for (int index in selectedResultIndices) {
      final res = displayedResults[index];
      versesToShare.add("${widget.getTeluguName(res['book'].bname)} ${res['chapter'].cnumber}:${res['verse'].vnumber}\n${res['verse'].text}");
    }
    
    String shareText = "పరిశుద్ధ గ్రంథము నుండి:\n\n${versesToShare.join('\n\n')}\n\n- WOG App";
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    bool isMultiSelectMode = selectedResultIndices.isNotEmpty;

    // రిజల్ట్స్ ఫిల్టర్స్ కోసం డైనమిక్ లిస్ట్స్
    List<String> resultBooks = allSearchResults.map((e) => e['book'].bname as String).toSet().toList();
    List<String> resultChapters = filterResultBookName != null
        ? allSearchResults.where((e) => e['book'].bname == filterResultBookName).map((e) => e['chapter'].cnumber as String).toSet().toList()
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: isMultiSelectMode 
          ? Text("${selectedResultIndices.length} ఎంచుకోబడ్డాయి", style: GoogleFonts.balooTammudu2(color: Colors.white))
          : TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18),
              cursorColor: const Color(0xFFE5A853),
              decoration: InputDecoration(
                hintText: "బైబిల్ లో వెతకండి...",
                hintStyle: GoogleFonts.balooTammudu2(color: Colors.grey),
                border: InputBorder.none,
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
        actions: isMultiSelectMode
            ? [
                IconButton(icon: const Icon(Icons.share, color: Color(0xFFE5A853)), onPressed: _shareSelectedVerses),
                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => selectedResultIndices.clear())),
              ]
            : null,
      ),
      body: Column(
        children: [
          // 1. Search Scope Selection (వెతికే విధానం)
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("వెతికే స్థలం: ", style: GoogleFonts.balooTammudu2(color: Colors.grey, fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1E1E1E),
                          isExpanded: true,
                          value: searchScope,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFE5A853)),
                          items: scopeOptions.map((String scope) {
                            return DropdownMenuItem<String>(
                              value: scope,
                              child: Text(scope, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 15)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                searchScope = newValue;
                                if (searchScope != 'ఒక నిర్దిష్ట పుస్తకంలో') specificBookToSearch = null;
                              });
                              _performSearch(searchQuery); // స్కోప్ మారగానే మళ్ళీ వెతుకుతుంది
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // ఒక నిర్దిష్ట పుస్తకం సెలెక్ట్ చేస్తేనే ఈ కింద డ్రాప్ డౌన్ కనిపిస్తుంది
                if (searchScope == 'ఒక నిర్దిష్ట పుస్తకంలో')
                  Row(
                    children: [
                      Text("పుస్తకం: ", style: GoogleFonts.balooTammudu2(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BibleBook>(
                            dropdownColor: const Color(0xFF1E1E1E),
                            isExpanded: true,
                            hint: Text("పుస్తకం ఎంచుకోండి", style: GoogleFonts.balooTammudu2(color: Colors.grey)),
                            value: specificBookToSearch,
                            items: widget.allBooks.map((book) {
                              return DropdownMenuItem<BibleBook>(
                                value: book,
                                child: Text(widget.getTeluguName(book.bname), style: GoogleFonts.balooTammudu2(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (BibleBook? newBook) {
                              setState(() => specificBookToSearch = newBook);
                              if (newBook != null) _performSearch(searchQuery);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // 2. Results Filters (రిజల్ట్స్ వచ్చాక అందులో ఫిల్టర్ చేయడానికి)
          if (allSearchResults.isNotEmpty && !isSearching)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1E1E),
                        hint: Text("పుస్తకం ఫిల్టర్", style: GoogleFonts.balooTammudu2(color: Colors.grey, fontSize: 13)),
                        value: filterResultBookName,
                        items: [
                          DropdownMenuItem<String>(value: null, child: Text("అన్ని పుస్తకాలు", style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853)))),
                          ...resultBooks.map((bName) => DropdownMenuItem(value: bName, child: Text(widget.getTeluguName(bName), style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 14)))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            filterResultBookName = val;
                            filterResultChapterNumber = null; // బుక్ మారితే చాప్టర్ రీసెట్
                            _applyResultFilters();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1E1E),
                        hint: Text("అధ్యాయం", style: GoogleFonts.balooTammudu2(color: Colors.grey, fontSize: 13)),
                        value: filterResultChapterNumber,
                        items: filterResultBookName == null ? [] : [
                          DropdownMenuItem<String>(value: null, child: Text("అన్ని", style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853)))),
                          ...resultChapters.map((cNum) => DropdownMenuItem(value: cNum, child: Text("అధ్యా $cNum", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 14)))),
                        ],
                        onChanged: filterResultBookName == null ? null : (val) {
                          setState(() {
                            filterResultChapterNumber = val;
                            _applyResultFilters();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: Color(0xFF2A2A2A)),

          // 3. Results List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (searchQuery.isEmpty) return Center(child: Text("పదాలు లేదా వాక్యాలు వెతకండి", style: GoogleFonts.balooTammudu2(color: Colors.grey, fontSize: 18)));
    if (isSearching) return const Center(child: CircularProgressIndicator(color: Color(0xFFE5A853)));
    if (displayedResults.isEmpty) return Center(child: Text("ఈ ఫిల్టర్స్ తో ఫలితాలు లేవు", style: GoogleFonts.balooTammudu2(color: Colors.grey, fontSize: 18)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("${displayedResults.length} ఫలితాలు (లాంగ్ ప్రెస్ చేసి షేర్ చేయండి)", style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853), fontSize: 13)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayedResults.length,
            itemBuilder: (context, index) {
              final result = displayedResults[index];
              final BibleBook book = result['book'];
              final Chapter chapter = result['chapter'];
              final Verse verse = result['verse'];
              final bool isSelected = selectedResultIndices.contains(index);

              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (isSelected) selectedResultIndices.remove(index);
                    else selectedResultIndices.add(index);
                  });
                },
                onTap: () {
                  if (selectedResultIndices.isNotEmpty) {
                    setState(() {
                      if (isSelected) selectedResultIndices.remove(index);
                      else selectedResultIndices.add(index);
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BibleReadingScreen(
                          book: book, chapter: chapter, initialVerse: verse, teluguBookName: widget.getTeluguName(book.bname),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE5A853).withOpacity(0.2) : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFFE5A853) : const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${widget.getTeluguName(book.bname)} ${chapter.cnumber}:${verse.vnumber}", style: GoogleFonts.balooTammudu2(color: const Color(0xFFE5A853), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RichText(text: TextSpan(style: GoogleFonts.balooTammudu2(color: const Color(0xFFE0E0E0), fontSize: 18, height: 1.6), children: _getHighlightedText(verse.text, searchQuery))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
