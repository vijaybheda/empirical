import 'package:pverify/models/defect_instruction_attachment.dart';

class DefectItem {
  int? id;
  String? name;
  String? instruction;
  List<DefectInstructionAttachment>? attachments;

  DefectItem({this.id, this.name, this.instruction, this.attachments});

  // toJson
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instruction': instruction,
        'attachments': attachments?.map((item) => item.toJson()).toList(),
      };

  // fromJson
  factory DefectItem.fromJson(Map<String, dynamic> json) {
    return DefectItem(
      id: json['id'],
      name: json['name'],
      instruction: json['instruction'],
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
    List<DefectInstructionAttachment>? attachments,
  }) {
    return DefectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      instruction: instruction ?? this.instruction,
      attachments: attachments ?? this.attachments,
    );
  }
}
