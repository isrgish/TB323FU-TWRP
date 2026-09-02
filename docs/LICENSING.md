# Licensing and third-party material

This repository is a **mixed-origin device tree**. Do not assume that one
blanket license applies to every file.

## Files with explicit SPDX identifiers

The core device-tree files that carry:

`SPDX-License-Identifier: Apache-2.0`

remain under the Apache License 2.0. A copy is provided at
`LICENSES/Apache-2.0.txt`.

Examples include the primary Android/TWRP make/build files such as
`Android.bp`, `AndroidProducts.mk`, `BoardConfig.mk`, `device.mk`, and
`twrp_TB323FU.mk`.

## Files retaining their own notices

Files with an embedded copyright or license notice retain that notice and its
terms. For example, `prebuilts/avbtool` retains its upstream permissive license
notice.

## Patches

Files under `patches/` are intended to modify upstream projects. They do not
replace or override the license of the upstream source to which they apply.
The applicable upstream source license must also be observed.

## Proprietary Lenovo / Qualcomm files

Lenovo/Qualcomm proprietary binaries, firmware, services, and libraries are
**not included in Git history**.

`proprietary-files.tsv` records the exact private-development target paths and
hashes used by the validated fix3b build. Builders must obtain any required
proprietary files from a source they are legally entitled to use.

The repository does not grant a license to Lenovo, Qualcomm, or other
third-party proprietary material.

## External prebuilt shell tools

Opaque `zsh`, `git`, `curl`, `wget`, `zstd`, and `fastfetch` binaries used by
the validated private development environment are not included in Git history.
`prebuilt-tools.tsv` records the exact validated private-development hashes.

Public-source/replacement handling for these optional recovery shell utilities
is being documented separately.

## Files without an explicit license notice

No default blanket license is asserted here for a file that lacks an explicit
license or a clearly documented upstream origin. Such files remain subject to
their actual provenance and applicable rights.

This document is practical project documentation, not legal advice.
