# Release guide

Perform the following steps in order to release a new version of Sumologic Kubernetes Setup.

1. Prepare and merge PR with the following changes:

   - update [changelog][changelog]

1. Create and push new tag:

   ```bash
   export TAG=x.y.z
   git checkout main
   git pull
   git tag -sm "v${TAG}" "v${TAG}"
   git push origin "v${TAG}"
   ```

1. Update [releases] page

[changelog]: ../CHANGELOG.md
[releases]: https://github.com/SumoLogic/sumologic-kubernetes-setup/releases
