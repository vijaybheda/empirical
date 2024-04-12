import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/qc_details_short_form_screen_controller.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';

class SpecAnalyticalTable
    extends GetWidget<QCDetailsShortFormScreenController> {
  const SpecAnalyticalTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.listSpecAnalyticals.length,
      itemBuilder: (context, index) {
        SpecificationAnalytical item = controller.listSpecAnalyticals[index];
        SpecificationAnalyticalRequest reqobj =
            SpecificationAnalyticalRequest();

        reqobj.copyWith(
          analyticalID: item.analyticalID,
          analyticalName: item.description,
          specTypeofEntry: item.specTypeofEntry,
          isPictureRequired: item.isPictureRequired,
          specMin: item.specMin,
          specMax: item.specMax,
          description: item.description,
          inspectionResult: item.inspectionResult,
        );

        return ListTile(
          title: Text(item.description ?? ''),
          subtitle: Column(
            children: [
              TextField(
                onChanged: (value) {
                  // TODO: Implement your logic here
                },
              ),
              DropdownButton<String>(
                items:
                    <String>['Select', 'Yes', 'No', 'N/A'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  // TODO: Implement your logic here
                },
              ),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Comments'),
                        content: TextField(
                          onChanged: (value) {
                            // TODO: Implement your logic here
                          },
                        ),
                        actions: [
                          ElevatedButton(
                            child: Text('Save'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
