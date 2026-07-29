# Space Race

[![Garbage Jam #6](https://img.shields.io/badge/Garbage%20Jam-%236-orange)](https://itch.io/jam/garbage-jam-6)
[![Zig](https://img.shields.io/badge/Zig-0.16.0-blue)](https://ziglang.org/)
[![Raylib](https://img.shields.io/badge/Raylib-6.0-green)](https://www.raylib.com/)

A prototype clone of the classic **Space Race** game, developed for [Garbage Jam #6](https://itch.io/jam/garbage-jam-6).

## About

This is a small game prototype where two players compete to cross the screen as many times as possible within a time limit, while avoiding stars that move across the screen. The game features simple mechanics, a scoring system, and a timer.

## Features

- **2-player local multiplayer** – Compete against a friend
- **Star obstacles** – Randomly generated stars that move horizontally
- **Scoring system** – Earn points by crossing the screen
- **Timer** – Limited gameplay time for intense matches
- **Ship selection** – Choose your spacecraft from available options
- **Infinite scrolling background** – Visual enhancement for immersive gameplay
- **Sound effects and music** – Audio feedback for game events

## Getting Started

### Prerequisites

- [Zig 0.16.0](https://ziglang.org/download/)
- [Raylib 6.0](https://www.raylib.com/) and its Zig bindings (`raylib_zig`)

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/sweetkaktus/space-race.git
   cd space-race
   ```

2. Ensure Zig 0.16.0 and Raylib dependencies are installed on your system.

### Building

To create an executable for your operating system:
```sh
zig build
```

The compiled binary will be available in the `zig-out/bin/` directory.

### Running

To build and run the game in one command:
```sh
zig build run
```

Alternatively, run the compiled binary directly:
```sh
./zig-out/bin/space_race
```

## Controls

| Player | Move Up | Move Down |
|--------|---------|-----------|
| Player 1 | W | S |
| Player 2 | ↑ | ↓ |

## Built With

- **[Zig 0.16.0](https://ziglang.org/)** – Programming language
- **[Raylib 6.0](https://www.raylib.com/)** – Graphics and game library
- **[raylib_zig](https://github.com/ryupold/raylib.zig)** – Zig bindings for Raylib

## Assets & Credits

All graphical, audio, and musical assets used in this project are created by talented artists from the itch.io community. For a complete list of contributors and their work, please refer to the [development notes](docs/notes_de_dev.md):

- **SFX**: [mattflat](https://mattflat.itch.io/)
- **Music**: [GooseNinja](https://gooseninja.itch.io)
- **Graphics**: [gvituri](https://gvituri.itch.io)

## License

This project is provided as-is for the Garbage Jam #6. See the [development notes](docs/notes_de_dev.md) for more details about the assets and their respective licenses.

## Garbage Jam #6

This game was created as an entry for [Garbage Jam #6](https://itch.io/jam/garbage-jam-6), a game jam focused on creating games with unique constraints and themes.

You can find the submission page [here](https://itch.io/jam/garbage-jam-6/rate/4825847).
