# SIRF on Ubuntu 16.04 on Docker

Docker wrapper for CCP PET-MR SIRF.

## TL;DR, I want a (Jupyter notebook) service NOW

1. Install [docker CE][docker-ce] and [`docker-compose`][docker-compose],
2. Run `./sirf-compose-service up -d sirf` (in this folder)
3. Open a browser at <http://localhost:9999>. It may take a few seconds.
The password is `virtual`.
The directory is mounted at `/devel` in the docker container
from `./devel` (in this folder) on the host. The container will copy
[SIRF-Exercises] into this folder if not present.

[docker-ce]: https://docs.docker.com/install/
[docker-compose]: https://github.com/docker/compose/releases
[SIRF-Exercises]: https://github.com/CCPPETMR/SIRF-Exercises

Note: If on Windows, `localhost` probably won't work.
Find out the service IP address using:
```
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sirf
```
and use the resultant IP instead of `localhost` (e.g.: `172.18.0.2:9999`).

## Tags

The repository is hosted at [hub.docker.com][dockerhub-SIRF].
To pull directly, use:

```sh
docker pull ccppetmr/sirf:<DOCKER_TAG>
```

| `<DOCKER_TAG>` | Service `<DOCKER_TAG>` | [SuperBuild] branch/tag |
|:--- |:--- |:--- |
| `release` | `release-service` | `<latest_tag>` |
| `<tag>` | `<tag>-service` | `<tag>` |
| `latest` | `service` | `master` |
| `devel` | `devel-service` | `master` with `cmake -DDEVEL_BUILD=ON` |

Service images are intended to be run in the background, and expose:

| Port | Notes |
| --- | --- |
| 9999 | `Jupyter` (in folder `/devel`) |
| 9002 | `Gadgetron` |

[dockerhub-SIRF]: https://hub.docker.com/r/ccppetmr/sirf/
[SuperBuild]: https://github.com/CCPPETMR/SIRF-SuperBuild/

## More Information

`./sirf-compose*` are simple wrappers around `docker-compose`.

- For a service (Jupyter) container:
    + `./sirf-compose-service`
- For a basic interactive container:
    + on Linux: `./sirf-compose`
    + on Windows: `docker-compose`

Run any of the above commands without arguments for help.

For example, to host multiple servers on one machine, simply:
```
grep -n '# .*scaling' docker-compose*.yml  # follow these edit instructions
./sirf-compose-server up -d --scale sirf=3 sirf  # start 3 servers
./sirf-compose-server ps  # print out exposed ports
./sirf-compose-server stop  # stop all servers
```

### Links

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
