
default: build

clean:
  -rm brickgame.love

build: clean
  fd -t f -E justfile -X zip -9 -r brickgame.love

run:
  love brickgame.love

watch: 
  fd -e lua | entr -rcs 'just build run'
