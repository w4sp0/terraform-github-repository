<!--
SPDX-FileCopyrightText: 2020-2022 Mineiros GmbH <hello@mineiros.io>
SPDX-FileCopyrightText: 2025-2026 Radek Janik <cyberwassp@gmail.com>

SPDX-License-Identifier: Apache-2.0
-->

# terraform-github-repository

[![Terraform Version](https://img.shields.io/badge/terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![Github Provider Version](https://img.shields.io/badge/GH-6.x-F8991D.svg?logo=terraform)](https://github.com/integrations/terraform-provider-github/releases)

## Fork Notice

This is a maintained fork of [mineiros-io/terraform-github-repository](https://github.com/mineiros-io/terraform-github-repository), which is no longer actively maintained. The goal of this fork is to bring the module up to GitHub Provider v6 compatibility and continue ongoing maintenance.

**Attention**: This module requires the `integrations/github` provider and is incompatible with the deprecated `hashicorp/github` provider.

## Warning

**Warning**: As this repository is being brough up to GitHub provider v6, it is
currently not ready for production, development only. Breaking changes can and
will be introduced in the meantime. You've been warned.

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Module Reference](#module-reference)
- [Contribute](#contribute)
- [Support](#support)
- [Contact](#contact)
- [Credits](#credits)
- [Legal](#legal)
- [Versioning](#versioning)

## Description

A [Terraform](https://www.terraform.io) module for creating and managing public or private repositories on [GitHub](https://github.com/).

This module supports Terraform v1.x and is compatible with the Official Terraform GitHub Provider v6.x from `integrations/github`.

Originally developed by [Mineiros](https://github.com/mineiros-io), this fork aims to:

- Update compatibility to GitHub Provider v6
- Fix outstanding issues and bugs
- Continue active maintenance and development

In contrast to the plain `github_repository` resource, this module enables various other features like Branch Protection, Collaborator Management, Deploy Keys, Webhooks, and more.

## Features

- **Default Security Settings**: Private repositories by default, read-only deploy keys by default
- **Standard Repository Features**: Metadata, merge strategy, auto init, license template, gitignore template, template repository
- **Extended Repository Features**: Branches, branch protection (v3 and v4), issue labels, collaborators, teams, deploy keys, projects, webhooks, secrets, autolink references, app installations

## Getting Started

Most basic usage creating a new private GitHub repository:

```hcl
module "repository" {
  source  = "w4sp0/repository/github"
  version = "~> 0.18.5"

  name               = "terraform-github-repository"
  license_template   = "apache-2.0"
  gitignore_template = "Terraform"
}
```

## Usage

See [variables.tf](variables.tf) and [examples/](examples/) for detailed use-cases.

The intended behavior is to enforce the state of repositories and their configurations. If you modify resources outside of Terraform and reapply the state, conflicting configurations will be overwritten.

For comprehensive documentation on module arguments, outputs, and advanced configurations, see [MODULE_REFERENCE.md](docs/MODULE_REFERENCE.md).

### Quick Reference

| Argument | Description | Default |
|----------|-------------|---------|
| `name` | Repository name | Required |
| `visibility` | `public`, `private`, or `internal` | `"private"` |
| `description` | Repository description | `""` |
| `default_branch` | Default branch name | `""` |
| `has_issues` | Enable GitHub Issues | `false` |
| `has_projects` | Enable GitHub Projects | `false` |
| `has_wiki` | Enable GitHub Wiki | `false` |
| `allow_merge_commit` | Allow merge commits | `true` |
| `allow_squash_merge` | Allow squash merges | `false` |
| `allow_rebase_merge` | Allow rebase merges | `false` |
| `delete_branch_on_merge` | Auto-delete head branches | `true` |
| `vulnerability_alerts` | Enable security alerts | - |
| `archive_on_destroy` | Archive instead of delete | `true` |

### Teams and Collaborators

```hcl
module "repository" {
  source = "w4sp0/repository/github"

  name = "my-repo"

  # Teams (by slug)
  admin_teams    = ["admin-team"]
  push_teams     = ["developers"]
  pull_teams     = ["contractors"]

  # Individual collaborators
  admin_collaborators = ["admin-user"]
  push_collaborators  = ["dev-user"]
}
```

### Branch Protection

```hcl
module "repository" {
  source = "w4sp0/repository/github"

  name = "my-repo"

  branch_protections_v4 = [
    {
      pattern                = "main"
      enforce_admins         = true
      require_signed_commits = true

      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        require_code_owner_reviews      = true
        required_approving_review_count = 1
      }

      required_status_checks = {
        strict   = true
        contexts = ["ci/build", "ci/test"]
      }
    }
  ]
}
```

## Module Reference

For the complete module argument reference, outputs, and advanced configurations, see [docs/MODULE_REFERENCE.md](docs/MODULE_REFERENCE.md).

### External Documentation

- [Terraform GitHub Provider - Repository](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository)
- [Terraform GitHub Provider - Branch](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch)
- [Terraform GitHub Provider - Branch Protection](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection)

## Contribute

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

Areas where help is especially appreciated:

- Testing with GitHub Provider v6
- Documentation improvements
- Bug fixes and feature additions

## Support

Support is provided on a best effort basis. If you encounter issues or have feature requests, please open an issue on GitHub. The project is best developed in the open so anyone can search for past issues and solutions.

## Contact

- [GitHub Issues](../../issues) - Bug reports and feature requests
- [GitHub Discussions](../../discussions) - Questions and community discussion

## Credits

This module was originally developed by [Mineiros GmbH](https://mineiros.io). Their work on Terraform modules for GitHub management laid the foundation for this project.

Thanks to all contributors to both the original repository and this fork.

## Legal

This project is [REUSE-compliant](https://reuse.software).

The easiest way to get the copyright and license of the project is with the reuse tool:

```sh
reuse spdx
```

You can also check this information manually by looking in the file header, a companion `.license` file, or in `.reuse/dep5`.

All licenses are present in the `LICENSES` directory.

## Versioning
This project follows [Semantic Versioning (SemVer)](https://semver.org/):

- `MAJOR` version for incompatible changes
- `MINOR` version for backwards compatible functionality
- `PATCH` version for backwards compatible bug fixes
