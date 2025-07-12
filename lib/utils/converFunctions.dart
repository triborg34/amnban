var labelmap = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  'A',
  'B',
  'D',
  'Gh',
  'H',
  'J',
  'L',
  'M',
  'N',
  'P',
  'PuV',
  'PwD',
  'Sad',
  'Sin',
  'T',
  'Taxi',
  'V',
  'Y'
];

var carDict = {
  '0': '0',
  '1': '1',
  '2': '2',
  '3': '3',
  '4': '4',
  '5': '5',
  '6': '6',
  '7': '7',
  '8': '8',
  '9': '9',
  'A': '10',
  'B': '11',
  'P': '12',
  'x': '13',
  'ث': '14',
  'J': '15',
  'چ': '16',
  'ح': '17',
  'خ': '18',
  'D': '19',
  'ذ': '20',
  'ر': '21',
  'ز': '22',
  'ژ': '23',
  'Sin': '24',
  'ش': '25',
  'Sad': '26',
  'ض': '27',
  'T': '28',
  'ظ': '29',
  'PuV': '30',
  'غ': '31',
  'ف': '32',
  'Gh': '33',
  'ک': '34',
  'گ': '35',
  'L': '36',
  'M': '37',
  'N': '38',
  'H': '39',
  'V': '40',
  'Y': '41',
  'PwD': '42'
};

var alphabetP = {
  "ZERO": "۰",
  "ONE": "۱",
  "TWO": "۲",
  "THREE": "۳",
  "FOUR": "۴",
  "FIVE": "۵",
  "SIX": "۶",
  "SEVEN": "۷",
  "EIGHT": "۸",
  "NINE": "۹",
  "A": "آ",
  "B": "ب",
  "D": "د",
  "Gh": "ق",
  "H": "ه",
  "J": "ج",
  "L": "ل",
  "M": "م",
  "N": "ن",
  "P": "پ",
  "PuV": "ع",
  "PwD": "ژ",
  "Sad": "ص",
  "Sin": "س",
  "T": "ط",
  "x": "ت",
  "V": "و",
  "Y": "ی",
};

var alphabetP2 = {
  "0": "۰",
  "1": "۱",
  "2": "۲",
  "3": "۳",
  "4": "۴",
  "5": "۵",
  "6": "۶",
  "7": "۷",
  "8": "۸",
  "9": "۹",
  "A": "آ",
  "B": "ب",
  "D": "د",
  "Gh": "ق",
  "H": "ه",
  "J": "ج",
  "L": "ل",
  "M": "م",
  "N": "ن",
  "P": "پ",
  "PuV": "ع",
  "PwD": "ژ",
  "Sad": "ص",
  "Sin": "س",
  "T": "ط",
  "x": "ت",
  "V": "و",
  "Y": "ی",
};

var alphabetE = {
  "ZERO": "0",
  "ONE": "1",
  "TWO": "2",
  "THREE": "3",
  "FOUR": "4",
  "FIVE": "5",
  "SIX": "6",
  "SEVEN": "7",
  "EIGHT": "8",
  "NINE": "9",
  'ALEF': 'A',
  'BEH': 'B',
  'DAL': 'D',
  'QAF': 'Gh',
  'HEH': 'H',
  'JEEM': 'J',
  'LAM': 'L',
  'MEEM': 'M',
  'NOON': 'N',
  'PEH': 'P',
  'AIN': 'PuV',
  'JEH': 'PwD',
  'SAD': 'Sad',
  'SEEN': 'Sin',
  'TAH': 'T',
  'x': 'Taxi',
  'WAW': 'V',
  'YEH': 'Y',
};

var plateAlphabet = {
  "A": "آ",
  "B": "ب",
  "D": "د",
  "Gh": "ق",
  "H": "ه",
  "J": "ج",
  "L": "ل",
  "M": "م",
  "N": "ن",
  "P": "پ",
  "PuV": "ع",
  "PwD": "ژ",
  "Sad": "ص",
  "Sin": "س",
  "T": "ط",
  "x": "ت",
  "V": "و",
  "Y": "ی",
};

String convertString(String input) {
  String result = input;

  // Sort keys based on their length (longest keys first) to match multi-character sequences first
  var sortedKeys = alphabetP2.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  // Replace all occurrences of keys in the input string with their corresponding values
  for (var key in sortedKeys) {
    result = result.replaceAll(key, alphabetP2[key]!);
  }

  return '\u200F' + result + '\u200E';
}

List convertToPersian(String input, Map<String, String> dictionary) {
  String result = '';

  

  // Loop through each character or group of characters in the input
  for (int i = 0; i < input.length; i++) {
    // Check if multi-character tokens exist in the dictionary
    if (i + 2 < input.length &&
        dictionary.containsKey(input.substring(i, i + 3))) {
      result += dictionary[input.substring(i, i + 3)]!;
      i += 2; // Skip next two characters since we used three
    } else if (i + 1 < input.length &&
        dictionary.containsKey(input.substring(i, i + 2))) {
      result += dictionary[input.substring(i, i + 2)]!;
      i += 1; // Skip next character since we used two
    } else if (dictionary.containsKey(input[i])) {
      result += dictionary[input[i]]!;
    } else {
      // If the character is not in the dictionary, just append it as is
      result += input[i];
    }
  }

try{
  var persianres = [
    "${result[3]}${result[4]}${result[5]} ${result[2]} ${result[0]}${result[1]}",
    "${result[6]}${result[7]}"
  ];



  return persianres;
}catch(e){

  return ["-","-"];
}
  

  
}

String convertToPersianString(String input, Map<String, String> dictionary) {
  String result = '';

  // Loop through each character or group of characters in the input
  for (int i = 0; i < input.length; i++) {
    // Check if multi-character tokens exist in the dictionary
    if (i + 2 < input.length &&
        dictionary.containsKey(input.substring(i, i + 3))) {
      result += dictionary[input.substring(i, i + 3)]!;
      i += 2; // Skip next two characters since we used three
    } else if (i + 1 < input.length &&
        dictionary.containsKey(input.substring(i, i + 2))) {
      result += dictionary[input.substring(i, i + 2)]!;
      i += 1; // Skip next character since we used two
    } else if (dictionary.containsKey(input[i])) {
      result += dictionary[input[i]]!;
    } else {
      // If the character is not in the dictionary, just append it as is
      result += input[i];
    }
  }

try{
  var persianres =
      "${result[3]}${result[4]}${result[5]}/${result[6]}${result[7]} ${result[2]} ${result[0]}${result[1]}";

  return persianres;
}catch(e){

  return "-";
}
}