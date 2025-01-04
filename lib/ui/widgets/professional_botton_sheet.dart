import 'package:flutter/material.dart';
import 'package:sona/domain/models/models.dart';

void showProfessionalAuthoritiesSelector({
  required BuildContext context,
  required void Function(List<Authority>) onSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ..._professionalsData.map(
              (data) {
                return ListTile(
                  title: Text(data['name'] as String),
                  leading: Icon(data['icon'] as IconData),
                  onTap: () {
                    onSelected(data['select'] as List<Authority>);
                    Navigator.pop(context);
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

final _professionalsData = [
  {
    'name': 'Todos los profesionales',
    'icon': Icons.business,
    'select': [Authority.medicalProfessional, Authority.legalProfessional],
  },
  {
    'name': 'Profesional médico',
    'icon': Icons.medical_services,
    'select': [Authority.medicalProfessional],
  },
  {
    'name': 'Profesional legal',
    'icon': Icons.gavel,
    'select': [Authority.legalProfessional],
  },
];
