# JustTones Version 1 Catalog Specification

Catalog schema version: 1. Stable identifiers use `org.justtones.tuning.*`; localized names are never identities.

The shipped tuning-system inventory is 12-TET, Pythagorean, five-limit just intonation, quarter-comma meantone, Werckmeister III, Kirnberger III, Vallotti, and Young II. Each is a documented model, not a universal tuning for a culture, instrument, or repertoire. The cents tables below are normative for catalog version 1 and use chromatic pitch-class order from C (0 cents) through B.

| Stable ID suffix | C through B cents |
| --- | --- |
| `twelve-tone-equal` | 0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100 |
| `pythagorean` | 0, 90.225, 203.910, 294.135, 407.820, 498.045, 611.730, 701.955, 792.180, 905.865, 996.090, 1109.775 |
| `five-limit-just` | 0, 111.731, 203.910, 315.641, 386.314, 498.045, 590.224, 701.955, 813.686, 884.359, 1017.596, 1088.269 |
| `quarter-comma-meantone` | 0, 76.049, 193.157, 310.265, 386.314, 503.422, 579.471, 696.578, 772.627, 889.735, 1006.843, 1082.892 |
| `werckmeister-iii` | 0, 92, 193, 294, 391.5, 498, 590, 696.5, 793, 889.5, 996, 1093.5 |
| `kirnberger-iii` | 0, 90.225, 193.157, 294.135, 386.314, 498.045, 590.224, 696.578, 792.180, 884.359, 996.090, 1088.269 |
| `vallotti` | 0, 94.135, 196.090, 298.045, 392.180, 501.955, 592.180, 698.045, 796.090, 894.135, 1000, 1090.225 |
| `young-ii` | 0, 90, 196, 294, 392, 498, 588, 698, 792, 894, 996, 1090 |

The first-launch profile is `Chromatic Reference`, using `org.justtones.tuning.twelve-tone-equal` and A4=440 supplied by the existing reference model. It is a selection only and never starts audio.

Built-in profile templates cover chromatic reference, guitar/12-string guitar, bass, bowed strings (violin and cello), mandolin, ukulele, banjo, lute, recorder, flute, transposing B♭ brass, and a configurable bagpipe reference. They are immutable catalog data; musicians duplicate them before editing. The bagpipe template is explicitly editable and does not claim a universal bagpipe tuning.

All profile templates use `org.justtones.tuning.twelve-tone-equal`, the `sine` timbre, and written named pitches. A4 uses the shared default reference of 440 Hz. The B♭ brass entry has a sounding offset of -2 semitones; all other entries have a zero offset.

| Stable ID suffix | Display name | Instrument / classification | Ordered written pitches |
| --- | --- | --- | --- |
| `chromatic-reference` | Chromatic Reference | General | C4, D4, E4, F4, G4, A4, B4, C5 |
| `guitar-standard` | Guitar Standard | Guitar | E2, A2, D3, G3, B3, E4 |
| `twelve-string-guitar-standard` | 12-string Guitar Standard | 12-string guitar | E2, E3, A2, A3, D3, D4, G3, G4, B3, B3, E4, E4 |
| `bass-standard` | Bass Standard | Bass | E1, A1, D2, G2 |
| `violin-standard` | Violin Standard | Bowed strings | G3, D4, A4, E5 |
| `cello-standard` | Cello Standard | Bowed strings | C2, G2, D3, A3 |
| `mandolin-standard` | Mandolin Standard | Mandolin family | G3, D4, A4, E5 |
| `ukulele-c6` | Ukulele C6 | Ukulele | G4, C4, E4, A4 |
| `banjo-open-g` | Banjo Open G | Banjo | G4, D3, G3, B3, D4 |
| `lute-renaissance-g` | Lute Renaissance G | Lute | G2, C3, F3, A3, D4, F4 |
| `recorder-c` | Recorder C | Recorder | C5, D5, E5, F5, G5, A5, B5, C6 |
| `flute-c` | Flute C | Flute | C5, D5, E5, F5, G5, A5, B5, C6 |
| `bb-brass` | B♭ Brass Reference | Transposing wind and brass | C4, D4, E4, F4, G4, A4, B4, C5 |
| `bagpipe-configurable` | Configurable Bagpipe Reference | Bagpipe; editable | A4 |

The manifest also enumerates the existing version-1 synthesized timbres: `sine`, `warmHarmonic`, `guitar`, `piano`, `bowedString`, `flute`, `clarinet`, and `brass`. Their normative harmonic-amplitude definitions, 240-frame attack, and −1 dBFS peak ceiling remain in `Packages/JustTonesCore/Sources/JustTonesCore/Timbre.swift`; the timbre synthesis work is not expanded by this catalog task.

## Source records and limits

- [Huygens–Fokker Scala scale archive](https://www.huygens-fokker.org/scala/downloads.html) and its [SCL format specification](https://www.huygens-fokker.org/scala/scl_format.html) provide machine-readable scale references and the import format used for cross-checking models.
- B. R. Jorgensen, *Tuning*, is the print reference retained for historical temperament nomenclature and variants.
- [*Early Music* 42(4) (2014)](https://academic.oup.com/em/article/42/4/579/2928473) discusses Young II and Vallotti rotations; they remain distinct catalog entries.
- [BYU physics publication 2791](https://physics.byu.edu/docs/publication/2791) describes quarter-comma meantone's fifth narrowing by one quarter of the syntonic comma.

Pythagorean is a 3-limit fifth-cycle model. Five-limit just intonation is one chromatic realization; its useful form may vary by key and repertoire. Meantone includes a wolf interval. Well-temperament names can have published variants. Consequently, culture-, repertoire-, or instrument-specific material must be added only with its own identifiable source, stated limitation, and review. The configurable bagpipe template intentionally makes no claim of a universal bagpipe tuning.
