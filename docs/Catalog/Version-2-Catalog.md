# JustTones Version 2 Catalog Specification

Catalog schema version: 2. Stable identifiers use `org.justtones.tuning.*`; localized names are never identities. Version 2 retains all version 1 tuning systems, profile templates, and timbres, and adds the one reviewed model below. The version 1 inventory remains recorded in [Version-1-Catalog.md](Version-1-Catalog.md).

## Added tuning system

**Stable identifier:** `org.justtones.tuning.chinese-sanfen-sunyi-huangzhong`  
**Display name:** Sanfen-sunyi twelve-lü (Huangzhong-rooted)  
**Classification:** Documented theoretical tuning-system model. This is one specified reconstruction; it is not a scale/mode, an absolute pitch reference, or a claim about all Chinese music or every historical twelve-lü account.  
**Context:** Chinese twelve lü (shierlü 十二律), historical China; Huangzhong 黄钟 is degree zero.

The *Lüshi chunqiu* / *Tongdian* source tradition describes the *sanfen sunyi* generation using successive pipe lengths two-thirds or four-thirds of the preceding length. Since frequency varies inversely with pipe length, the corresponding frequency multipliers are 3/2 and 3/4. Starting at Huangzhong, the generated order is Huangzhong, Linzhong, Taicou, Nanlü, Guxian, Yingzhong, Ruibin, Daliu, Yize, Jiazhong, Wuyi, Zhonglü. Each pitch is octave-folded, then sorted in ascending pitch order for this catalog.

| Degree ID / display label | Frequency ratio to Huangzhong | Derived cents |
| --- | ---: | ---: |
| `huangzhong-黄钟` | 1/1 | 0.000 |
| `daliu-大吕` | 2187/2048 | 113.685 |
| `taicou-太簇` | 9/8 | 203.910 |
| `jiazhong-夹钟` | 19683/16384 | 317.595 |
| `guxian-姑洗` | 81/64 | 407.820 |
| `zhonglü-仲吕` | 177147/131072 | 521.505 |
| `ruibin-蕤宾` | 729/512 | 611.730 |
| `linzhong-林钟` | 3/2 | 701.955 |
| `yize-夷则` | 6561/4096 | 815.640 |
| `nanlü-南吕` | 27/16 | 905.865 |
| `wuyi-无射` | 59049/32768 | 1019.550 |
| `yingzhong-应钟` | 243/128 | 1109.775 |

Ratios are stored as tuning-degree ratios; cents are derived as `1200 × log₂(ratio)` and rounded to three decimals only in this document. Generation uses the source procedure through twelve applications. The return ratio is `531441/524288` relative to seven octaves, a 23.460-cent mismatch. The catalog adapts the result into a one-octave, octave-repeating model: after octave reduction, degrees repeat at the next octave by app convention. No temperament adjustment closes the source generation cycle.

**Reference behavior:** Degree zero (Huangzhong) resolves to the profile's configured reference frequency. A profile using this tuning displays that field as the Huangzhong reference. The reference is musician-configurable; the catalog assigns no absolute Huangzhong Hz value. The application's default reference of 440 Hz is a general app default, not historical Huangzhong evidence.

## Built-in profile: Twelve Lü Pitch-Pipe Reference

The built-in **Twelve Lü Pitch-Pipe Reference** profile lists the twelve degrees in ascending catalog order and resolves every entry through this tuning-system ID. Its instrument/context is historical pitch pipes (*lüguan* 律管), which the historical theory describes as pitch standards. Harvard's overview also notes that bells and monochords were used as more durable or measurable pitch-determining methods, and that pitch standards regulated instruments. The *Sui shu* account specifically describes pitch pipes being used to regulate bells, chimes, and other eight-sound instruments. This supports a pitch-reference profile, not a claim that one instrument family universally used this exact reconstructed tuning in performance.

The Huangzhong degree uses the profile's configurable reference frequency. The shipped 440 Hz default is the app's general reference default; it is not presented as a historically established Huangzhong frequency. Other instruments such as the guqin should receive their own profile only when a specific, source-supported instrument tuning is selected.

**Source and limitations:**

- Du You, *Tongdian* 通典, “Music 3: Five Tones and Twelve Pitch Standards Generating Each Other,” primary historical compilation in Chinese Text Project translation: <https://ctext.org/text.pl?if=gb&node=560327>.
- Jonathan Service, “Chinese Music Theory,” Harvard University, for the pipe-length procedure, generation order, octave-closure issue, and distinction from Jing Fang's later extended cycle and Zhu Zaiyu's later equal temperament: <https://soundingchina.fas.harvard.edu/Service.html>.
- *Sui shu*, Volume 16, “Laws and Calendars I,” for historical use of pitch pipes to regulate bells, chimes, and other eight-sound instruments: <https://ctext.org/wiki.pl?chapter=906012&if=en&remap=gb>.
- Mori, “Sanfen sunyi-fa and Yin-yang philosophy,” *Tōyō Ongaku Kenkyū* / J-STAGE, for the historical development and changing interpretations of the procedure: <https://www.jstage.jst.go.jp/article/toyoongakukenkyu1936/1987/51/1987_51_4/_article>.
- Full candidate research, user approval, source qualifications, and the excluded Indian candidate disposition: [SP-038 Candidate Review](SP-038-Candidate-Review.md).

The origin story of Huangzhong pitch pipes is legendary. Historical accounts and later theories differ in generation and return conventions. This catalog adopts only the named model and playback convention above; it does not identify Huangzhong with concert C, A4=440, or any universal absolute pitch.

## Manifest inventory

Version 2 contains the eight version 1 tuning systems plus `chinese-sanfen-sunyi-huangzhong`. The fourteen version 1 profile templates and eight version 1 timbres are unchanged. No Indian śruti content is included in the playable catalog.
