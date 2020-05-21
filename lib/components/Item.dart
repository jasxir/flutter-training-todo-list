class Item{

  String text;
  bool selected;

  Item({this.text, this.selected});

  Map toJson() => {
    'text': text,
    'selected': selected,
  };

  factory Item.fromJson(dynamic json) {
    return Item(text: json['text'] as String, selected: json['selected'] as bool);
  }

  @override
  String toString() {
    return '{ ${this.text}, ${this.selected} }';
  }
}