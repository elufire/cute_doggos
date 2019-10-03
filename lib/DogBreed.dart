import 'package:cute_doggos/height.dart';
import 'package:cute_doggos/weight.dart';

class DogBreed {

  String bred_for;
  String breed_group;
  Height height;
  int id;
  String life_span;
  String name;
  String temperament;
  Weight weight;
  String imageUrl;

//  DogBreed(this.height, this.weight, this.temperament, this.bred_for, this.breed_group,
//			this.id, this.life_span, this.name);


	DogBreed.fromJsonMap(Map<String, dynamic> map):
		bred_for = map["bred_for"],
		breed_group = map["breed_group"],
		height = Height.fromJsonMap(map["height"]),
		id = map["id"],
		life_span = map["life_span"],
		name = map["name"],
		temperament = map["temperament"],
		weight = Weight.fromJsonMap(map["weight"]),
		imageUrl = map["imageUrl"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['bred_for'] = bred_for;
		data['breed_group'] = breed_group;
		data['height'] = height == null ? null : height.toJson();
		data['id'] = id;
		data['life_span'] = life_span;
		data['name'] = name;
		data['temperament'] = temperament;
		data['weight'] = weight == null ? null : weight.toJson();
		data['imageUrl'] = imageUrl;
		return data;
	}
}
