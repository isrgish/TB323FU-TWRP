# Proprietary-file acquisition

The validated TB323FU fix3b recovery requires **103** proprietary payload
targets after retirement of the stale inherited `liblenovokeymint_qti.so`.

They are intentionally excluded from this Git repository.

## Acquisition classes

`proprietary-sources.tsv` pins every target by path, size, and SHA-256.

- **25 `tb323fu-stock` targets** are exact files from the tested TB323FU stock
  firmware:
  `TB323FU_ROW_OPEN_USER_Q00020.0_A16_ZUI_18.0.12.104_ST_260711`
- **78 `public-tb322fc-git` targets** are exact inherited bytes from the
  public donor tree:
  `polygraphene/android_device_lenovo_TB322FC`
  at/present in history reachable from pinned commit
  `c9c6a9f1287e5b416c3480c5fe06b23dc54c9ab8`.

TB322FC is the **upstream donor tree**, not the target device. The build target
remains TB323FU.

The donor mapping records exact Git blob object IDs and introducing commits.
Every acquired byte is SHA-256 verified before it is copied into the recovery
tree.

## Staging

Run:

```bash
scripts/acquire-proprietary-files.sh --stock-root /path/to/stock-root
```

On the matching TB323FU device itself, `--stock-root /` can be used when the
stock partition files are readable. On a build host, provide an extracted
filesystem root containing the mapped Android paths such as `vendor/...`.

The acquisition script builds the complete payload in a temporary staging
directory first and only updates the recovery tree after all 103 sources pass
their size/SHA-256 checks.

## Licensing

The source map documents provenance/acquisition; it does **not** grant a
license to Lenovo, Qualcomm, or other proprietary material. The TB322FC donor
repository is a third-party public source of the exact inherited bytes used by
the validated recovery. Builders are responsible for ensuring they have the
right to use any proprietary material they acquire.

See also `docs/DECRYPTION_TROUBLESHOOTING.md` for the historical KeyMint/SPU
transition and the retired stale Lenovo KeyMint library.
