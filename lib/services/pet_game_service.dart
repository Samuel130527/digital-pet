import '../models/pet_state.dart';

enum PetOutcome {
  none,
  won,
  lost,
}

class PetGameService {
  // --------------------------------
  // Feed
  // --------------------------------

  PetState feed(PetState state) {
    if (state.gameOver || state.hasWon) {
      return state;
    }

    final newHunger =
        (state.hunger - 10).clamp(0.0, 100.0);

    double newHappiness;

    if (newHunger < 30) {
      newHappiness =
          (state.happiness - 20).clamp(0.0, 100.0);
    } else {
      newHappiness =
          (state.happiness + 10).clamp(0.0, 100.0);
    }

    return state.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
    );
  }

  // --------------------------------
  // Play
  // --------------------------------

  PetState play(PetState state) {
    if (state.gameOver || state.hasWon) {
      return state;
    }

    if (state.energy < 10) {
      return state;
    }

    return state.copyWith(
      happiness: state.happiness + 10,
      hunger: state.hunger + 5,
      energy: state.energy - 10,
    );
  }

  // --------------------------------
  // Run
  // --------------------------------

  PetState run(PetState state) {
    if (state.gameOver || state.hasWon) {
      return state;
    }

    if (state.energy < 25) {
      return state;
    }

    return state.copyWith(
      happiness: state.happiness + 15,
      hunger: state.hunger + 10,
      energy: state.energy - 25,
    );
  }

  // --------------------------------
  // Sleep
  // --------------------------------

  PetState sleep(PetState state) {
    if (state.gameOver || state.hasWon) {
      return state;
    }

    return state.copyWith(
      happiness: state.happiness + 5,
      hunger: state.hunger - 5,
      energy: state.energy + 30,
    );
  }

  // --------------------------------
  // Hunger timer tick
  // --------------------------------

  PetState hungerTick(PetState state) {
    if (state.gameOver || state.hasWon) {
      return state;
    }

    final oldHunger = state.hunger;

    double newHunger =
        (state.hunger + 5).clamp(0.0, 100.0);

    double newHappiness = state.happiness;

    // If hunger was already 100 and another
    // hunger tick occurs, reduce happiness.
    if (oldHunger >= 100) {
      newHunger = 100;
      newHappiness =
          (state.happiness - 20).clamp(0.0, 100.0);
    }

    final newEnergy =
        (state.energy - 5).clamp(0.0, 100.0);

    return state.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      energy: newEnergy,
    );
  }

  // --------------------------------
  // Outcome
  // --------------------------------

  PetOutcome checkOutcome(PetState state) {
    // Loss condition:
    // hunger = 100 AND happiness <= 10
    if (state.hunger >= 100 && state.happiness <= 10) {
      return PetOutcome.lost;
    }

    return PetOutcome.none;
  }

  // --------------------------------
  // Apply loss
  // --------------------------------

  PetState applyLoss(PetState state) {
    return state.copyWith(
      gameOver: true,
    );
  }

  // --------------------------------
  // Apply win
  // --------------------------------

  PetState applyWin(PetState state) {
    return state.copyWith(
      hasWon: true,
    );
  }

  // --------------------------------
  // Reset
  // --------------------------------

  PetState reset() {
    return PetState.initial();
  }
}