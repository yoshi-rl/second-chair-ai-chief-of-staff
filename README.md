# Second Chair

Second Chair is a human-guided AI chief-of-staff prototype for founders. This fork adds a native macOS workspace while preserving the original validation website.

## Native macOS app

The SwiftUI app includes:

- a daily operating brief;
- a persistent human approval queue;
- business workstreams across lead generation, sales, marketing, operations, finance, and people;
- an executive brief for decisions and exceptions;
- a transparent connector map that distinguishes sandbox demonstrations from roadmap-only integrations.

The current build uses local sample data. It does not send messages, launch ads, update marketplaces, move money, or mutate live CRM data.

### Design language

The native app uses the **Executive Command Centre** palette: `#F7F7F5` workspace backgrounds, white cards, `#111111` primary text, deep forest `#1F5D4E` for actions, slate `#64748B` for supporting information, and emerald for success. Colour is deliberately sparse to keep the interface calm, premium, and high-trust.

### Run

Requirements: macOS 14 or later and Swift 6.

```bash
bash ./script/build_and_run.sh
```

Use `bash ./script/build_and_run.sh --verify` to build, launch, and confirm the process is running. The Codex environment also exposes the same command as its Run action.

### Test

```bash
swift test
```

## Validation website

The original static landing page remains at the repository root in `index.html`, with its supporting CSS and JavaScript unchanged.
