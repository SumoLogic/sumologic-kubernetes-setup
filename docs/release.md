# Releasing guide

Perform the following steps in order to release new verions of Sumologic Kubernetes Setup.

1. Prepare and merge PR with the following changes:

   - update [changelog][changelog]

1. Create and push new tag:

   ```bash
   export TAG=x.y.z
   git tag -sm "v${TAG}" "v${TAG}"
   git push origin "v${TAG}"
   ```

[changelog]: ../../CHANGELOG.md
