# TB323FU decryption troubleshooting notes

## Known-good fix3b crypto path

The validated fix3b decryption path uses the stock TB323FU SPU KeyMint /
Gatekeeper stack, including:

- `android.hardware.security.keymint-service-spu-qti`
- `android.hardware.gatekeeper-service-spu-qti`
- `libqti-utils.so`
- `libspuqtigatekeeper.so`
- `libspukeymint.so`
- `libspukeymintutils.so`
- the other SPU support libraries staged with the fix3b stock-SPU bundle

The successful transition to this stack happened during the fix2/fix2b
decryption work and was carried forward into fix3b.

## Retired stale library: liblenovokeymint_qti.so

Historical file:

`recovery/root/system/lib64/liblenovokeymint_qti.so`

Historical SHA-256:

`fa6d3d9ee2ea16f78b53731b51be73e20200977e2f8a48a9bf0774d048d67af5`

This library was already present in the initial cleaned TB323FU tree before the
successful SPU crypto repair. Later fix2/fix2b work replaced the active crypto
path with the exact stock TB323FU SPU KeyMint/Gatekeeper stack, but this older
library was never removed from the inherited payload.

A later static requiredness audit found:

- zero inbound ELF `DT_NEEDED` dependencies on `liblenovokeymint_qti.so`;
- zero other recovery-payload filename/dlopen-style references to it;
- no tracked runtime/config references beyond its old `.gitignore` and
  `proprietary-files.tsv` entries;
- the active SPU KeyMint service links to the SPU KeyMint libraries instead.

For publication cleanup this stale library was removed from the required
recovery payload and proprietary manifest. A preserved private historical copy
is retained under the fix3b private-blob cache.

### If decryption regresses later

Revisit this note before assuming the old Lenovo KeyMint library was part of
the working fix3b crypto path. Compare the active SPU KeyMint/Gatekeeper stack,
service versions, VINTF declarations, and exact stock-SPU hashes first.

The removal was based on development chronology plus static dependency
analysis. It was not, by itself, a separate full runtime revalidation of the
recovery image.
