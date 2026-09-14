# JustTones Capability Inventory

This inventory implements the EP-001 foundation review for JT-BR-002, JT-BR-003, JT-FR-024 through JT-FR-028, JT-FR-079, JT-NFR-023, JT-NFR-028, JT-SR-016, and JT-SR-023. Final capability qualification remains governed by the mapped requirements and tests.

| Capability | Foundation disposition | Rationale / later gate |
| --- | --- | --- |
| iPhone target | Configured | iOS 27.0, iPhone device family only; bundle ID `com.caposoft.JustTones`. |
| Watch companion | Configured | watchOS 27.0; bundle ID `com.caposoft.JustTones.watchkitapp`; companion ID points to the iPhone app and the Watch product is embedded. |
| Swift language | Configured | Swift 6 for application and test targets; Swift tools 6.4 for the shared package. |
| Background audio | Deferred | Enable only with the authorized audio-session implementation and verify lock/background behavior in EP-003. |
| App Group | Deferred | Select and provision the final JustTones-only group when EP-006 synchronization work requires it. No JustTune group may be reused. |
| Document type / exported UTI | Deferred | Define the `.justtones` type with import/export implementation in EP-004. |
| Microphone | Not applicable | Prohibited for JustTones by JT-SR-016; no usage description or entitlement is present. |
| Network client entitlement | Not applicable | Core use is offline; external help links are handed to the system browser only after user action. |
| Accounts, CloudKit, analytics, ads | Not applicable | Explicitly outside approved product scope. |
| Store distribution and archive validation | Deferred | Final identifiers, signing, archive, and App Store availability are qualified in EP-008. |

No external provisioning or developer-portal state is changed by this inventory.
