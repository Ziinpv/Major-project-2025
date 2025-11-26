class FilterOption {
  final String id;
  final String label;

  const FilterOption({required this.id, required this.label});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

