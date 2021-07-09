class SummitParticipant {
  //participant main
  final String participantId;
  final String email;
  final String summitId;
  final String portalPassword;
  final String qrCode;
  final int isFullyFunded;
  final String createdDate;

//participant details
  final String photo;
  final String fullName;
  final String birthdate;
  final String nationality;
  final String address;
  final String gender;
  final String occupation;
  final String fieldOfStudy;
  final String institutionName;
  final String emergencyContact;
  final String contactRelation;
  final String waNumber;
  final String igAccount;
  final String tshirtSize;
  final String diseaseHistory;
  final int isVegetarian;
  final String essay;

  SummitParticipant({
    this.participantId,
    this.email,
    this.summitId,
    this.portalPassword,
    this.qrCode,
    this.isFullyFunded,
    this.createdDate,
    this.photo,
    this.fullName,
    this.birthdate,
    this.nationality,
    this.address,
    this.gender,
    this.occupation,
    this.fieldOfStudy,
    this.institutionName,
    this.emergencyContact,
    this.contactRelation,
    this.waNumber,
    this.igAccount,
    this.tshirtSize,
    this.diseaseHistory,
    this.isVegetarian,
    this.essay,
  });
}
