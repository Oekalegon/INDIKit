# GitHub Branch Protection and Workflow Configuration

This document describes the branch protection rules and workflow requirements for this repository.

## Branch Strategy

- **`develop`**: Default branch for ongoing development
  - Feature branches merge here via PR
  - All PRs must pass required checks before merging
  
- **`main`**: Production/release branch
  - Hotfix branches merge here via PR
  - Release branches merge here via PR
  - Used for releases and downloads
  - All PRs must pass required checks before merging

## Required GitHub Settings

### 1. Set Default Branch to `develop`

1. Go to **Settings** → **General**
2. Scroll down to the "Default branch" section
3. Click the switch/edit icon next to the current default branch
4. Select `develop` from the dropdown
5. Click **Update**
6. Confirm the change if prompted

### 2. Configure Branch Protection Rules

#### For `develop` branch:

1. Go to **Settings** → **Branches**
2. Click **Add rule** (or edit existing rule for `develop`)
3. Configure:
   - **Branch name pattern**: `develop`
   - ✅ **Require a pull request before merging**
     - ✅ Require approvals: `1` (or more as needed)
     - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ **Require status checks to pass before merging**
     - ✅ Require branches to be up to date before merging
     - **Status checks that are required:**
       - ✅ `CI / build-and-test` (from ci.yml)
       - ✅ `SwiftLint` (from lint.yml)
       - ✅ `PR Validation / validate-branch-target` (from pr-validation.yml)
       - ✅ `Docs / validate-docs` (from docs.yml - validates documentation builds on PRs)
   - ❌ **Do not allow bypassing the above settings** (unchecked - allows repository admins/owners to bypass)
   - ❌ **Allow force pushes** (unchecked)
   - ❌ **Allow deletions** (unchecked)
   
   **Note**: Some options like "Require conversation resolution" and "Restrict who can push" may not be visible in all GitHub repositories or may be located in different sections. Focus on the core settings listed above.
   
   **Note**: By unchecking "Do not allow bypassing the above settings", repository owners and admins can merge PRs even without approvals or passing status checks. This allows you to override the rules when needed.
   
   **Additional settings**: If you see other options in your GitHub UI that aren't listed here, you can configure them as needed. The most important settings are requiring PRs, approvals, and status checks.

#### For `main` branch:

1. Go to **Settings** → **Branches**
2. Click **Add rule** (or edit existing rule for `main`)
3. Configure:
   - **Branch name pattern**: `main`
   - ✅ **Require a pull request before merging**
     - ✅ Require approvals: `1` (or more as needed)
     - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ **Require status checks to pass before merging**
     - ✅ Require branches to be up to date before merging
     - **Status checks that are required:**
       - ✅ `CI / build-and-test` (from ci.yml)
       - ✅ `SwiftLint` (from lint.yml)
       - ✅ `PR Validation / validate-branch-target` (from pr-validation.yml)
       - ✅ `Docs / validate-docs` (from docs.yml - validates documentation builds on PRs)
   - ❌ **Do not allow bypassing the above settings** (unchecked - allows repository admins/owners to bypass)
   - ❌ **Allow force pushes** (unchecked)
   - ❌ **Allow deletions** (unchecked)
   
   **Note**: Some options like "Require conversation resolution" and "Restrict who can push" may not be visible in all GitHub repositories or may be located in different sections. Focus on the core settings listed above.
   
   **Note**: By unchecking "Do not allow bypassing the above settings", repository owners and admins can merge PRs even without approvals or passing status checks. This allows you to override the rules when needed.
   
   **Additional settings**: If you see other options in your GitHub UI that aren't listed here, you can configure them as needed. The most important settings are requiring PRs, approvals, and status checks.

### 3. Configure Branch Rules for PR Targeting

This repository includes a PR validation workflow (`.github/workflows/pr-validation.yml`) that automatically validates PR targeting based on branch naming:

- **Feature branches** (`feature/*`) → must target `develop`
- **Hotfix branches** (`hotfix/*`) → must target `main`
- **Release branches** (`release/*`) → must target `main`
- **All other branches** → must target `develop` (default)

This workflow runs automatically on PRs and will fail if a branch targets the wrong base branch. Only `hotfix/*` and `release/*` branches are allowed to target `main`.

**Note**: This check is configured as required in the branch protection rules above, so PRs cannot be merged if they target the wrong branch.

### 4. Configure Releases for Downloads

When creating releases manually:

1. Go to your repository's **Releases** page
2. Click **Create a new release**
3. Select the tag from the `main` branch (or create a new tag on `main`)
4. The release will be associated with `main` branch

**Note**: GitHub doesn't have a setting to automatically enforce which branch releases come from. You need to manually ensure that when creating releases, you select tags that are on the `main` branch. The release page will show which branch/commit the tag points to.

## Workflow Status Checks

### Required Checks (must pass before merge):
- ✅ **CI / build-and-test**: Builds and tests the Swift package
- ✅ **SwiftLint**: Runs SwiftLint with strict mode
- ✅ **PR Validation / validate-branch-target**: Validates PR branch targeting rules (enforces feature→develop, hotfix/release→main, others→develop)
- ✅ **Docs / validate-docs**: Validates documentation builds on PRs (ensures docs build successfully before merge)

### Post-Merge Actions (run after merging, not required for PRs):
- 📦 **Docs / build-and-deploy**: Builds and deploys documentation to GitHub Pages (only runs on push to main, not on PRs)

## Notes

- The `docs.yml` workflow has a `validate-docs` job that runs on PRs to validate documentation builds correctly - this is required before merging
- The `build-and-deploy` job in `docs.yml` only runs on pushes to `main` or manual dispatch (after merging), not on PRs, so it cannot be a required check for PRs
- All direct pushes to `develop` and `main` are blocked by branch protection rules

