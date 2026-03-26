## 1.0.0

### Breaking

- Replaced boolean state with `LiquidGlassSwitchValue` enum (`light` / `dark`).
- Replaced face API with `LiquidGlassSwitchContent` and `LiquidGlassStateContent`.
- Introduced style-object API via `LiquidGlassSwitchStyle` and nested style classes.

### Added

- New visual system matching dark/light glass reference style.
- New glass shader controls: `refraction`, `depth`, `dispersion`, `frost`, `lightAngle`, `lightIntensity`.
- Partial orb overflow geometry control.
- State-level icon glow customization.
- Orb rebound controls in `LiquidGlassSwitchMotion` (`bounceAmplitude`, `bounceCycles`, `bounceDamping`, `bounceDuration`).
- `onPositionChanged` callback for progress-driven external effects.
- Golden tests for `dark` and `light` visual states.

### Changed

- Updated example app to showcase the final dark/light switch only, with background transitions driven by switch progress.
- Updated README with migration notes and new API usage.
