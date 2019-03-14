# SIRF on Ubuntu 16.04 on Docker

Docker wrapper for CCP PET-MR SIRF.

- [SIRF docker source]
    + See also: [SIRF SuperBuild on Docker wiki]
- [Synergistic Image Reconstruction Framework (SIRF) project][SIRF]
    + [SIRF wiki]
- [Collaborative Computational Project in Positron Emission Tomography and Magnetic Resonance imaging (CCP PET-MR)][CCP PET-MR]

[SIRF docker source]: https://github.com/CCPPETMR/SIRF-SuperBuild/tree/master/docker
[SIRF SuperBuild on Docker wiki]: https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-Docker
[SIRF]: https://github.com/CCPPETMR/SIRF
[SIRF wiki]: https://github.com/CCPPETMR/SIRF/wiki
[CCP PET-MR]: https://www.ccppetmr.ac.uk/

## Tags

The repository is hosted at [hub.docker.com][dockerhub-SIRF].
To pull directly, use:

```sh
docker pull ccppetmr/sirf:<DOCKER_TAG>
```

| `<DOCKER_TAG>` | [SuperBuild] branch/tag |
|:--- |:--- |
| `release` | `<latest_tag>` |
| `<tag>` | `<tag>` |
| `latest` | `master` |
| `devel` | `master` with `cmake -DDEVEL_BUILD=ON` |

[dockerhub-SIRF]: https://hub.docker.com/r/ccppetmr/sirf/
[SuperBuild]: https://github.com/CCPPETMR/SIRF-SuperBuild/
