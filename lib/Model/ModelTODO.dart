import 'dart:core';

class ModelTODO{
  int? id =0;
  String?  title="";
  String?  description="";
  String?  status="";
  String?  timer="";
  bool isplay = true;


  ModelTODO({
    this.id,
    this.title,
    this.description,this.status,this.timer,isplay});


  factory ModelTODO.fromJson(Map<dynamic, dynamic> json) {
    return ModelTODO(

      id: json['id']!=null?json['id']:'',
      title: json['title']!=null?json['title'].toString():'',
      description:json['description']!=null? json['description'].toString():'',
      status: json['status']!=null?json['status'].toString():'',
      timer: json['timer']!=null?json['timer'].toString():'',
    );
  }

}