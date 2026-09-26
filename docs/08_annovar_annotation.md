```markdown
# Variant Annotation with ANNOVAR

Variant calling produces a list of genomic variants, but the raw variant information does not directly describe the biological or clinical context of each variant.

ANNOVAR is used to add functional information to the variants.

## ANNOVAR

ANNOVAR is a variant annotation tool that can compare variants against different gene and population databases.

In this project, ANNOVAR is used for gene-based annotation using the RefGene database.

## humandb

`humandb` is the directory used by ANNOVAR to store downloaded annotation databases.

The databases are not included in this repository because they are external resources and can be large.

## table_annovar.pl

`table_annovar.pl` is used to perform the annotation and combine the results into a convenient output table.

The workflow uses:

-buildver hg38
-protocol refGeneWithVer
-operation g

This means the variants are annotated against the hg38 reference build using the RefGene database with gene-based annotation.

multianno output

ANNOVAR produces files such as:

NA12873.hg38_multianno.txt
NA12873.hg38_multianno.vcf

The multianno file combines the variant information with the annotation results into a single table.

This makes the final variants easier to inspect and analyse.
