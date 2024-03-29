# maja

![a screenshot](https://raw.githubusercontent.com/Tanami/maja/master/opt/maja.png)
![another screenshot](https://raw.githubusercontent.com/Tanami/maja/master/opt/graph.png)

## How to run it

Get something like Node Version Manager because everything else sucks.

```
npm install
npm run serve
```

For the Perl database:
```
cpanm AnyEvent Coro::Twiggy Plack::Request Data::Dumper::Perltidy Graph Graph::D3
perl storage.pl
```

## What exactly is this?
It is my personal note-taking tool which I devised after years of messing around with other stuff like TreeSheets, yEd, TiddlyWiki, Nototo, GraphViz, etc. I came to the realisation that having plaintext files is essential, and that navigating between them had to be instantaneous. Coincidentally, if you pin your thoughts to keywords this tool will create an accurate mind-mapping via collocations. You can achieve the exact same functionality as this tool with the Acme editor, but that is not usable on a mobile phone or web browser.

## Keyboard Shortcuts
- <kbd>Ctrl+s</kbd>  Save All
- <kbd>Alt-Shift-g</kbd>  toggle graph view
- <kbd>Alt-Shift-d</kbd>  insert current date
- <kbd>Alt-Shift-r</kbd>  load random page
- <kbd>Ctrl+a</kbd>  jump to start of line
- <kbd>Ctrl+e</kbd>  jump to end of line
- <kbd>Tab</kbd>  insert 4 spaces :}


## The code looks buggy/unsafe! is it?
It was written to run on my laptop. If you want to run it in a public environment I suggest modifying it.

## Hasn't this been done before?
Definitely not, the closest things I have found still require you to manually specify which sections of text are links, and that is a total waste of time. That said, here is a list of things which people might find similar:
 - https://www.ummm.co
   - a new commercial service, has some cool features like public sharing, thought fragments, and mind-maps but requires manual linking of words
 - https://obsidian.md
   - Has a nice graph view, but still requires manual linking.
 - https://www.notion.so
 - https://www.nototo.app
 - https://roamresearch.com
   - probably the closest to my program, but costs money and requires manual linking of words (yuck!)
 - https://foambubble.github.io/foam/
   - free clone of Roam
 - https://infranodus.com/
   - also commercial and is not a true collocational map since it attempts to derive significance by node betweenness
 - https://connectedtext.com
   - requires manual linking `[[wiki-style]]`, commercial, has many formatting features
 - https://logseq.com/
   - TBD
 - https://foambubble.github.io/foam/
   - TBD
 - https://tana.inc/
   - TBD
 - https://standardnotes.com
   - TBD
 - https://anytype.io
   - TBD
 - https://capacities.io
   - TBD
