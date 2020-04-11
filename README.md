# maja

![a screenshot](https://raw.githubusercontent.com/Tanami/maja/master/opt/maja.png)

## How to run it

Get something like Node Version Manager because everything else sucks.

```
npm install
npm run serve
```

For the Perl database:
```
cpanm AnyEvent Coro::Twiggy Plack::Request Data::Dumper::Perltidy
perl storage.pl
```

## What exactly is this?
It is my personal note-taking tool which I devised after years of messing around with other stuff like TreeSheets, yEd, TiddlyWiki, Nototo, GraphViz, etc. I came to the realisation that having plaintext files is essential, and that navigating between them had to be instantaneous. Coincidentally, if you pin your thoughts to keywords this tool will create an accurate mind-mapping via collocations. You can achieve the exact same functionality as this tool with the Acme editor, but that is not usable on a mobile phone or web browser.

## The code looks buggy/unsafe! is it?
It was written to run on my laptop. If you want to run it in a public environment I suggest modifying it.

## Hasn't this been done before?
Definitely not, the closest things I have found still require you to manually specify which sections of text are links, and that is a total waste of time.
