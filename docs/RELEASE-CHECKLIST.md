# Release checklist

Record the release candidate version, full SHA, build provenance, systems and architecture, compiler and Qt versions, and CI results.

- [ ] Relevant matrix items are verified and critical and high defects are addressed.
- [ ] Linux and Windows Debug and Release builds and tests pass. Record real UI acceptance, reproducibility checks, performance and security results.
- [ ] Windows x64 portable ZIP launches with its packaged Qt and Visual C++ runtimes and without SDK paths.
- [ ] Windows installer tests cover Start Menu, desktop shortcut, safe upgrade, rollback and removal with user files preserved.
- [ ] Linux AppImage or distribution package is usable on supported systems and provides application metadata, desktop entry, icons and install instructions.
- [ ] Verify the SHA-256 of each downloadable package. Distribute the dependency manifest, SBOM, notices and required corresponding source or source offer under the selected license route.
- [ ] Sign packages when an approved certificate is available. Record the signature result and unsigned status where applicable.
- [ ] Publish release notes, changelog, installation and removal instructions and validation limitations. Confirm release authorization and repository controls.

Historical installer, portable and screenshot artifact IDs are recorded in [the development log](DEVELOPMENT-LOG.md).
