import 'dart:async';

import 'package:flutter/material.dart';

import '../models/pet_state.dart';
import '../services/pet_game_service.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final PetGameService _gameService = PetGameService();

  PetState _state = PetState.initial();

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    super.dispose();
  }

  // --------------------------------
  // Hunger Timer
  // --------------------------------

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_state.gameOver || _state.hasWon) {
          return;
        }

        setState(() {
          _state = _gameService.hungerTick(_state);
          _checkOutcome();
        });
      },
    );
  }

  // --------------------------------
  // Check Loss
  // --------------------------------

  void _checkOutcome() {
    final outcome = _gameService.checkOutcome(_state);

    if (outcome == PetOutcome.lost) {
      _highMoodTimer?.cancel();
      _hungerTimer?.cancel();

      _state = _gameService.applyLoss(_state);
      return;
    }

    _updateWinTimer();
  }

  // --------------------------------
  // Win Timer
  // --------------------------------

  void _updateWinTimer() {
    if (_state.happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    if (_state.happiness > 80 &&
        _highMoodTimer == null) {
      _highMoodTimer = Timer(
        const Duration(minutes: 3),
        () {
          if (!mounted) {
            return;
          }

          if (_state.happiness > 80 &&
              !_state.gameOver) {
            setState(() {
              _state = _gameService.applyWin(_state);
              _hungerTimer?.cancel();
            });
          }

          _highMoodTimer = null;
        },
      );
    }
  }

  // --------------------------------
  // Feed
  // --------------------------------

  void _feedPet() {
    if (_state.gameOver || _state.hasWon) {
      return;
    }

    setState(() {
      _state = _gameService.feed(_state);
      _checkOutcome();
    });
  }

  // --------------------------------
  // Play
  // --------------------------------

  void _playPet() {
    if (_state.gameOver || _state.hasWon) {
      return;
    }

    if (_state.energy < 10) {
      _showMessage('Not enough energy to play!');
      return;
    }

    setState(() {
      _state = _gameService.play(_state);
      _checkOutcome();
    });
  }

  // --------------------------------
  // Run
  // --------------------------------

  void _runPet() {
    if (_state.gameOver || _state.hasWon) {
      return;
    }

    if (_state.energy < 25) {
      _showMessage('Not enough energy to run!');
      return;
    }

    setState(() {
      _state = _gameService.run(_state);
      _checkOutcome();
    });
  }

  // --------------------------------
  // Sleep
  // --------------------------------

  void _sleepPet() {
    if (_state.gameOver || _state.hasWon) {
      return;
    }

    setState(() {
      _state = _gameService.sleep(_state);
      _checkOutcome();
    });
  }

  // --------------------------------
  // Change Name
  // --------------------------------

  Future<void> _changePetName() async {
    final controller =
        TextEditingController(text: _state.petName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Name Your Pet'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: 'Pet name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _state = _state.copyWith(
          petName: newName,
        );
      });
    }
  }

  // --------------------------------
  // Reset
  // --------------------------------

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _state = _gameService.reset();
    });

    _startHungerTimer();
  }

  // --------------------------------
  // SnackBar
  // --------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // --------------------------------
  // Mood
  // --------------------------------

  String get _mood {
    if (_state.gameOver) {
      return 'Game Over';
    }

    if (_state.hasWon) {
      return 'You Win!';
    }

    if (_state.happiness > 70) {
      return 'Happy';
    }

    if (_state.happiness >= 30) {
      return 'Neutral';
    }

    return 'Unhappy';
  }

  Color get _moodColor {
    if (_state.happiness > 70) {
      return Colors.green;
    }

    if (_state.happiness >= 30) {
      return Colors.amber.shade700;
    }

    return Colors.red;
  }

  Color get _petTintColor {
    if (_state.happiness > 70) {
      return Colors.green;
    }

    if (_state.happiness >= 30) {
      return Colors.amber.shade700;
    }

    return Colors.red;
  }

  double get _petScale {
    if (_state.happiness > 70) {
      return 1.06;
    }

    if (_state.happiness < 30) {
      return 0.94;
    }

    return 1.0;
  }

  String get _petMessage {
    if (_state.gameOver) {
      return '${_state.petName} needs more care!';
    }

    if (_state.hasWon) {
      return 'Amazing! ${_state.petName} stayed happy for 3 minutes!';
    }

    if (_state.hunger > 80) {
      return 'I am really hungry!';
    }

    if (_state.energy < 20) {
      return 'I am sleepy...';
    }

    if (_state.happiness <= 30) {
      return 'Please play with me!';
    }

    return "Hi, I'm ${_state.petName}!";
  }

  // --------------------------------
  // Build
  // --------------------------------

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Text('Digital Pet'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _changePetName,
            tooltip: 'Change pet name',
            icon: const Icon(Icons.edit),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // --------------------------------
              // PET
              // --------------------------------

              Center(
                child: AnimatedScale(
                  scale: _petScale,
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(
                          milliseconds: 400,
                        ),
                  curve: Curves.easeInOut,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _petTintColor,
                      BlendMode.srcIn,
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 130,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  _state.petName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: Text(
                  _mood,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: _moodColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(
                        milliseconds: 300,
                      ),
                child: Center(
                  key: ValueKey(_petMessage),
                  child: Text(
                    _petMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --------------------------------
              // METERS
              // --------------------------------

              _buildMeter(
                label: 'Happiness',
                value: _state.happiness,
                icon: Icons.favorite,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 20),

              _buildMeter(
                label: 'Hunger',
                value: _state.hunger,
                icon: Icons.restaurant,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 20),

              _buildMeter(
                label: 'Energy',
                value: _state.energy,
                icon: Icons.bolt,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 30),

              // --------------------------------
              // FEED / PLAY
              // --------------------------------

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          (_state.gameOver ||
                                  _state.hasWon)
                              ? null
                              : _feedPet,
                      icon: const Icon(
                        Icons.restaurant,
                      ),
                      label: const Text('Feed'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          (_state.gameOver ||
                                  _state.hasWon)
                              ? null
                              : _playPet,
                      icon: const Icon(
                        Icons.sports_esports,
                      ),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // --------------------------------
              // ACTIVITIES
              // --------------------------------

              Text(
                'Activities',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          (_state.gameOver ||
                                  _state.hasWon)
                              ? null
                              : _runPet,
                      icon: const Icon(
                        Icons.directions_run,
                      ),
                      label: const Text('Run'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          (_state.gameOver ||
                                  _state.hasWon)
                              ? null
                              : _sleepPet,
                      icon: const Icon(
                        Icons.nightlight,
                      ),
                      label: const Text('Sleep'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --------------------------------
              // RESET
              // --------------------------------

              Center(
                child: OutlinedButton.icon(
                  onPressed: _resetPet,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------
              // WIN
              // --------------------------------

              if (_state.hasWon)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 42,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You Win!',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Happiness stayed above 80 for 3 minutes.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // --------------------------------
              // GAME OVER
              // --------------------------------

              if (_state.gameOver)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          size: 42,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Game Over',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your pet needs more care. Try again!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------
  // Meter
  // --------------------------------

  Widget _buildMeter({
    required String label,
    required double value,
    required IconData icon,
    required bool reduceMotion,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${value.round()} / 100',
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: value / 100,
          ),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(
                  milliseconds: 400,
                ),
          curve: Curves.easeOut,
          builder: (
            context,
            animatedValue,
            child,
          ) {
            return LinearProgressIndicator(
              value: animatedValue,
              minHeight: 12,
              borderRadius:
                  BorderRadius.circular(10),
            );
          },
        ),
      ],
    );
  }
}