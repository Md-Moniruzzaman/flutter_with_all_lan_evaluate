class Customer {
  final String id;
  final String name;
  final String territory;
  final String zone;
  final String marketThanaDistrict;
  final String branch;
  final String storeBelt;
  final String road;
  final String status;
  final String location;

  Customer({
    required this.id,
    required this.name,
    required this.territory,
    required this.zone,
    required this.marketThanaDistrict,
    required this.branch,
    required this.storeBelt,
    required this.road,
    required this.status,
    required this.location,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      territory: json['territory'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      marketThanaDistrict: json['market_thana_district'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      storeBelt: json['store_belt'] as String? ?? '',
      road: json['road'] as String? ?? '',
      status: json['status'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'territory': territory,
      'zone': zone,
      'market_thana_district': marketThanaDistrict,
      'branch': branch,
      'store_belt': storeBelt,
      'road': road,
      'status': status,
      'location': location,
    };
  }

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, territory: $territory, zone: $zone, marketThanaDistrict: $marketThanaDistrict, branch: $branch, storeBelt: $storeBelt, road: $road, status: $status, location: $location}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
