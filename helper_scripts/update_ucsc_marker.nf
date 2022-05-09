nextflow.enable.dsl=2

static boolean hgdownloadIsAvailable() {
    try {
        final URL url = new URL("https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/UShER_SARS-CoV-2/public-latest.version.txt");
        final URLConnection conn = url.openConnection();
        conn.connect();
        conn.getInputStream().close();
        return true;
    } catch (MalformedURLException e) {
        return false;
    } catch (IOException e) {
        return false;
    }
}

def internetcheck = hgdownloadIsAvailable()

if ( params.lcs_ucsc_update ){
    if ( internetcheck.toString() == "true" ) { 
        latest_version = 'https://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/UShER_SARS-CoV-2/public-latest.version.txt'.toURL().text.split('\\(')[1].split('\\)')[0]
        println "\033[0;32mFound latest UCSC version, using: " + latest_version + " \033[0m" 
        params.lcs_ucsc = latest_version
    }
    if ( internetcheck.toString() == "false" ) { 
        println "\033[0;33mCould not find the latest UCSC version, trying: " + params.lcs_ucsc_default + "\033[0m"
        params.lcs_ucsc = params.lcs_ucsc_default
    }
} else { params.lcs_ucsc = params.lcs_ucsc_default}

if (params.variant_groups != 'default') {
    variant_group_ch = Channel.fromPath("$params.variant_groups", checkIfExists: true)
}

process lcs_ucsc_markers_table {
    container 'rkimf1/lcs:1.1.0--24a0909'
    // execution properties
    executor 'slurm'
    cpus 10
    memory '200 GB'
    clusterOptions '--partition=long'
    // output
    publishDir "${params.output_dir}", mode: 'copy'

    input:
    path(variant_group_tsv)

    output:
    path("LCS/outputs/variants_table/ucsc-markers-table-*.tsv")

    script:
    if ( params.lcs_ucsc_update || params.lcs_ucsc_default != 'predefined')
        """
        git clone https://github.com/MarieLataretu/LCS.git
        git rev-parse HEAD

        if [[ "${variant_group_tsv}" != default ]]; then
            rm -rf LCS/data/variant_groups.tsv
            cp ${variant_group_tsv} LCS/data/variant_groups.tsv
        fi

        cd LCS
        # change settings
        sed -i "s/PB_VERSION=.*/PB_VERSION='${params.lcs_ucsc}'/" rules/config.py
        sed -i "s/NUM_SAMPLE=.*/NUM_SAMPLE=${params.downsampling}/" rules/config.py
        mem=\$(echo ${task.memory} | cut -d' ' -f1)
        # run pipeline
        snakemake --cores ${task.cpus} --resources mem_gb=\$mem --config dataset=somestring markers=ucsc -- ucsc_gather_tables
        # --set-threads pool_mutect=${task.cpus}
        # output
        mv outputs/variants_table/ucsc-markers-table.tsv outputs/variants_table/ucsc-markers-table-${params.lcs_ucsc}.tsv 
        """
    else if ( params.lcs_ucsc_default == 'predefined' )
        """
        git clone https://github.com/MarieLataretu/LCS.git
        git rev-parse HEAD
        mkdir -p LCS/outputs/variants_table
        zcat LCS/data/pre-generated-marker-tables/ucsc-markers-${params.lcs_ucsc_predefined}.tsv.gz > LCS/outputs/variants_table/ucsc-markers-table.tsv
        mv LCS/outputs/variants_table/ucsc-markers-table.tsv LCS/outputs/variants_table/ucsc-markers-table-predefined.tsv 
        """
}

workflow {
    // variant_group_ch.view()
    lcs_ucsc_markers_table( params.variant_groups == 'default' ? file('default') : variant_group_ch )
}