
class Weight {

  String imperial;
  String metric;

	Weight.fromJsonMap(Map<String, dynamic> map): 
		imperial = map["imperial"],
		metric = map["metric"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['imperial'] = imperial;
		data['metric'] = metric;
		return data;
	}
}
