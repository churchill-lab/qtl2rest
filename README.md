## rest2api

A Docker image for use with [qtl2api](https://github.com/churchill-lab/qtl2api).

## Building

    docker build --progress plain -t churchilllab/qtl2rest .


## Running

The Docker image needs a file and a path to be mounted in the following loctions:

**/app/qtl2rest/data**

 - R data directory - this should have RData and Rds files

**ccfoundersnps.sqlite** 

- founder snps database

The following command will start the Docker image.

```
    docker run --rm \
        -p 8001:8001 \
        --name qtl2rest \
        --network qtl2rest \
        -v /data/rdata:/app/qtl2rest/rdata \
        -v /data/ccfoundersnps.sqlite:/app/qtl2rest/data/ccfounders.sqlite -v \
        churchilllab/qtl2rest
```

## API

The following API Endpoints will be available:

#### /envinfo
- Get information about the files loaded and what elements they contain

#### /markers
 - Get all the markers or markers for a chromosome

#### /datasets
 - Get information about the datasets loaded

#### /datasetsstats
 - Get statistic information about the datasets loaded

#### /rankings
 - Get a ranking of gene annotations.  For use with SNP association.

#### /idexists?id={id}&dataset={dataset}
 - See if the **id** exists in the viewer or dataset if **dataset** is supplied.

#### /lodpeaks?dataset={dataset}
 - Get LOD peaks for the specified **dataset**.

#### /lodscan?dataset={dataset}&id={id}&intcovar={covar}
 - Perform a LOD scan on the **id** in the **dataset**.  An optional interactive covariate can be specified (**covar**).

#### /lodscansamples?dataset={dataset}&id={id}&chrom={chromosome}&intcovar={covar}
 - Perform a LOD scan on the **id** in the **dataset** for a specific **chromosome**.  An interactive covariate must be specified (**covar**).  This will group samples by the **covar** and return a LOD scan for each unique **covar** value.

#### /expression?dataset={dataset}&id={id}
 - Get the expression data for the **id** in the **dataset**.

#### /snpassoc?dataset={dataset}&id={id}&chrom={chromosome}&location={location}&window_size={windowSize}
 - Perform a SNP association mapping for the specified **id**, **dataset**, **chromsome**, **location**, and **windowSize**.

#### /mediate?dataset={dataset}&id={id}&marker_id={markerID}&dataset_mediate=${dataset_mediate}
 - Perform a mediation scan for the specified **id**, **dataset**, and **markerID**.  If **dataset_mediate** is specified, the mediation will be against that dataset.

#### /foundercoefs?dataset={dataset}&id={id}&chrom={chromosome}&intcovar={covar}
 - Get the Founder coefficient data or the specified **id**, **dataset**, and **markerID**.  If **covar** is specified, that interactive covariate will be used.
  
#### /correlation?dataset={dataset}&id={id}&dataset_correlate={dataset_correlate}&intcovar={covar}
 - Perform a correlation scan for the specified **id** in **dataset**.  If **dataset_correlate** is specified, the correlation will be against that dataset.  If **covar** is specified, that interactive covariate will be used.

#### /correlationplot?dataset={dataSet}&id={id}&dataset_correlate={dataset_correlate}&id_correlate={id_correlate}&intcovar={covar}
 - Perform a correlation scan for the specified **id** in **dataset** against the specified **id_correlate** in **dataset_correlate**.  If **covar** is specified, that interactive covariate will be used.  This is mainly for seeing how the two ids look when plotted.



