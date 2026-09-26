# Variant-calling
A small WES variant-calling workflow using Nextflow, GATK, BWA-MEM2, samtools, fastp, FastQC, and ANNOVAR.

# TinyWES Variant Calling Pipeline

A small whole-exome sequencing (WES) variant-calling workflow implemented using **Nextflow**.

The pipeline takes paired-end FASTQ files through quality control, adapter and quality trimming, alignment to the reference genome, BAM processing, variant calling, variant filtering, and functional annotation with ANNOVAR.

## Pipeline overview

```text
Paired-end FASTQ
       │
       ▼
    FastQC
       │
       ▼
     fastp
       │
       ▼
   FastQC
       │
       ▼
   BWA-MEM2
       │
       ▼
   Sorted BAM
       │
       ▼
   CleanSam
       │
       ▼
 FixMateInformation
       │
       ▼
 MarkDuplicates
       │
       ▼
 HaplotypeCaller
       │
       ▼
   Raw VCF
       │
       ▼
 VariantFiltration
       │
       ▼
 Filtered VCF
       │
       ▼
    ANNOVAR
       │
       ▼
 Annotated variants
```

## Tools used

| Tool            | Purpose                                       |
| --------------- | --------------------------------------------- |
| Nextflow        | Workflow management and reproducibility       |
| FastQC          | Quality control of sequencing reads           |
| fastp           | Adapter trimming and quality filtering        |
| BWA-MEM2        | Alignment of reads to the reference genome    |
| samtools        | BAM sorting and indexing                      |
| GATK            | BAM processing, variant calling and filtering |
| HaplotypeCaller | Small variant calling                         |
| ANNOVAR         | Functional annotation of variants             |
| Conda           | Software/environment management               |

## Data source

The raw sequencing data and reference material used for this project were obtained from the University of Sheffield genomics/wrangling tutorial:

https://sbc.shef.ac.uk/wrangling-genomics/aio.html

The project uses the sample `NA12873` and a chromosome 20 reference for this small demonstration workflow.

The dataset is intentionally kept small so that the workflow can be tested without requiring a complete whole-genome or whole-exome dataset.

## Why Nextflow?

Nextflow is a workflow management system designed to make computational pipelines reproducible and portable.

Instead of manually running:

```text
FastQC → fastp → BWA → samtools → GATK → ANNOVAR
```

each step is represented as a Nextflow process.

Each process has defined:

* inputs
* outputs
* commands
* software/files it requires

Nextflow connects the output of one process to the input of the next process.

For example:

```text
FASTP
  │
  │ trimmed reads
  ▼
BWA_MEM2
```

This makes the workflow easier to reproduce, modify and scale.

## Project status

This repository is a learning-oriented WES variant-calling pipeline. It is intended to demonstrate the structure and concepts of a bioinformatics workflow rather than serve as a production clinical variant-calling pipeline.
