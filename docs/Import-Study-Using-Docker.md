Import Study Using Docker

## Adding a Study

:warning: Please make sure to restart tomcat every time you update a study

```bash
docker exec -it "{CBIOPORTAL_CONTAINER_NAME}" \
metaImport.py -u http://"{CBIOPORTAL_CONTAINER_NAME}":8080/cbioportal -s "{/PATH/TO/STUDIES}" --html=/outdir/report.html
```

Where:    
- **{CBIOPORTAL_CONTAINER_NAME}**: The name of your cbioportal container instance, _i.e **cbioportal**_.
- **{/PATH/TO/STUDIES}**: The external path where cBioPortal studies are stored.

## Removing a Study

Coming soon...