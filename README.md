# Rain gauge sequences

Amplicons produced using the earth microbiome project general eukaryote 18S V9 primers. Taxonomic assignment of amplicon sequences was performed against both the PR2 database and the eukaryome 18S database. The eukaryome taxonomic IDs are preferred (see eukaryome paper) but comparison to PR2 may be useful.

In the data folder find the full list of [taxonomic IDs](./data/ASVs_taxonomy_eukrayome.tsv) for each ASV along with RDP [bootstrap values](./data/ASVs_taxonomy_bootstrapVals_eukrayome.tsv) and [sequence counts per ASV per sample](./data/ASVs_counts.tsv).

- taxa_summary.R [sums sequence counts](./data/taxon_summary_table_euakryome.csv) by taxonomic group (through species or lowest available) and calculates [relative abundace](./data/taxon_summary_table_euakryome.rel_abd.csv).
- plot_taxa_sumary.R creates a [plot of class level relative abundance](./figures/class_rel_abd.pdf)
