//Mapa del código braile en bits para cada letra del abecederio y simbolos
const Map<String, List> brailleDictionary = {
  "mayuscula": ["01", "00", "01"],
  "a": ["10", "00", "00"],
  "b": ["10", "10", "00"],
  "c": ["11", "00", "00"],
  "d": ["11", "01", "00"],
  "e": ["10", "01", "00"],
  "f": ["11", "10", "00"],
  "g": ["11", "11", "00"],
  "h": ["10", "11", "00"],
  "i": ["01", "10", "00"],
  "j": ["01", "11", "00"],
  "k": ["10", "00", "10"],
  "l": ["10", "10", "10"],
  "m": ["11", "00", "10"],
  "n": ["11", "01", "10"],
  "ñ": ["11", "11", "01"],
  "o": ["10", "01", "10"],
  "p": ["11", "10", "10"],
  "q": ["11", "11", "10"],
  "r": ["10", "11", "10"],
  "s": ["01", "10", "10"],
  "t": ["01", "11", "10"],
  "u": ["10", "00", "11"],
  "v": ["10", "10", "11"],
  "w": ["01", "11", "01"],
  "x": ["11", "00", "11"],
  "y": ["11", "01", "11"],
  "z": ["10", "01", "11"],
  "á": ["10", "11", "11"],
  "é": ["01", "10", "11"],
  "í": ["01", "00", "10"],
  "ó": ["01", "00", "11"],
  "ú": ["01", "11", "11"],
  "ü": ["10", "11", "01"],
  "signoNumero": ["01", "01", "11"],
  ",": ["00", "00", "10"],
  ".": ["00", "10", "00"],
  ":": ["00", "11", "00"],
  ";": ["00", "10", "10"],
  "?": ["00", "10", "01"],
  "¿": ["00", "10", "01"],
  "!": ["00", "11", "10"],
  "comillas dobles": ["00", "10", "11"],
  "(": ["10", "10", "01"],
  ")": ["01", "01", "10"],
  " ": ["00", "00", "00"],
};

//Mapa de numeros a su equivalente en letras en código braille
const Map<String, String> numberDictionary = {
  "0": "a",
  "1": "b",
  "2": "c",
  "3": "d",
  "4": "e",
  "5": "f",
  "6": "g",
  "7": "h",
  "8": "i",
  "9": "j",
};

String convertedText = '';

String convertBraille(String text) {
  var temp = text.split("");
  var value, lastValue;
  var numberSign = brailleDictionary["signoNumero"];

  for (var char in temp) {
    if (isCharSymbol(char)) {
    } else if (isCharNumber(char) & (lastValue == brailleDictionary[" "])) {
      //print('signoNumero, $numberSign');
      convertedText += ('signoNumero' '\t' '$numberSign' '\n');
      char = turnCharToNum(char);
    } else if (isCharNumber(char)) {
      char = turnCharToNum(char);
    } else {
      char = isCharUpperCase(char);
    }
    //printBraille(value);
    value = brailleDictionary[char];
    //print('$char, $value');
    lastValue = value;
    convertedText += ('$char' '\t' '$value' '\n');
  }
  //print(convertedText);
  return convertedText;
}

bool isCharNumber(String char) {
  String chars = r'[0123456789]';
  bool isNum = chars.contains(char);
  return isNum;
}

String turnCharToNum(String char) {
  String? numToChar;
  numToChar = numberDictionary[char];
  char = numToChar!;
  return char;
}

bool isCharSymbol(String char) {
  String chars = r'[!#%&()*+-.,/:;<>=¿?¿@[]^_¨" {}%$]';
  return chars.contains(char);
}

String isCharUpperCase(String char) {
  var mayuscula = brailleDictionary["mayuscula"];
  bool isCharUpperCase = char == char.toUpperCase();
  if (!isCharUpperCase) {
  } else {
    //print('mayuscula, $mayuscula');
    convertedText += ('mayuscula' '\t' '$mayuscula' '\n');
    return char = char.toLowerCase();
  }
  return char;
}
