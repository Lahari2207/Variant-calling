```markdown
# Read Trimming

The paired-end reads are processed using fastp.

Input:
```text
NA12873_R1.fastq.gz
NA12873_R2.fastq.gz

Output:
trimmed_R1.fastq.gz
trimmed_R2.fastq.gz

fastp performs read quality control and adapter/low-quality base trimming.

The two reads are processed together because they are paired-end reads.

fastp also produces:

fastp.html
fastp.json

The HTML file provides a visual summary of the trimming results, while the JSON file contains the same information in a machine-readable format.
