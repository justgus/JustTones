# Pitch Domain Semantics

`JustTonesCore` represents named pitch identity separately from calculated frequency. `NamedPitch` retains its note letter, accidental, and octave verbatim, so enharmonic spellings such as C♯4 and D♭4 calculate to the same sounding frequency without becoming the same value.

The default calculation is twelve-tone equal temperament with A4 at 440.0 Hz. `ReferencePitch` stores valid A4 values as an integer number of tenths of a hertz (3,500 through 5,000), while `DirectFrequency` stores its valid range (160 through 120,000 tenths) the same way. This avoids locale-dependent parsing and prevents entry/display precision from reducing calculation precision.

Invalid non-finite values, values outside the supported ranges, and values not exactly representable to a tenth of a hertz are rejected with `PitchValidationError`; they are never silently normalized. Named-pitch frequency calculation keeps `Double` precision and reports arithmetic overflow deterministically.

`WrittenSoundingPitch` retains its written `NamedPitch` and records the sounding displacement in semitones. Transposition changes only that displacement, so applying an inverse displacement round-trips exactly and the musician's original spelling remains available throughout.

`PitchDomainFixtures` provides independently calculated twelve-tone frequency points and the complete supported reference range to the package, iPhone, and Watch test hosts. It keeps cross-platform calculation checks on the same inputs without coupling the domain to a UI or test framework.

## Generalized tuning semantics

`TuningSystem` is a platform-neutral ordered collection of no more than 4,096 uniquely identified degrees. Each `TuningDegreeDefinition` is validated at creation and is exactly one of: equal divisions of an octave, a positive finite ratio, finite cents, or an existing validated `DirectFrequency`.

Equal-division, ratio, and cents definitions are relative: changing the supplied `ReferencePitch` recalculates them. Explicit frequencies are absolute and remain unchanged. Resolved relative values must remain within the supported 16.0–12,000.0 Hz domain range; invalid definition values and overflows produce deterministic `TuningValidationError` cases.

`TuningContext` stores musician-supplied system, tradition, region, instrument or performance context, and provenance without inference or a claim that any variant is universal. `TuningDomainFixtures` shares the four-representation qualification system with all test hosts.
