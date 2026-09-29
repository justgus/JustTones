# SP-038 Candidate Review

**Status:** Decisions recorded; Chinese model approved for implementation, Indian model excluded from the playable catalog  
**Prepared:** 2026-09-29  
**Governing work:** EP-014 / SP-038 / T-0048

This document records source claims, candidate-specific interpretation, and unresolved decisions. A candidate here is a proposal, not approved built-in data. Source evidence is distinguished from the proposed app model below.

## Candidate A — Chinese twelve lü

### Proposed exact model

**Display name proposal:** *Sanfen-sunyi twelve-lü (Huangzhong-rooted pitch-class reconstruction)*  
**Type:** A documented theoretical tuning-system model, not an absolute reference pitch and not a five-note scale or mode.  
**Context:** The Huangzhong-rooted twelve-pitch generation described through the *sanfen sunyi* (“subtracting and adding thirds”) procedure. The pitch-pipe origin story is legendary; this proposal is about the mathematical generation attributed to the historical theory, not a claim about one universal Chinese practice.

Harvard's Chinese music theory overview explains that the procedure alternates pipe lengths at 2/3 and 4/3 of the preceding pipe, producing a fifth upward and a fourth downward, and that the twelve-generation cycle does not close exactly at the octave. It distinguishes this from Jing Fang's later extended 60-generation cycle and Zhu Zaiyu's 16th-century twelve-tone equal temperament. The *Lüshi chunqiu* passage is identified as dating to 239 BCE. [Jonathan Service, “Chinese Music Theory,” Harvard University](https://soundingchina.fas.harvard.edu/Service.html); [Mori, “Sanfen sunyi-fa and Yin-yang philosophy,” J-STAGE](https://www.jstage.jst.go.jp/article/toyoongakukenkyu1936/1987/51/1987_51_4/_article).

The *Tongdian*'s “Five Tones and Twelve Pitch Standards Generating Each Other” preserves the generating account and the tradition of upward/downward generation. [*Tongdian*, Music 3, Chinese Text Project](https://ctext.org/text.pl?if=gb&node=560327). A Harvard-affiliated historical overview identifies the twelve-pitch framework and explains why octave closure was a recognized issue. [Service, “Chinese Music Theory”](https://soundingchina.fas.harvard.edu/Service.html).

### Ordered pitch data proposed for app playback

The source gives pipe-length generation, not this octave-sorted app table. The table is the proposal's reproducible derivation: use Huangzhong as 1/1; apply the documented alternating 3/2 and 3/4 frequency multipliers in the named generation order; reduce each generated result into one octave; sort by increasing frequency; then repeat at the octave. The cent values are calculated from each listed ratio as `1200 × log₂(ratio)` and rounded to 0.001 cent for display.

| Increasing pitch order | Proposed lü label | Ratio to Huangzhong | Cents |
| ---: | --- | ---: | ---: |
| 1 | Huangzhong 黄钟 | 1/1 | 0.000 |
| 2 | Daliu 大吕 | 2187/2048 | 113.685 |
| 3 | Taicou 太簇 | 9/8 | 203.910 |
| 4 | Jiazhong 夹钟 | 19683/16384 | 317.595 |
| 5 | Guxian 姑洗 | 81/64 | 407.820 |
| 6 | Zhonglü 仲吕 | 177147/131072 | 521.505 |
| 7 | Ruibin 蕤宾 | 729/512 | 611.730 |
| 8 | Linzhong 林钟 | 3/2 | 701.955 |
| 9 | Yize 夷则 | 6561/4096 | 815.640 |
| 10 | Nanlü 南吕 | 27/16 | 905.865 |
| 11 | Wuyi 无射 | 59049/32768 | 1019.550 |
| 12 | Yingzhong 应钟 | 243/128 | 1109.775 |

