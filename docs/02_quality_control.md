```markdown
# Quality Control

FastQC is used to assess the quality of the sequencing reads.

FastQC is run twice:

```text
Raw FASTQ
   |
   v
 FastQC
   |
   v
 fastp
   |
   v
Trimmed FASTQ
   |
   v
 FastQC

The first FastQC run assesses the original reads.

The second FastQC run checks the reads after trimming and filtering.

FastQC reports include information such as:

per-base sequence quality
GC content
sequence duplication
adapter contamination
overrepresented sequences
