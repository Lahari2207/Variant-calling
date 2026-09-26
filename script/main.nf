nextflow.enable.dsl=2

params.r1 = "$baseDir/data/NA12873_R1.fastq.gz"
params.r2 = "$baseDir/data/NA12873_R2.fastq.gz"
params.ref = "$baseDir/reference/chr20.fa"

process FASTQC_RAW {

    tag "Raw FASTQ QC"

    publishDir "$baseDir/results/fastqc/raw", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

    script:
    """
    fastqc \
        -t 2 \
        ${r1} \
        ${r2}
    """
}


process FASTP {

    tag "Adapter and quality trimming"

    publishDir "$baseDir/results/trimmed", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id), path("trimmed_R1.fastq.gz"), path("trimmed_R2.fastq.gz"), emit: trimmed_reads
    path "fastp.html"
    path "fastp.json"

    script:
    """
    fastp \
        -i ${r1} \
        -I ${r2} \
        -o trimmed_R1.fastq.gz \
        -O trimmed_R2.fastq.gz \
        --html fastp.html \
        --json fastp.json \
        --thread 2
    """
}


process FASTQC_TRIMMED {

    tag "Trimmed FASTQ QC"

    publishDir "$baseDir/results/fastqc/trimmed", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

    script:
    """
    fastqc \
        -t 2 \
        ${r1} \
        ${r2}
    """
}

process BWA_MEM2 {

    tag "BWA-MEM2 alignment: ${sample_id}"

    publishDir "$baseDir/results/alignment", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)
    path reference_files

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam"), path("${sample_id}.sorted.bam.bai")

    script:
    """
    bwa-mem2 mem \
        -t 2 \
        -R '@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA' \
        chr20.fa \
        ${r1} \
        ${r2} \
    | samtools sort \
        -@ 2 \
        -o ${sample_id}.sorted.bam

    samtools index ${sample_id}.sorted.bam
    """
}

process CLEANSAM {
    tag "CleanSam: ${sample_id}"

    publishDir "$baseDir/results/bam", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.clean.bam"), path("${sample_id}.clean.bam.bai")

    script:
    """
    gatk CleanSam \
        -I ${bam} \
        -O ${sample_id}.clean.bam

    samtools index ${sample_id}.clean.bam
    """
}

process FIXMATE {
    tag "FixMate: ${sample_id}"

    publishDir "$baseDir/results/bam", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.fixmate.bam"), path("${sample_id}.fixmate.bam.bai")

    script:
    """
    gatk FixMateInformation \
        -I ${bam} \
        -O ${sample_id}.fixmate.bam

    samtools index ${sample_id}.fixmate.bam
    """
}

process MARKDUP {
    tag "MarkDuplicates: ${sample_id}"

    publishDir "$baseDir/results/bam", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.dedup.bam"), path("${sample_id}.dedup.bai"),emit:dedup_bam
    path "${sample_id}.dedup.metrics.txt",emit:metrics

    script:
    """
    gatk MarkDuplicates \
        -I ${bam} \
        -O ${sample_id}.dedup.bam \
        -M ${sample_id}.dedup.metrics.txt \
        --CREATE_INDEX true
    """
}

process HAPLOTYPECALLER {
    tag "HaplotypeCaller: ${sample_id}"

    publishDir "$baseDir/results/vcf", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)
    path reference_files

    output:
    tuple val(sample_id), path("${sample_id}.raw.vcf.gz"), path("${sample_id}.raw.vcf.gz.tbi")

    script:
    """
    gatk HaplotypeCaller \
        -R chr20.fa \
        -I ${bam} \
        -O ${sample_id}.raw.vcf.gz
    """
}

process HARD_FILTER {
    tag "Hard filtering: ${sample_id}"

    publishDir "$baseDir/results/filtered_vcf", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(tbi)

    output:
    tuple val(sample_id), path("${sample_id}.filtered.vcf.gz"), path("${sample_id}.filtered.vcf.gz.tbi")

    script:
    """
    gatk VariantFiltration \
        -V ${vcf} \
        -filter-name "SNP_QD2" \
        -filter-expression "vc.getType().equals('SNP') && QD < 2.0" \
        -filter-name "SNP_FS60" \
        -filter-expression "vc.getType().equals('SNP') && FS > 60.0" \
        -filter-name "SNP_MQ40" \
        -filter-expression "vc.getType().equals('SNP') && MQ < 40.0" \
        -filter-name "SNP_MQRankSum" \
        -filter-expression "vc.getType().equals('SNP') && MQRankSum < -12.5" \
        -filter-name "SNP_ReadPosRankSum" \
        -filter-expression "vc.getType().equals('SNP') && ReadPosRankSum < -8.0" \
        -filter-name "INDEL_QD2" \
        -filter-expression "vc.getType().equals('INDEL') && QD < 2.0" \
        -filter-name "INDEL_FS200" \
        -filter-expression "vc.getType().equals('INDEL') && FS > 200.0" \
        -filter-name "INDEL_ReadPosRankSum" \
        -filter-expression "vc.getType().equals('INDEL') && ReadPosRankSum < -20.0" \
        -O ${sample_id}.filtered.vcf.gz

    tabix -f -p vcf ${sample_id}.filtered.vcf.gz
    """
}

process ANNOVAR {
    tag "ANNOVAR annotation: ${sample_id}"

    publishDir "$baseDir/results/annovar", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(tbi)

    path annovar_db

    output:
    path "${sample_id}.hg38_multianno.txt"
    path "${sample_id}.hg38_multianno.vcf"

    script:
    """
    perl ${annovar_db}/table_annovar.pl \
        ${vcf} \
        ${annovar_db}/humandb/ \
        -buildver hg38 \
        -out ${sample_id} \
        -protocol refGeneWithVer \
        -operation g \
        -nastring . \
        -vcfinput \
        -polish
    """
}
workflow {

    reads = Channel.of(
        tuple(
            'NA12873',
            file(params.r1),
            file(params.r2)
        )
    )

    raw_qc = FASTQC_RAW(reads)

    trimmed = FASTP(reads)

    FASTQC_TRIMMED(trimmed.trimmed_reads)

    reference_files = Channel
        .fromPath("$baseDir/reference/chr20.*")
        .collect()

    aligned = BWA_MEM2(
        trimmed.trimmed_reads,
        reference_files
    )

    cleaned = CLEANSAM(aligned)

    fixmated = FIXMATE(cleaned)

    dedup = MARKDUP(fixmated)

    raw_vcf = HAPLOTYPECALLER(
        dedup.dedup_bam,
        reference_files
    )
    filtered_vcf = HARD_FILTER(raw_vcf)
    annovar_db = file("$baseDir/../annovar")
    annotated = ANNOVAR(filtered_vcf,annovar_db)
}