**Generation order before octave folding and sorting:** Huangzhong → Linzhong → Taicou → Nanlü → Guxian → Yingzhong → Ruibin → Daliu → Yize → Jiazhong → Wuyi → Zhonglü. The name spellings are transliterations for display; retain the Chinese forms as source-faithful labels.

### Playback and reference assumptions

- The profile's selected tonic/reference is Huangzhong. No absolute frequency for Huangzhong is specified by this model; the app must not imply that it is concert C, A=440, or any other universal Hz value.
- Each ratio is relative to the musician-selected Huangzhong reference. In JustTones' degree model, store the octave-sorted values as ratio degrees or their equivalent cents.
- The twelve generated pipes do not return to a pure octave. After 12 fifth-generations and octave normalization the residual is `531441/524288`, about 23.460 cents. An octave-repeating app model necessarily folds/normalizes pitches and resets the period at 1200 cents. This is an explicit playback adaptation, not a historical claim that the pipes close or repeat at an exact octave.
- The selected recurrence convention yields a mathematical reconstruction; historical text traditions disagree on generation details, especially the later steps and return/rotation procedures. Do not call this “the Chinese tuning” or silently equate it with equal temperament.

**Instrument association:** The direct reference instrument is the pitch pipe (*lüguan* 律管): historical theory describes the twelve standards as pipes. The *Sui shu* also records pitch pipes being used to regulate bells, chimes, and other instruments. This does not establish the approved octave-folded reconstruction as a universal performance tuning for guqin, pipa, or another instrument. The built-in profile is therefore a twelve-lü pitch-pipe reference profile, not a guqin or ensemble tuning preset.

### Decision requested

Approve or reject this exact *Huangzhong-rooted, sanfen-sunyi, octave-folded pitch-class reconstruction* as one named built-in tuning-system model. Approval would authorize implementation of only this table, metadata, source/limitation disclosure, and focused checks. It would not approve other twelve-lü variants, absolute Huangzhong frequencies, or other Chinese traditions.

## Candidate B — Bharata's two grāma interval allocations

### Source-specific model and exact data

