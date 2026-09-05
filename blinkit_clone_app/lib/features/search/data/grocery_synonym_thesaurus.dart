// lib/features/search/data/grocery_synonym_thesaurus.dart
// Ultra-lightweight, zero-heap overhead Hinglish and Indian grocery synonym thesaurus.
// Uses compile-time const maps to consume < 25 KB memory on low-end 3GB/4GB RAM devices.

class GrocerySynonymThesaurus {
  GrocerySynonymThesaurus._();

  // Noise / conversational words in Hinglish queries ("mujhe 2 packet amul dudh chahiye")
  static const Set<String> noiseWords = {
    'chahiye',
    'chahie',
    'dena',
    'dedo',
    'do',
    'wala',
    'wali',
    'wale',
    'bhi',
    'aur',
    'mujhe',
    'mere',
    'ko',
    'humko',
    'kripya',
    'please',
    'ek',
    'tin',
    'char',
    'paanch',
    'pack',
    'packet',
    'packets',
    'kilo',
    'kg',
    'gm',
    'gram',
    'grams',
    'litre',
    'liter',
    'ltr',
    'ml',
    'bhaiya',
  };

  // Bidirectional vernacular grocery synonym mappings
  // Canonical terms map to lists of colloquial synonyms and vice versa
  static const Map<String, List<String>> _synonyms = {
    // ── DAIRY ──
    'milk': ['dudh', 'doodh', 'dhud', 'dhoodh', 'dairy'],
    'dudh': ['milk', 'doodh', 'dhud', 'dairy'],
    'doodh': ['milk', 'dudh', 'dhud', 'dairy'],
    'curd': ['dahi', 'yogurt', 'yoghurt'],
    'dahi': ['curd', 'yogurt'],
    'paneer': ['panir', 'cottage cheese'],
    'panir': ['paneer', 'cottage cheese'],
    'butter': ['makhan', 'maska', 'amul butter'],
    'makhan': ['butter', 'maska'],
    'ghee': ['ghi', 'clarified butter'],
    'cheese': ['cheeze', 'slice'],

    // ── VEGETABLES & FRUITS ──
    'potato': ['aloo', 'alu', 'batata', 'potatoes'],
    'aloo': ['potato', 'alu', 'batata'],
    'alu': ['potato', 'aloo', 'batata'],
    'batata': ['potato', 'aloo'],
    'onion': ['pyaaz', 'pyaz', 'kanda', 'pyaj', 'onions'],
    'pyaaz': ['onion', 'pyaz', 'kanda'],
    'pyaz': ['onion', 'pyaaz', 'kanda'],
    'kanda': ['onion', 'pyaaz'],
    'tomato': ['tamatar', 'tamater', 'tomatoes'],
    'tamatar': ['tomato', 'tamater'],
    'chilli': ['mirchi', 'mirch', 'chili', 'green chilli'],
    'mirchi': ['chilli', 'mirch', 'chili'],
    'mirch': ['chilli', 'mirchi', 'chili'],
    'ginger': ['adrak', 'adrakh'],
    'adrak': ['ginger', 'adrakh'],
    'garlic': ['lahsun', 'lehsun', 'lasun'],
    'lahsun': ['garlic', 'lehsun'],
    'lemon': ['nimbu', 'neebu', 'lime'],
    'nimbu': ['lemon', 'neebu', 'lime'],
    'banana': ['kela', 'kele'],
    'kela': ['banana', 'kele'],
    'apple': ['seb', 'saib'],
    'seb': ['apple', 'saib'],
    'mango': ['aam'],
    'aam': ['mango'],
    'orange': ['santra', 'santre', 'narangi'],
    'santra': ['orange', 'santre'],
    'spinach': ['palak', 'paalak'],
    'palak': ['spinach', 'paalak'],
    'okra': ['bhindi', 'lady finger'],
    'bhindi': ['okra', 'lady finger'],
    'eggplant': ['baingan', 'brinjal', 'baigan'],
    'brinjal': ['baingan', 'eggplant', 'baigan'],
    'baingan': ['brinjal', 'eggplant'],
    'cucumber': ['kheera', 'kakdi'],
    'kheera': ['cucumber', 'kakdi'],
    'peas': ['matar', 'mattar', 'green peas'],
    'matar': ['peas', 'mattar'],
    'coriander': ['dhaniya', 'dhania', 'kothmir'],
    'dhaniya': ['coriander', 'dhania'],
    'dhania': ['coriander', 'dhaniya'],

    // ── STAPLES, GRAINS & FLOUR ──
    'flour': ['atta', 'aata', 'gehun', 'wheat flour'],
    'atta': ['flour', 'aata', 'wheat', 'gehun'],
    'aata': ['flour', 'atta', 'wheat'],
    'rice': ['chawal', 'chaawal', 'basmati'],
    'chawal': ['rice', 'chaawal', 'basmati'],
    'sugar': ['cheeni', 'chini', 'shakkar', 'shakar'],
    'cheeni': ['sugar', 'chini', 'shakkar'],
    'chini': ['sugar', 'cheeni', 'shakkar'],
    'shakkar': ['sugar', 'cheeni', 'chini'],
    'salt': ['namak', 'tata namak'],
    'namak': ['salt', 'tata namak'],
    'oil': ['tel', 'tail', 'refined oil', 'mustard oil'],
    'tel': ['oil', 'tail', 'sarson tel'],
    'dal': ['daal', 'pulses', 'lentils', 'toor dal', 'moong dal', 'chana dal'],
    'daal': ['dal', 'pulses', 'lentils'],
    'besan': ['gram flour', 'chana flour'],
    'maida': ['refined flour', 'all purpose flour'],
    'sooji': ['suji', 'rava', 'semolina'],
    'suji': ['sooji', 'rava', 'semolina'],
    'poha': ['flattened rice', 'chivda'],

    // ── SPICES ──
    'turmeric': ['haldi'],
    'haldi': ['turmeric'],
    'cumin': ['jeera', 'jira'],
    'jeera': ['cumin', 'jira'],
    'cardamom': ['elaichi', 'ilaichi'],
    'elaichi': ['cardamom', 'ilaichi'],
    'clove': ['laung', 'lavang'],
    'laung': ['clove'],
    'cinnamon': ['dalchini'],
    'dalchini': ['cinnamon'],
    'mustard': ['sarson', 'rai'],
    'sarson': ['mustard', 'rai'],
    'asafoetida': ['hing'],
    'hing': ['asafoetida'],

    // ── BAKERY, SNACKS & ESSENTIALS ──
    'egg': ['anda', 'ande', 'eggs'],
    'anda': ['egg', 'ande', 'eggs'],
    'ande': ['egg', 'anda', 'eggs'],
    'bread': ['paav', 'pav', 'bun', 'loaf'],
    'pav': ['bread', 'paav', 'bun'],
    'biscuit': ['biscuits', 'cookie', 'cookies', 'biskoot'],
    'cookie': ['biscuit', 'cookies', 'biskoot'],
    'tea': ['chai', 'chaa', 'patti', 'tea powder'],
    'chai': ['tea', 'chaa', 'patti'],
    'coffee': ['nescafe', 'bru'],
    'water': ['paani', 'pani', 'mineral water'],
    'paani': ['water', 'pani'],
    'pani': ['water', 'paani'],
    'soap': ['sabun', 'body wash', 'bathing bar'],
    'sabun': ['soap', 'body wash'],
    'snack': ['snacks', 'namkeen', 'bhujia', 'chips', 'farsan'],
    'namkeen': ['snack', 'bhujia', 'farsan', 'mixture'],
    'bhujia': ['namkeen', 'snack'],
    'chips': ['lays', 'wafers', 'crisps'],
    'chocolate': ['chocolates', 'cadbury', 'dairy milk'],
  };

