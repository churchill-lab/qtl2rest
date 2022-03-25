## rest2api

A Docker image for use with [qtl2api](https://github.com/churchill-lab/qtl2api).

## Building

    docker build --progress plain -t mattjvincent/qtl2rest:0.2.0 .


## Running

The Docker image needs 2 files to be mounted in the following directory:

**/app/qtl2rest/data**

 - RData file - it can be named anything you wish, but it needs to end in **".RData"**. *TODO: Specifications on the RData file*
 - **ccfoundersnps.sqlite** *TODO: Link to file*

The following command will start the Docker image.

```
    docker run --rm \
        -p 8001:8001 \
        --name qtl2rest \
        --network qtl2rest \
        -v /data/project.RData:/app/qtl2rest/data/projectData.RData \
        -v /data/ccfoundersnps.sqlite:/app/qtl2rest/data/ccfounders.sqlite -v \
        mattjvincent/qtl2rest:0.2.0
```

## API

The following API Endpoints will be available:

#### /datasets
 - Get information about the datsets in the RData file

**/lodpeaksall?dataset={dataset}**
 - Get LOD peaks for the specified **dataset**.

**/lodscan?dataset={dataset}&id={id}&intcovar={covar}**
 - Perform a LOD scan on the **id** in the **dataset**.  An optional interactive covariate can be specified (**covar**).

**/lodscansamples?dataset={dataset}&id={id}&chrom={chromosome}&intcovar={covar}**
 - Perform a LOD scan on the **id** in the **dataset** for a specific **chromosome**.  An interactive covariate must be specified (**covar**).  This will group samples by the **covar** and return a LOD scan for each unique **covar** value.

**/expression?dataset={dataset}&id={id}**
 - Get the expression data for the **id** in the **dataset**.

**/snpassoc?dataset={dataset}&id={id}&chrom={chromosome}&location={location}&window_size={windowSize}**
 - Perform a SNP association mapping for the specified **id**, **dataset**, **chromsome**, **location**, and **windowSize**.

**/mediate?dataset={dataset}&id={id}&marker_id={markerID}&dataset_mediate=${dataset_mediate}**
 - Perform a mediation scan for the specified **id**, **dataset**, and **markerID**.  If **dataset_mediate** is specified, the mediation will be against that dataset.

**/foundercoefs?dataset={dataset}&id={id}&chrom={chromosome}&intcovar={covar}**
 - Get the Founder coefficient data or the specified **id**, **dataset**, and **markerID**.  If **covar** is specified, that interactive covariate will be used.
  
**/correlation?dataset={dataset}&id={id}&dataset_correlate={dataset_correlate}&intcovar={covar}**
 - Perform a correlation scan for the specified **id** in **dataset**.  If **dataset_correlate** is specified, the correlation will be against that dataset.  If **covar** is specified, that interactive covariate will be used.

**/correlationplot?dataset={dataSet}&id={id}&dataset_correlate={dataset_correlate}&id_correlate={id_correlate}&intcovar={covar}**
 - Perform a correlation scan for the specified **id** in **dataset** against the specified **id_correlate** in **dataset_correlate**.  If **covar** is specified, that interactive covariate will be used.  This is mainly for seeing how the two ids look when plotted.



