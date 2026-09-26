```markdown
# BAM Processing

The aligned BAM file is processed using GATK and samtools.

The workflow performs:

Sorted BAM
    |
    v
 CleanSam
    |
    v
FixMateInformation
    |
    v
MarkDuplicates
    |
    v
Deduplicated BAM

CleanSam is used to clean the SAM/BAM file before downstream processing.

FixMateInformation ensures that paired reads contain consistent mate information.

MarkDuplicates identifies duplicate sequencing reads, commonly produced during PCR amplification.

The duplicates are marked rather than simply deleted.

The process also produces a metrics file containing duplicate statistics.

The final BAM is indexed for downstream variant calling.
