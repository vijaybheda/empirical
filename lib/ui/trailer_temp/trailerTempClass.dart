import 'package:flutter/material.dart';
/*

class TrailerTempClass {
  TrailerTempObject? nose;
  TrailerTempObject? middle;
  TrailerTempObject? tail;

  TrailerTempClass({
    this.nose,
    this.middle,
    this.tail,
  });
}

class TrailerTempObject {
  TrailerPallet? pallet1;
  TrailerPallet? pallet2;
  TrailerPallet? pallet3;

  TrailerTempObject({
    this.pallet1,
    this.pallet2,
    this.pallet3,
  });
}

class TrailerPallet {
  String? top = "";
  String? middle = "";
  String? bottom = "";

  TrailerPallet({
    this.top,
    this.middle,
    this.bottom,
  });
}
*/

enum TrailerEnum { Nose, Middle, Tail }

class TrailerTemp {
  TrailerTemp? tailer;

  TrailerTemp({this.tailer});

  TrailerTemp.fromJson(Map<String, dynamic> json) {
    tailer = json['TrailerTemp'] != null
        ? new TrailerTemp.fromJson(json['TrailerTemp'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tailer != null) {
      data['TrailerTemp'] = this.tailer!.toJson();
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
    nose = json['nose'] != null
        ? new TrailerTempPallet.fromJson(json['nose'])
        : null;
    middle = json['middle'] != null
        ? new TrailerTempPallet.fromJson(json['middle'])
        : null;
    tail = json['tail'] != null
        ? new TrailerTempPallet.fromJson(json['tail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.nose != null) {
      data['nose'] = this.nose!.toJson();
    }
    if (this.middle != null) {
      data['middle'] = this.middle!.toJson();
    }
    if (this.tail != null) {
      data['tail'] = this.tail!.toJson();
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
    pallet1 =
        json['pallet1'] != null ? new Pallet.fromJson(json['pallet1']) : null;
    pallet2 =
        json['pallet2'] != null ? new Pallet.fromJson(json['pallet2']) : null;
    pallet3 =
        json['pallet3'] != null ? new Pallet.fromJson(json['pallet3']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pallet1 != null) {
      data['pallet1'] = this.pallet1!.toJson();
    }
    if (this.pallet2 != null) {
      data['pallet2'] = this.pallet2!.toJson();
    }
    if (this.pallet3 != null) {
      data['pallet3'] = this.pallet3!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['top'] = this.top;
    data['middle'] = this.middle;
    data['bottom'] = this.bottom;
    return data;
  }
}
