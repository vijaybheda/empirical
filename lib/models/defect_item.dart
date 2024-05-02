import 'package:flutter/cupertino.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';

class DefectItem {
  int? id;
  String? name;
  String? instruction;
  TextEditingController? injuryTextEditingController;
  TextEditingController? damageTextEditingController;
  TextEditingController? sDamageTextEditingController;
  TextEditingController? vsDamageTextEditingController;
  TextEditingController? decayTextEditingController;
  List<DefectInstructionAttachment>? attachments;

  DefectItem({
    this.id,
    this.name,
    this.instruction,
    this.attachments,
    this.injuryTextEditingController,
    this.damageTextEditingController,
    this.sDamageTextEditingController,
    this.vsDamageTextEditingController,
    this.decayTextEditingController,
  });

  // toJson
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instruction': instruction,
        "injuryTextEditingController": injuryTextEditingController,
        "damageTextEditingController": damageTextEditingController,
        "sDamageTextEditingController": sDamageTextEditingController,
        "vsDamageTextEditingController": vsDamageTextEditingController,
        "decayTextEditingController": decayTextEditingController,
        'attachments': attachments?.map((item) => item.toJson()).toList(),
      };

  // fromJson
  factory DefectItem.fromJson(Map<String, dynamic> json) {
    return DefectItem(
      id: json['id'],
      name: json['name'],
      instruction: json['instruction'],
      injuryTextEditingController: json['injuryTextEditingController'],
      damageTextEditingController: json['damageTextEditingController'],
      sDamageTextEditingController: json['sDamageTextEditingController'],
      vsDamageTextEditingController: json['vsDamageTextEditingController'],
      decayTextEditingController: json['decayTextEditingController'],
      attachments: json['attachments']
          .map<DefectInstructionAttachment>(
              (item) => DefectInstructionAttachment.fromJson(item))
          .toList(),
    );
  }

  // copyWith
  DefectItem copyWith({
    int? id,
    String? name,
    String? instruction,
    TextEditingController? injuryTextEditingController,
    TextEditingController? damageTextEditingController,
    TextEditingController? sDamageTextEditingController,
    TextEditingController? vsDamageTextEditingController,
    TextEditingController? decayTextEditingController,
    List<DefectInstructionAttachment>? attachments,
  }) {
    return DefectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      instruction: instruction ?? this.instruction,
      injuryTextEditingController:
          injuryTextEditingController ?? this.injuryTextEditingController,
      damageTextEditingController:
          damageTextEditingController ?? this.damageTextEditingController,
      sDamageTextEditingController:
          sDamageTextEditingController ?? this.sDamageTextEditingController,
      vsDamageTextEditingController:
          vsDamageTextEditingController ?? this.vsDamageTextEditingController,
      decayTextEditingController:
          decayTextEditingController ?? this.decayTextEditingController,
      attachments: attachments ?? this.attachments,
    );
  }
}
