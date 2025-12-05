# Neo Vim
## Standard Key Maps

### Autocompletion in Command Mode
- using `Tab` key


## quit

- `ZZ`: qw
= `ZQ`: q! 

## select braces and quote

- `vib`: between (
- `viB`: between {
- `viq`: between " or '
- `vab`: outside (
- `cib` or `dib` also work


## visual block mode

### insert before every lines
- C-v: enter visual block mode
- move down
- I: insert
- type characters
- ESC: add before all lines

### append after every lines
- gv (direct after intert before every lines) : activate the last selected visual block 
- $: go to the end of every lines
- A: append
- typing
- ESC to accespt for all lines

### switch the case 

- ~
- g~w: switch case for a word

## indent

- gg=G: indent the whole file


## jump from ( to )

- %

## go to previous line

- Ctrl-o
- Ctrl-i

## dettach vim and come back

- c-z: dettach and goto terminal
- type `fg` in terminal to come back

## url and file

- `gx`: open url
- `gf`: open file

## mark
### in the same file
- ma: create mark `a`
- 'a: goto mark `a`

### cross files
-mA: create mark `A`
-'A: goto mark `A`

### delete mark
- :delmarks a or :delmarks A

## Join lines

- J: join next line with space between
- gJ: join next line without space

## Snacks

- file grep: foobar -- -g={*.cpp,*.hpp}
