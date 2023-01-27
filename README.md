This fork contains the following changes:
- downsampling functionality for UCSC marker table generation
- an updated variant group table

# LCS

Lineage deComposition for Sars-cov-2 pooled samples.

Supporting material for the paper ["A mixture model for determining SARS-Cov-2 variant composition in pooled samples"](https://doi.org/10.1093/bioinformatics/btac047).

# Running the pipeline

The pipeline was written with snakemake: https://snakemake.readthedocs.io/en/stable/.

To get started, clone this repository and use it as a template:

```bash
git clone https://github.com/rvalieris/LCS.git
cd LCS
```

## 1. Create the conda environment

All the software used on the pipeline can be installed with conda.

If you don't already have conda installed in your machine, you can follow [this guide for instalation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) according to your operational system.

On **Linux**, you can execute the command below to create an environment, install all dependencies to run LCS and activate the new environment:


```bash
conda env create -n lcs -f conda.env.yaml
conda activate lcs
```

On **MacOS**, you can use another environment file to install all required dependencies:

```bash
conda env create -n lcs -f conda.env.macosx.yaml
conda activate lcs
```

> We have successfully tested LCS on a MacOS version 11.5.2 with python 3.8 and ray 1.9.0.

## 2. Markers source choice

The markers table contains the list of all mutation markers found in each of the variant-groups
defined in `data/variant-groups.tsv`.

You can either generate a new table or use a pre-generated one.

> **You will need to generate a new table if you want to change the variant-groups definition.**


Choose one of these 3 options:

1. **Use a pre-generated table**:

    Pre-generated tables are provided to shorten the time required to run the pipeline, simply
    choose which table you want to use and copy it to the appropriate place:

    1. pango-designation:
        ```bash
        mkdir -p outputs/variants_table &&
        zcat data/pre-generated-marker-tables/pango-designation-markers-v1.2.60.tsv.gz > outputs/variants_table/pango-markers-table.tsv
        ```
    2. ucsc:
        ```bash
        mkdir -p outputs/variants_table &&
        zcat data/pre-generated-marker-tables/ucsc-markers-2021-08-19.tsv.gz > outputs/variants_table/ucsc-markers-table.tsv
        ```


2. **Generate a new table using [pango-designation](https://github.com/cov-lineages/pango-designation) as a source**:

    To do this you need to have a fasta file in `data/gisaid.fa.gz` containing all GISAID genomes
    listed in the `lineages.csv` file from pango-designation [repository](https://github.com/cov-lineages/pango-designation).

    You must register on the [GISAID](https://www.gisaid.org/) website to gain access to these sequences.

    The variable `PANGO_DESIGNATIONS_VERSION` on `rules/config.py` controls which version of pango-designation to use.

    You can run `snakemake --config markers=pango dataset=x -j1 repo` to download the appropriate pango-designation repository to `data/pango-designation`.

3. **Generate a new table using [sequences tree generated by UCSC](https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/UShER_SARS-CoV-2/) as a source**:

    This data, gathered by the [UShER](https://github.com/yatisht/usher) team, includes only public sequences, as such they are downloaded by the pipeline automatically.
    
    These data trees are updated daily, the variable `PB_VERSION` on `rules/config.py` controls which version of UCSC data to use, make sure to change it to use the most recent data,
    the download of the data is done automatically by the pipeline so no intermediary step is needed.

## 3. Prepare your pooled sample dataset

Place your raw-fastq files pooled samples in `data/fastq`, and create a tags file listing your samples name. 
It should look like this:

```bash
$ ls data/fastq/
sample1_1.fastq.gz
sample1_2.fastq.gz
sample2_1.fastq.gz
sample2_2.fastq.gz
sample3_1.fastq.gz
sample3_2.fastq.gz

$ cat data/tags_pool_mypool
sample1
sample2
sample3
```

If your sequencing data is amplicon, create a fasta file of the primers used and set the variable `PRIMERS_FA`, on `rules/config.py`,
the primers will be trimmed from the sequences if you set the `primer_trimming=True` option.



## 4. Run the pipeline

To execute the pipeline run the command:

```bash
snakemake --config markers=pango dataset=mypool --cores <C> --resources mem_gb=<M>
```

The `markers` config indicates which markers table you are using (*pango* or *ucsc*) and the `dataset` config should match your tags file `data/tags_pool_mypool` describing your samples.

You also need to indicate how many cores and memory you have available to run the analysis, snakemake will parallelize the pipeline accordingly.

If you want to trim primers, also set the option `primer_trimming=True`.

## 5. View the results

After the pipeline completes, the results should be in `outputs/decompose`.

### Generate plots

Plots can be generated by running the notebook:
- [results.ipynb](notebooks/results.ipynb)

# Citing

If you use this software please consider citing:

```
@article{10.1093/bioinformatics/btac047,
    author = {Valieris, Renan and Drummond, Rodrigo D and Defelicibus, Alexandre and Dias-Neto, Emmanuel and Rosales, Rafael A and Tojal da Silva, Israel},
    title = "{A mixture model for determining SARS-Cov-2 variant composition in pooled samples}",
    journal = {Bioinformatics},
    year = {2022},
    month = {02},
    issn = {1367-4803},
    doi = {10.1093/bioinformatics/btac047},
    url = {https://doi.org/10.1093/bioinformatics/btac047},
    note = {btac047},
    eprint = {https://academic.oup.com/bioinformatics/advance-article-pdf/doi/10.1093/bioinformatics/btac047/42357424/btac047.pdf},
}
```
