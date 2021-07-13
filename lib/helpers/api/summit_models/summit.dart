class Summit {
  String summitId;
  String desc;
  String registFee;
  String programFee;
  int status;

  Summit({
    this.summitId,
    this.desc,
    this.registFee,
    this.programFee,
    this.status,
  });

  factory Summit.fromJSON(Map<String, dynamic> data) {
    return Summit(
      summitId: data['id_summit'],
      desc: data['description'],
      registFee: data['regist_fee'],
      programFee: data['program_fee'],
      status: int.parse(data['status']),
    );
  }
}
