class PetState {
  final String petName;
  final double happiness;
  final double hunger;
  final double energy;
  final bool gameOver;
  final bool hasWon;

  const PetState({
    required this.petName,
    required this.happiness,
    required this.hunger,
    required this.energy,
    this.gameOver = false,
    this.hasWon = false,
  });

  factory PetState.initial() {
    return const PetState(
      petName: 'Pip',
      happiness: 50,
      hunger: 50,
      energy: 70,
    );
  }

  PetState copyWith({
    String? petName,
    double? happiness,
    double? hunger,
    double? energy,
    bool? gameOver,
    bool? hasWon,
  }) {
    return PetState(
      petName: petName ?? this.petName,
      happiness: _clamp(happiness ?? this.happiness),
      hunger: _clamp(hunger ?? this.hunger),
      energy: _clamp(energy ?? this.energy),
      gameOver: gameOver ?? this.gameOver,
      hasWon: hasWon ?? this.hasWon,
    );
  }

  static double _clamp(double value) {
    return value.clamp(0.0, 100.0);
  }
}