class Agent {
  final int id;
  final String name;
  final String code;
  final String? address;
  final String? contact;
  final String? email;
  final List<AgentLocation> locations;

  Agent({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.contact,
    this.email,
    this.locations = const [],
  });

  factory Agent.fromJson(Map<String, dynamic> json) {

    return Agent(
      id: json['ID'] ?? 0,
      name: json['Name'] ?? json['Sup_Name'] ?? '',
      code: json['Sup_Acc_No'] ?? json['Sup_Code'] ?? '',
      address: json['Address'] ?? json['Address'],
      contact: json['Mobile'] ?? json['TP'],
      email: json['Email'] ?? json['Email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'contact': contact,
      'email': email,
    };
  }
}

class AgentLocation {
  final int id;
  final int agentId;
  final String location;
  final String? address;
  final String? contact;

  AgentLocation({
    required this.id,
    required this.agentId,
    required this.location,
    this.address,
    this.contact,
  });

  factory AgentLocation.fromJson(Map<String, dynamic> json) {
    return AgentLocation(
      id: json['id'] ?? 0,
      agentId: json['agent_id'] ?? 0,
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'location': location,
    };
  }
}