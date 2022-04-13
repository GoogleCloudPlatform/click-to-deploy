# Contributing Guidelines

Contributions are welcome via GitHub pull requests.

## Sign Your Work

To certify you agree to the [Developer Certificate of Origin](https://developercertificate.org/) you must sign-off each commit message using `git commit --signoff`, or manually write the following:
```text
This is my commit message

Signed-off-by: John Smith <john.smith@example.org>
```

The text of the agreement is:
```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

## Semantic Commit Messages

All commit messages and PR names must pass the [zeke/semantic-pull-requests](https://github.com/zeke/semantic-pull-requests) check.

Here are some example semantic commit messages:
- `feat: a new feature`
- `fix: a bug fix`
- `docs: documentation only change`
- `style: fix formatting/white-space/etc`
- `refactor: code change that neither fixes a bug nor adds a feature`
- `test: add or update tests`
- `ci: changes to CI configs`
- `chore: other changes that dont modify code`
- `revert: revert a commit`

## Documentation

Most non-patch changes will require documentation updates.

If you __ADD a value__:
- ensure the value has a descriptive docstring in `values.yaml`
- ensure the value is listed under `Values Reference` in [README.md](README.md#values-reference)
   - Note, only directly include the value if it's a top-level value like `airflow.level_1`, otherwise only include `airflow.level_1.*`

If you __bump the version__:
- add a heading for the new version to [CHANGELOG.md](CHANGELOG.md) (and comparison link, at bottom of file)

## Linting

Please ensure `ct lint` from [chart-testing](https://github.com/helm/chart-testing) succeeds.

## Versioning

The chart `version` should follow [SemVer](https://semver.org/):
- If you __REMOVE/CHANGE a value__ → bump a MAJOR version
- If you __ADD a value__ → bump a MINOR version
- If you __fix a bug__ → bump a PATCH version