**Display name proposal:** *Bharata's Ṣaḍja-grāma and Madhyama-grāma śruti allocation (theoretical model)*  
**Type:** A historical theoretical pitch-organization model; it is not itself a named modern tuning system, pitch-reference standard, rāga, or instrument profile.  
**Context:** The Ṣaḍja and Madhyama grāmas described in chapter 28 of the *Nāṭyaśāstra*, as translated by Manomohan Ghosh. The translation says each grāma comprises 22 śrutis, gives the allocation among the seven svaras, and describes lowering Pañcama by one śruti when moving to Madhyama-grāma. [Bharata, *Nāṭyaśāstra*, chapter 28, verses 24–28, Ghosh translation](https://www.wisdomlib.org/hinduism/book/the-natyashastra/d/doc210187.html#h1-1).

The source-supported ordered data are counts of śruti-units assigned between svara positions, not cents, ratios, or a measurement scale of 22 equal semitones:

| Grāma | Ordered svaras | Inter-svara allocations (śruti counts) | Cumulative positions from Sa |
| --- | --- | --- | --- |
| Ṣaḍja-grāma | Sa, Ri, Ga, Ma, Pa, Dha, Ni, Sa′ | 4, 3, 2, 4, 4, 3, 2 | 0, 4, 7, 9, 13, 17, 20, 22 |
| Madhyama-grāma | Sa, Ri, Ga, Ma, Pa, Dha, Ni, Sa′ | 4, 3, 2, 4, 3, 4, 2 | 0, 4, 7, 9, 13, 16, 20, 22 |

Sa is a relative tonic. The source's “one śruti” is a theoretical unit/count in the grāma construction. The source does not specify one frequency ratio or cent value per counted śruti, nor an absolute Sa frequency.

### App classification and playback finding

The primary text supports the two ordered interval-count layouts above. It does **not** by itself support converting those counts to seven deterministic profile frequencies. A modern musicological review of Hindustani intonation states that note pitches are not standardized in frequencies or ratios, that pitch is relative to the performer's tonic, and that intonation and melodic movement depend on context. It further warns against treating contemporary śruti as a universal set of fixed points. [Rao & Rao, “An Overview of Hindustani Music in the Context of Computational Musicology,” *Journal of New Music Research* 43:1 (2014), author manuscript](https://www.ee.iitb.ac.in/student/~daplab/publications/2014/sr-pr-JNMR-v11.pdf); [Jairazbhoy & Stone, “Intonation in Present-Day North Indian Classical Music,” *Bulletin of SOAS* 26:1 (1963)](https://doi.org/10.1017/S0041977X00074309).

Accordingly, the primary-source allocation is not sufficient to build a playable JustTones tuning system or reference profile. Mapping each śruti count to equal cents would add an unsupported equal-spacing assumption. Choosing a just-intonation ratio reconstruction would select one later interpretation not specified by this source. Neither choice is proposed as a silent implementation default.

### Decision requested

For this exact primary-source model, choose one disposition:

1. **Exclude it from the playable built-in catalog** and retain the source findings as documentation only; or
2. **Approve a separate non-playable educational record** of the two symbolic grāma allocations, if/when the catalog supports non-playable theoretical models; or
3. **Defer playable Indian content** until you specify or approve a particular named later treatise/reconstruction (including tradition/context) that supplies the ratios or cents to be used.

No option authorizes a generic “Indian śruti tuning” with invented, equal-spaced, or uncited playable values.

## Sources and scope limits

- Jonathan Service, “Chinese Music Theory,” Harvard University, discussion of the *Lüshi chunqiu*, sanfen-sunyi procedure, twelve-pitch generation, closure discrepancy, Jing Fang's later sixty-pitch cycle, and Zhu Zaiyu's later equal temperament: <https://soundingchina.fas.harvard.edu/Service.html>.
- Du You (杜佑), *Tongdian* 通典, “Music 3: Five Tones and Twelve Pitch Standards Generating Each Other,” primary historical compilation in Chinese Text Project translation: <https://ctext.org/text.pl?if=gb&node=560327>.
- Mori, “Sanfen sunyi-fa and Yin-yang philosophy,” *Tōyō Ongaku Kenkyū* / J-STAGE record, on the method's development and transformations: <https://www.jstage.jst.go.jp/article/toyoongakukenkyu1936/1987/51/1987_51_4/_article>.
- Bharata, *Nāṭyaśāstra*, chapter 28, verses 24–28, Manomohan Ghosh translation, source text and grāma counts: <https://www.wisdomlib.org/hinduism/book/the-natyashastra/d/doc210187.html>.
- Suvarnalata Rao and Preeti Rao, “An Overview of Hindustani Music in the Context of Computational Musicology,” *Journal of New Music Research* 43:1 (2014), author manuscript, on tonic-relative pitch, non-standardized frequencies/ratios, and context-sensitive intonation: <https://www.ee.iitb.ac.in/student/~daplab/publications/2014/sr-pr-JNMR-v11.pdf>.
- N. A. Jairazbhoy and A. W. Stone, “Intonation in Present-Day North Indian Classical Music,” *Bulletin of the School of Oriental and African Studies* 26:1 (1963), pp. 119–132, DOI: <https://doi.org/10.1017/S0041977X00074309>.

## Approval and implementation record

| Candidate | User decision | Catalog implementation |
| --- | --- | --- |
| A — Chinese Huangzhong-rooted sanfen-sunyi pitch-class reconstruction | Approved by the user on 2026-09-29 | Implemented in catalog version 2; see [Version-2-Catalog.md](Version-2-Catalog.md) |
| B — Bharata's two grāma allocation model | Excluded from the playable catalog by the user on 2026-09-29 | No runtime catalog entry; this review retains the source findings and symbolic counts only |
