# JustTones `.justtones` Interchange Schema

Schema version 1 is UTF-8 declarative JSON. The root object's `format` is `justtones`; `schemaVersion` is `1`; optional `catalogVersion` identifies the compatible built-in catalog. Documents contain `profiles` and `tuningSystems` arrays only—never executable code, archived objects, plug-ins, scripts, or opaque payloads.

`profiles` use the shared profile model and retain UUID identity, Unicode names and labels, entries, written/sounding pitch representation, tags, instrument, preferred timbre, and `tuningSystemID`. A tuning-system reference must resolve either to a `tuningSystems` record in the document (by its UUID string) or to a compatible built-in catalog identifier. Built-ins are referenced rather than copied.

`tuningSystems` records contain a UUID `id` and the shared declarative `TuningSystem` model. Degree definitions state their kind (`equalDivision`, `ratio`, `cents`, or `explicitFrequency`) and their unambiguous associated values. Ratios and frequencies must be finite and positive; equal divisions must be positive; unsupported values, zero denominators, non-finite numbers, unresolved references, duplicate identities, and incompatible schema versions are rejected before a preview is produced.

## Compatibility and limits

- A newer major version is rejected without mutation.
- Version 1 exports use sorted keys and stable pretty formatting. Re-exporting unchanged input is semantically deterministic.
- Import has a 10 MiB encoded limit, 10,000 JSON-object limit, 2,000 profile limit, 4,096-entry profile limit, 16 nesting-level limit, and 16 KiB per text-field limit.
- Import returns a preview only. Conflict choices—replace, keep both, or rename—are explicit. Cancellation has no side effect. A caller saves the resulting profile library through the existing atomic local-store boundary.

The iPhone registers `com.caposoft.justtones.document`, conforming to `public.json`, for the `.justtones` extension. The schema model has no playback behavior and does not access the network.
