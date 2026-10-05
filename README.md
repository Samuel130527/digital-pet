# Digital Pet

## Project Overview

Digital Pet is a Flutter mobile application where users take care of a virtual pet by managing its happiness, hunger, and energy.

The application demonstrates state management, timed state changes, user interactions, animations, accessibility, automated testing, and separation of game logic from UI rendering.

## Features

- Display pet happiness from 0–100
- Display pet hunger from 0–100
- Display pet energy from 0–100
- Editable pet name
- Feed the pet
- Play with the pet
- Run activity
- Sleep activity
- Automatic hunger increase every 30 seconds
- Mood changes based on happiness
- Mood-based pet color tint using `ColorFiltered`
- Animated pet scaling
- Animated pet messages
- Reduced-motion accessibility support
- Win condition
- Loss condition
- Reset functionality
- Automated unit and widget tests

## Game Rules

### Happiness

Happiness is maintained between 0 and 100.

- Happiness above 70: Happy
- Happiness from 30 to 70: Neutral
- Happiness below 30: Unhappy

### Hunger

Hunger is maintained between 0 and 100.

Every 30 seconds:

- Hunger increases by 5
- Energy decreases by 5
- If hunger is already 100 and another timer tick occurs, happiness decreases by 20

### Feed

Feeding the pet:

- Decreases hunger by 10
- Normally increases happiness by 10
- If the resulting hunger is below 30, happiness decreases by 20

### Play

Playing:

- Increases happiness by 10
- Increases hunger by 5
- Decreases energy by 10

Play requires at least 10 energy.

### Run

Running:

- Increases happiness by 15
- Increases hunger by 10
- Decreases energy by 25

Run requires at least 25 energy.

### Sleep

Sleeping:

- Increases happiness by 5
- Decreases hunger by 5
- Increases energy by 30

All meters are clamped between 0 and 100.

## Win Condition

The player wins when happiness remains above 80 continuously for 3 minutes.

If happiness falls to 80 or below, the win timer is cancelled.

## Loss Condition

The game ends when:

- Hunger reaches 100
- AND happiness is 10 or lower

After the game ends, game actions are disabled.

## Architecture

The application separates game rules from UI rendering.

```text
lib/
├── main.dart
├── models/
│   └── pet_state.dart
├── services/
│   └── pet_game_service.dart
└── screens/
    └── pet_screen.dart