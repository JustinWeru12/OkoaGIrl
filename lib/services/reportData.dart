

class Report {
  final String victimName,
      phone,
      location,
      assailantName,
      relationship,
      crime,
      persuing;
  final geolocation;
  final bool solved;

  Report({
    this.victimName,
    this.phone,
    this.location,
    this.assailantName,
    this.relationship,
    this.crime,
    this.persuing,
    this.geolocation,
    this.solved
  });

  Map<String, dynamic> getDataMap() {
    return {
      "victimName": victimName,
      "phone": phone,
      "location": location,
      "assailantName": assailantName,
      "relationship": assailantName,
      "crime": crime,
      "persuing": persuing,
      "geolocation": geolocation,
      "solved": solved,
    };
  }
}
