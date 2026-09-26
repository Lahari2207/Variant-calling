# Data and Reference Genome

## Data source

The sequencing data used in this project were obtained from the University of Sheffield's genomics/wrangling tutorial:

https://sbc.shef.ac.uk/wrangling-genomics/aio.html

The tutorial provides example genomic data that can be used for learning and practicing genomics workflows.

For this project, the paired-end sequencing reads from sample `NA12873` were used.

The files are:

```text
NA12873_R1.fastq.gz
NA12873_R2.fastq.gz
```

`R1` and `R2` represent the two reads generated from paired-end sequencing.

The files are intentionally not included in this GitHub repository.

## Reference genome

The workflow uses a chromosome 20 FASTA reference:

```text
chr20.fa
```

Several companion files are required by different tools.

### FASTA index

```text
chr20.fa.fai
```

This is generated using:

```bash
samtools faidx chr20.fa
```

The `.fai` file allows programs such as samtools and GATK to efficiently access specific regions of the FASTA reference.

### GATK sequence dictionary

```text
chr20.dict
```

This is generated using:

```bash
gatk CreateSequenceDictionary \
    -R chr20.fa \
    -O chr20.dict
```

GATK uses the sequence dictionary to store information about the reference contigs.

### BWA-MEM2 index

BWA-MEM2 also requires index files associated with the FASTA reference.

These files have names beginning with:

```text
chr20.fa.
```

The workflow therefore collects the reference files using:

```nextflow
.fromPath("$baseDir/reference/chr20.*")
```

This allows both the FASTA and its required companion files, including `chr20.dict`, to be available to the processes that need them.

## Important

The raw FASTQ files and reference genome are not committed to GitHub.

Instead, this repository documents:

1. where the data came from
2. which files are required
3. how the reference indexes were generated
4. how the pipeline expects the files to be organised
