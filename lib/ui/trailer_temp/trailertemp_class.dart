enum TrailerEnum { Nose, Middle, Tail }

class TrailerTemp {
  TrailerTemp? tailer;

  TrailerTemp({this.tailer});

  TrailerTemp.fromJson(Map<String, dynamic> json) {
    tailer = json['TrailerTemp'] != null
        ? TrailerTemp.fromJson(json['TrailerTemp'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tailer != null) {
      data['TrailerTemp'] = tailer!.toJson();
    }
    return data;
  }
}

class TrailerTempClass {
  TrailerTempPallet? nose;
  TrailerTempPallet? middle;
  TrailerTempPallet? tail;

  TrailerTempClass({this.nose, this.middle, this.tail});

  TrailerTempClass.fromJson(Map<String, dynamic> json) {
    nose =
        json['nose'] != null ? TrailerTempPallet.fromJson(json['nose']) : null;
    middle = json['middle'] != null
        ? TrailerTempPallet.fromJson(json['middle'])
        : null;
    tail =
        json['tail'] != null ? TrailerTempPallet.fromJson(json['tail']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (nose != null) {
      data['nose'] = nose!.toJson();
    }
    if (middle != null) {
      data['middle'] = middle!.toJson();
    }
    if (tail != null) {
      data['tail'] = tail!.toJson();
    }
    return data;
  }
}

class TrailerTempPallet {
  Pallet? pallet1;
  Pallet? pallet2;
  Pallet? pallet3;

  TrailerTempPallet({this.pallet1, this.pallet2, this.pallet3});

  TrailerTempPallet.fromJson(Map<String, dynamic> json) {
    pallet1 = json['pallet1'] != null ? Pallet.fromJson(json['pallet1']) : null;
    pallet2 = json['pallet2'] != null ? Pallet.fromJson(json['pallet2']) : null;
    pallet3 = json['pallet3'] != null ? Pallet.fromJson(json['pallet3']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pallet1 != null) {
      data['pallet1'] = pallet1!.toJson();
    }
    if (pallet2 != null) {
      data['pallet2'] = pallet2!.toJson();
    }
    if (pallet3 != null) {
      data['pallet3'] = pallet3!.toJson();
    }
    return data;
  }
}

class Pallet {
  String? top = '';
  String? middle = '';
  String? bottom = '';

  Pallet({this.top, this.middle, this.bottom});

  Pallet.fromJson(Map<String, dynamic> json) {
    top = json['top'];
    middle = json['middle'];
    bottom = json['bottom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['top'] = top;
    data['middle'] = middle;
    data['bottom'] = bottom;
    return data;
  }
}
