# LCS

## 2023.01.30

### `Added`

- new precalculated dataset: `ucsc-markers-2023-01-26.tsv.gz`
    - nextflow run update_ucsc_marker.nf --lcs_ucsc_update -profile singularity --downsampling 80000
    - [variant_groups.tsv](https://github.com/rki-mf1/LCS/blob/4967491a6f91e5ce1f706c9b5ff9e5b1ddae473c/data/variant_groups.tsv)

### `Dependencies`

- updated Docker container to `rkimf1/lcs:1.1.0--607c188`
  - `usher=0.6.2`
  - `snakemake=7.20.0`
