# Import Study Using Docker

:warning: Please make sure to restart tomcat every time you add/remove/overwrite a study

## Adding a Study

In a docker terminal type the following command:

```bash
docker exec -it "{CBIOPORTAL_CONTAINER_NAME}" \
metaImport.py -u http://"{CBIOPORTAL_CONTAINER_NAME}":8080/cbioportal -s "{/PATH/TO/STUDIES}" --html=/outdir/report.html
```

Where:    
- **{CBIOPORTAL_CONTAINER_NAME}**: The name of your cbioportal container instance, _i.e **cbioportal**_.
- **{/PATH/TO/STUDIES}**: The external path where cBioPortal studies are stored.

## Removing a Study

In a docker terminal type the following command:

```bash
docker exec -it "{CBIOPORTAL_CONTAINER_NAME}" \
Coming soon...
```

Where:    
- **{CBIOPORTAL_CONTAINER_NAME}**: The name of your cbioportal container instance, _i.e **cbioportal**_.
- **{/PATH/TO/STUDIES}**: The external path where cBioPortal studies are stored.


## Restarting Tomcat

In a docker terminal type the following command:

```bash
docker exec -it "{CBIOPORTAL_CONTAINER_NAME}" \
Coming soon...
```

Where:    
- **{CBIOPORTAL_CONTAINER_NAME}**: The name of your cbioportal container instance, _i.e **cbioportal**_.