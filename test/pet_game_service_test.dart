import 'package:flutter_test/flutter_test.dart';

import 'package:digital_pet/models/pet_state.dart';
import 'package:digital_pet/services/pet_game_service.dart';

void main() {
  final service = PetGameService();

  group('PetState clamping', () {
    test('values cannot exceed 100', () {
      final state = PetState.initial().copyWith(
        happiness: 150,
        hunger: 200,
        energy: 120,
      );

      expect(state.happiness, 100);
      expect(state.hunger, 100);
      expect(state.energy, 100);
    });

    test('values cannot go below 0', () {
      final state = PetState.initial().copyWith(
        happiness: -20,
        hunger: -10,
        energy: -50,
      );

      expect(state.happiness, 0);
      expect(state.hunger, 0);
      expect(state.energy, 0);
    });
  });

  group('Feed', () {
    test('feeding decreases hunger and increases happiness', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      final result = service.feed(state);

      expect(result.hunger, 40);
      expect(result.happiness, 60);
    });

    test('feeding never makes hunger negative', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 5,
        energy: 70,
      );

      final result = service.feed(state);

      expect(result.hunger, 0);
    });
  });

  group('Play', () {
    test('play increases happiness and hunger and decreases energy', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      final result = service.play(state);

      expect(result.happiness, 60);
      expect(result.hunger, 55);
      expect(result.energy, 60);
    });

    test('play does nothing when energy is below 10', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 5,
      );

      final result = service.play(state);

      expect(result.happiness, 50);
      expect(result.hunger, 50);
      expect(result.energy, 5);
    });
  });

  group('Run', () {
    test('running changes all relevant meters', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      final result = service.run(state);

      expect(result.happiness, 65);
      expect(result.hunger, 60);
      expect(result.energy, 45);
    });

    test('run does nothing when energy is below 25', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 20,
      );

      final result = service.run(state);

      expect(result.happiness, 50);
      expect(result.hunger, 50);
      expect(result.energy, 20);
    });
  });

  group('Sleep', () {
    test('sleep increases energy and happiness and decreases hunger', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 50,
      );

      final result = service.sleep(state);

      expect(result.happiness, 55);
      expect(result.hunger, 45);
      expect(result.energy, 80);
    });

    test('sleep cannot increase energy above 100', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 90,
      );

      final result = service.sleep(state);

      expect(result.energy, 100);
    });
  });

  group('Hunger timer', () {
    test('hunger increases by 5 and energy decreases by 5', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      final result = service.hungerTick(state);

      expect(result.hunger, 55);
      expect(result.energy, 65);
      expect(result.happiness, 50);
    });

    test('hunger is clamped at 100', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 95,
        energy: 70,
      );

      final result = service.hungerTick(state);

      expect(result.hunger, 100);
      expect(result.happiness, 50);
    });

    test('hunger overflow reduces happiness', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 50,
        hunger: 100,
        energy: 70,
      );

      final result = service.hungerTick(state);

      expect(result.hunger, 100);
      expect(result.happiness, 30);
      expect(result.energy, 65);
    });
  });

  group('Loss condition', () {
    test('loss occurs when hunger is 100 and happiness is 10', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 10,
        hunger: 100,
        energy: 50,
      );

      expect(
        service.checkOutcome(state),
        PetOutcome.lost,
      );
    });

    test('loss does not occur when happiness is above 10', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 11,
        hunger: 100,
        energy: 50,
      );

      expect(
        service.checkOutcome(state),
        PetOutcome.none,
      );
    });
  });

  group('Win state', () {
    test('applyWin changes the state to won', () {
      const state = PetState(
        petName: 'Pip',
        happiness: 90,
        hunger: 30,
        energy: 70,
      );

      final result = service.applyWin(state);

      expect(result.hasWon, true);
      expect(result.gameOver, false);
    });
  });

  group('Reset', () {
    test('reset returns the pet to initial values', () {
      final result = service.reset();

      expect(result.petName, 'Pip');
      expect(result.happiness, 50);
      expect(result.hunger, 50);
      expect(result.energy, 70);
      expect(result.gameOver, false);
      expect(result.hasWon, false);
    });
  });
}