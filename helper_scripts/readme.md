## Update the UCSC marker table

### specific UCSC tree version
```
nextflow run update_ucsc_marker.nf -profile singularity --singularity_cache_dir /path/to/your/cache -resume --downsampling 'None' --lcs_ucsc_version '2022-05-08'
```

### the latest UCSC tree version
```
nextflow run update_ucsc_marker.nf -profile singularity --singularity_cache_dir /path/to/your/cache -resume --downsampling 'None' --lcs_ucsc_update
```

## Options

- `lcs_ucsc_version` 
  - set date for the UCSC tree, e.g. '2022-05-01'
  - use 'predefined' to return uncompressed pre-calculated table from this repo [default]
- `lcs_ucsc_predefined`
  - if `--lcs_ucsc_version 'predefined'`, set pre-calculated table date from repo
  - '2022-01-31' [default]
- `lcs_ucsc_update`
  - automatically check for the latest date [default false]
  - if check fails, use `lcs_ucsc_version`
- `downsampling` 
  - downsample samples per variant to 100000 [default]
  - 'None' to turn of
- `variant_groups`
  - path to custom variants group tsv file 
  - 'default' to turn off [default]


## Approximate runtime with default resources

|parameter|time|
|-|-|
|`--downsampling 'None'`  | ~ 1 d 18 h / ~ 3 h *|
|`--downsampling 100000`  | ~ 60 min|
|`--downsampling 10000`   | ~ 8-12 min|
|`--downsampling 1000`    | ~ 2-4 min|


*) with the current Usher version (0.5.4) in the current container, it seems to be really fast