# Third-party recovery shell tools

The validated TB323FU fix3b recovery contains six third-party command-line
utilities under `/system/bin`. They are intentionally included so a normal
recovery build preserves the known-good shell-tool payload.

| Tool | Version | SHA-256 |
| --- | --- | --- |
| curl | 8.18.0 | `b5ea61dd713f6caeaa3b6628c6a951127c1b6db16ab1cee107d934a92369222d` |
| fastfetch | 2.64.2 | `7c71d9a3ead78aab7e8be44ffc65ac04e301d2193856cb0631d075ba8519d4b0` |
| git | 2.50.1 | `b1734feda9233090f52765000bc4160b8b274f62a24cb2b265e3d673e5323947` |
| wget | 1.25.0 | `d6c9909d70cd6411697ac10242860b2b9a6acb72783c04d751c48e19865aac4d` |
| zsh | 5.9 | `7e7ac8c450e7d5213f2db868189c6b34c18f5d3a033b2f25f2ee644d3faa36fa` |
| zstd | 1.5.6 | `f3972de532b4330b3bdfbb8e4af53b9157ad06f83133d147019fda1f02b9b49a` |

## Accompanying source/provenance bundle

Release asset: `TB323FU-TWRP-third-party-corresponding-source-fix3b.tar.xz`

SHA-256: `49eaaf833512753260320cdc0c7263a3de16fb0ac3a9159a0815146307f6b79d`

It contains upstream source archives/exact Git archives, recursively resolved
static dependencies, historical ndk-pkg formulas, full public ndk-pkg/formula
Git histories, dependency graph, source inventory, and hashes.

The normal TB323FU TWRP build does **not** rebuild these six tools.

The exact generic ndk-pkg engine commit originally used for the inherited
static binaries was not proven. No byte-for-byte rebuild claim is made.
License/notice texts are under `LICENSES/third-party-tools/`.

This is practical provenance documentation, not legal advice.
