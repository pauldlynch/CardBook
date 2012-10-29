CardBook
========

CardBook - MacOS X card index program

#CardBook 0.3 README

This is 0.2 (for MacOS X 10.2) updated for Lion support and Xcode 4.5.

CardBook is a card index application for Mac OS X.  It is released under the FreeBSD license, which means without charge.  Several sample cardbook files are included, as well as the full source code for CardBook.

Documentation of both the application and source are included in cardbook format.

Typical applications for CardBook:

- addresses
- recipes
- CRC cards
- to do lists
- note keeping

Inevitably, there are some bugs in this release:

- pasteboard operations with other applications (copy and paste and drag and drop) don't always work;
- Make Card service should create a card in the top open cardbook;
- undo isn't fully implemented, and will be flakey at times.

Please let me know of any more.

Planned upgrades:

- more elaborate printing (suitable for labels, plus page numbering)
- better AppleScript suppport
- import of different file formats

New in 0.3:

Bug fixes and updates to support MacOS X Lion (10.8), removing old deprecations, etc.

New in 0.2:

- toolbar;
- basic AppleScript support;
- fixed bug that caused moving cards by dragging inside a single cardbook duplicates rather than moves the cards;
- fixed bug that caused memory release problem when dragging cards between apps;
- find panel upgraded.

[Paul Lynch](mailto:paul@plsys.co.uk)

