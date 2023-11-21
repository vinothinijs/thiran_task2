class Github {
  int? id;
  String? name;
  String? description;
  Owner? owner;
  int? stars;
  // String? username;
  // Uri? avatar;

  Github({this.id,this.name,this.description,this.stars,this.owner});
  // Github({this.id,this.name,this.description,this.stars,this.username,this.avatar});

  factory Github.fromJson(Map<String,dynamic> json) {
    return Github(
        id: json['id'],
        name:json['name'],
        description:json['description'],
        stars:json['stargazers_count'],
        owner: Owner.fromJson(json['owner'])
    );
  }
}

class Owner {
  String? username;
  String? avatar;

  Owner({this.username,this.avatar});

  factory Owner.fromJson(Map<String,dynamic> json) {
    return Owner(
      username:json['login'],
      avatar: json['avatar_url']
    );
  }
}