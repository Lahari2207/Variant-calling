```markdown
# Variant Filtering

Variants produced by HaplotypeCaller are filtered using GATK VariantFiltration.

The workflow applies different filtering criteria to SNPs and indels.

Examples include:
QD
FS
MQ
MQRankSum
ReadPosRankSum

These metrics provide information about the quality and characteristics of the variant evidence.

Variants that fail a filter are marked in the VCF.

The filtered VCF is then used for downstream annotation.
