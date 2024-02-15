class ModelClass{

  String?  title="";
  String?  description="";
  String?  status="";
  String?  timer="";


  ModelClass({
    this.title,
    this.description,this.status,this.timer});

  @override
  String toString() {
    return 'ModelClass{title: $title, description: $description, status: $status, timer: $timer, }';
  }

  Map<String,dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'timer': timer,
    };
  }
  factory ModelClass.fromJson(Map<dynamic, dynamic> json) {
    return ModelClass(

      title: json['title']!=null?json['title'].toString():'',
      description:json['description']!=null? json['description'].toString():'',
      status: json['status']!=null?json['status'].toString():'',
      timer: json['timer']!=null?json['timer'].toString():'',
    );
  }

}