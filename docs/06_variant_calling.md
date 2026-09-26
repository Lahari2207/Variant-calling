```markdown
# Variant Calling

GATK HaplotypeCaller is used to identify germline variants from the processed BAM file.

Input:
Deduplicated BAM
+
Reference genome

Output:
NA12873.raw.vcf.gz

HaplotypeCaller identifies candidate variants such as:

SNPs
small insertions
small deletions

The output is stored in VCF (Variant Call Format).

A VCF records information such as the genomic position, reference allele, alternate allele and variant-related quality metrics.

The VCF is compressed and indexed for efficient access.