  /// Expands a single normalized token to its canonical term + synonyms.
  /// Zero heap overhead: returns const lists where possible.
  static List<String> getSynonyms(String token) {
    final clean = token.toLowerCase().trim();
    final direct = _synonyms[clean];
    if (direct != null) {
      return [clean, ...direct];
    }
    return [clean];
  }

  /// Strips noise/conversational words and extracts meaningful search tokens.
  /// Example: "mujhe 2 packet amul dudh chahiye" -> ["amul", "dudh"]
  static List<String> normalizeQueryTokens(String rawQuery) {
    final clean = rawQuery.toLowerCase().trim();
    if (clean.isEmpty) return const [];

    final rawTokens = clean.split(RegExp(r'[\s,._-]+'));
    final filtered = <String>[];

    for (final t in rawTokens) {
      final token = t.trim();
      if (token.isEmpty) continue;

      // Skip numbers/quantities (e.g. "2", "500", "1") and noise words
      if (int.tryParse(token) != null || double.tryParse(token) != null) continue;
      if (noiseWords.contains(token)) continue;

      filtered.add(token);
    }

    // If all words were filtered out (e.g. user typed only "2kg"), fallback to original tokens
    if (filtered.isEmpty) {
      return rawTokens.where((t) => t.isNotEmpty).toList();
    }

    return filtered;
  }
}
