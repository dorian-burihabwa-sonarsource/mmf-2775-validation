# Runtime analysis comparison on nuxeo

## Run the experiment
### Build the container

```bash
docker build -t nuxeo .
```

### Run the experiment
```bash
docker run -it --rm --env-file=./secrets.env --volume=${PWD}/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo /bin/bash
```
Set the `SONARQUBE_TOKEN` env variable in secrets.env.