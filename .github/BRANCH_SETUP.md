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

1. Go to **Settings** → **Branches**
2. Under "Default branch", click the switch icon
3. Select `develop` as the default branch
4. Click **Update**

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
       - ❌ `Docs / validate-docs` (optional - runs but not required)
   - ✅ **Require conversation resolution before merging**
   - ✅ **Do not allow bypassing the above settings**
   - ✅ **Restrict who can push to matching branches**: (leave empty or add specific users/teams)
   - ❌ **Allow force pushes** (unchecked)
   - ❌ **Allow deletions** (unchecked)

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
       - ❌ `Docs / validate-docs` (optional - runs but not required)
   - ✅ **Require conversation resolution before merging**
   - ✅ **Do not allow bypassing the above settings**
   - ✅ **Restrict who can push to matching branches**: (leave empty or add specific users/teams)
   - ❌ **Allow force pushes** (unchecked)
   - ❌ **Allow deletions** (unchecked)

### 3. Configure Branch Rules for PR Targeting

This repository includes a PR validation workflow (`.github/workflows/pr-validation.yml`) that automatically validates PR targeting based on branch naming:

- **Feature branches** (`feature/*`) → must target `develop`
- **Hotfix branches** (`hotfix/*`) → must target `main`
- **Release branches** (`release/*`) → must target `main`
- **All other branches** → must target `develop` (default)

This workflow runs automatically on PRs and will fail if a branch targets the wrong base branch. Only `hotfix/*` and `release/*` branches are allowed to target `main`.

**Optional**: If you want this validation to be required before merging:
1. Go to branch protection settings for `develop` and `main`
2. Add `PR Validation / validate-branch-target` to the required status checks

### 4. Configure Releases for Downloads

To make `main` the branch shown for downloads:

1. Go to **Settings** → **General** → **Releases**
2. Ensure releases are created from `main` branch
3. When creating releases, tag from `main` branch

## Workflow Status Checks

### Required Checks (must pass before merge):
- ✅ **CI / build-and-test**: Builds and tests the Swift package
- ✅ **SwiftLint**: Runs SwiftLint with strict mode

### Optional Checks (run but not required):
- ⚠️ **Docs / validate-docs**: Validates documentation builds (runs on PRs but not required)
- ⚠️ **PR Validation / validate-branch-target**: Validates PR branch targeting rules (optional - can be made required if desired)

## Notes

- The `docs.yml` workflow has a `validate-docs` job that runs on PRs to check if documentation builds correctly, but it's not set as required to avoid blocking merges for documentation-only issues
- The `build-and-deploy` job in `docs.yml` only runs on pushes to `main` or manual dispatch, not on PRs
- All direct pushes to `develop` and `main` are blocked by branch protection rules

