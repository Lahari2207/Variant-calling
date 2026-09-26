```markdown
# Read Alignment

The trimmed reads are aligned to the chromosome 20 reference using BWA-MEM2.

Trimmed R1 + R2
       |
       v
   BWA-MEM2
       |
       v
    SAM/BAM
       |
       v
  samtools sort
       |
       v
  Sorted BAM

BWA-MEM2 identifies where sequencing reads align to the reference genome.

The resulting BAM file is coordinate-sorted and indexed so that downstream tools can efficiently access aligned reads.

Read-group information is also added during alignment because it is required by downstream GATK analysis.
