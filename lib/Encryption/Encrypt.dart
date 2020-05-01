



class Encrypt{
  String _key = "aopmfsajfa12jn21k4ntbefs8c304";



  int _changer;
  String _replace_this = " ";
  String _replace_to = "lfkasfKLFNjksafPIFKNOJAF1234Avamv";


  Encrypt()
  {
    this._changer = 0;
  }


  // String String -> String
  // takes a text and a key and returns the encrypted version of the text based on the key

  String encrypt(String text)
  {
    String newText = replace(text,this._replace_this,this._replace_to);

    List<int> text_to_char = newText.codeUnits;
    List<int> new_set_char = new List<int>();
    List<int> key_set = _key.codeUnits;

    int index_of_key = 0;
    int size_of_key = _key.length;

    for(int i = 0;i<text_to_char.length;i++)
    {
      if(size_of_key==index_of_key)
      {
        index_of_key = 0;
      }
      new_set_char.add((text_to_char[i] + key_set[index_of_key]));
      index_of_key++;
    }
    return String.fromCharCodes(new_set_char);
  }


  // String String -> String
  // Decrypts the given text based on the given key

   String decrypt(String text)
  {
    List<int> text_to_char = text.codeUnits;
    List<int> new_set_char = new List<int>();
    List<int> key_set = _key.codeUnits;

    int index_of_key = 0;
    int size_of_key = _key.length;

    for(int i = 0;i<text_to_char.length;i++)
    {
      if(size_of_key==index_of_key)
      {
        index_of_key = 0;
      }
      new_set_char.add((text_to_char[i] - key_set[index_of_key]));
      index_of_key++;
    }
    return replace(String.fromCharCodes(new_set_char),this._replace_to,_replace_this);
  }


  // String String String -> String
  // takes a text and replace the "replace_this" to "replace_to"

  String replace(String text, String replace_this, String replace_to)
  {
    if(text.isEmpty)
    {
      return replace_to;
    }
    else if(text.length<replace_this.length)
    {
      return text;
    }
    else if(text.substring(0, replace_this.length).contains(replace_this))
    {
      return  replace_to + replace(text.substring(replace_this.length), replace_this, replace_to);
    }
    return String.fromCharCode(text.codeUnitAt(0)) + replace(text.substring(1), replace_this, replace_to);
  }



  // String String Integer -> String
  // adds a string to another based on the given number

   String addAt(String text, String add_this, int period)
  {
    String finalText = "";
    for(int i = 0;i<text.length;i++)
    {
      if( (period-1) % i == 0)
      {
        finalText+=add_this;
      }
      finalText+= String.fromCharCode(text.codeUnitAt(i));
    }
    return finalText;
  }

}
