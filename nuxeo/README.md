# Runtime analysis comparison on nuxeo

## Run the experiment
### Build the container

```bash
docker build -t nuxeo .
```

### Run the experiment
A local sonarqube instance with PR analysis support must be running on port 9000.
The analysis token should be placed in local file to pass to the script (here the `SONARQUBE_TOKEN` is set in variable in secrets.env).
```
SONARQUBE_TOKEN=<your analysis token here
```

```bash
docker run -it --rm --env-file=./secrets.env --volume=${PWD}/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo /bin/bash
```

A simple run of the experiment can be done by running the main script

```bash
./run.sh
```


### Parse results

The results of a run can be parsed and dumped as as csv file using the python script in this folder.
```bash
./parse.py <reports folder> > data.csv
```
