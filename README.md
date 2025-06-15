# Brickgames

Implementation of various games from classic 999-in-1 brick games using [Love2D][1].

- [x] wavebreaker
- [ ] snake
- [ ] tetris
- [ ] traffic dogger

## Running

Make sure you have `love` installed. Then run `just build` to build the project
and `just run` to start the game. The `build` command creates a zip file of the
repo with a `.love` extension and the `run` command invokes `love` with the
zip file.

## WaveBreaker

![WaveBreaker](images/wavebreaker.png)

- Advancing wave is filled in with bullets until a full line is filled and removed.
- The wave advances periodically
- Game ends when wave reaches bottom



[1]: https://www.love2d.org/
