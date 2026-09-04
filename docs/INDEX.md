# TB323FU TWRP documentation

This repository targets the **Lenovo TB323FU**. References to **TB322FC**
identify the public upstream donor/base work only; TB322FC is not the build
target.

## Start here

- [Known-good baseline](KNOWN_GOOD.md) — validated fix3b runtime and source
  baseline.
- [Building](BUILDING.md) — canonical build/preflight workflow.
- [Proprietary files](PROPRIETARY_FILES.md) — acquisition and verification of
  the 103 required proprietary payload targets.
- [Third-party tools](THIRD_PARTY_TOOLS.md) — recovery shell-tool provenance,
  licensing, and corresponding-source bundle.
- [Publication status](PUBLICATION_STATUS.md) — what has and has not been
  validated for the public source release.

## Provenance and licensing

- [Tree provenance](../TREE_PROVENANCE.md)
- [Licensing](LICENSING.md)
- [Top-level NOTICE](../NOTICE)
- [Top-level LICENSES directory](../LICENSES/)

## Troubleshooting

- [Decryption troubleshooting](DECRYPTION_TROUBLESHOOTING.md) — SPU
  KeyMint/Gatekeeper history and the retired stale
  `liblenovokeymint_qti.so`.

## Verification scripts

The repository includes fail-fast checks for the device tree, proprietary
source map, public documentation, and acquisition workflow. The canonical
public build script also supports `--preflight-only` so source preparation can
be tested without invoking the large Android/TWRP compile.
