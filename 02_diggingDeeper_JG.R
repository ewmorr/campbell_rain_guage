# This code does many of the same things as taxa_summary.R but adds a few elements 

# asv_tab.tax is inherited from taxa_summary.R (code copied below)

taxonomy$ASV = rownames(taxonomy)
asv_tab = read.table("data/ASVs_counts.tsv", header = T)
asv_tab$ASV = rownames(asv_tab)
asv_tab.tax = left_join(taxonomy, asv_tab, by = "ASV")

# remove mt sequences (filter function also removes NA's 
# in this step, which is fine, though unexpected)
# aslo sums sequences by row
asv_nmt <- asv_tab.tax %>%
    filter(Kingdom !="Mitochondrion") %>%
    mutate(sumSeq = RG620_S89 + RG627_S90)


# asv relative sequence abundance
asvRSA <- asv_nmt %>%
    mutate(across(where(is.numeric), ~ .x / sum(.x)))

# set taxonomic levels
taxonomic_levels <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

# Get the first column index with NA to set max resolution
maxResol <- apply(asvRSA, 1, function(row) {
    which(is.na(row))[1]  
})

# No NA's when species is IDed. Reduce by one to correct to highest non-NA
maxResol[is.na(maxResol)] <- 8
asvRSA$maxResol <- maxResol-1
names(asvRSA)


# for the map function
library(purrr)

# creates a list where the drill-down goes to each successive taxonomic resolution.
seqCountbyLevels <- map(seq_along(taxonomic_levels), ~ {
    asvRSA %>%
        group_by(across(all_of(taxonomic_levels[1:.x]))) %>%
        summarize(sumSeq = sum(sumSeq), asv_count = n(), maxResolution=max(maxResol), .groups = "keep")
})

# calculate relative proportions
asvRSA_rp <- asvRSA %>%
    mutate(across(all_of(c("sumSeq", "RG620_S89", "RG627_S90")), ~ .x / sum(.x),.names = "relprop_{.col}"))

seqCountbyLevels_all <- map(seq_along(taxonomic_levels), ~ {
    asvRSA_rp %>%
        group_by(across(all_of(taxonomic_levels[1:.x]))) %>%
        summarize(
            rp_seq_all = sum(relprop_sumSeq),      
            rp_seq_RG620r_S89 = sum(relprop_RG620_S89),
            rp_seq_RG627_S90 = sum(relprop_RG627_S90),
            seq_all = sum(sumSeq),      
            seq_RG620r_S89 = sum(RG620_S89),
            seq_RG627_S90 = sum(RG627_S90),
            maxResolution = max(maxResol),
            asv_count_all = n(),
            asv_count_RG620_S89_gt_0 = sum(relprop_RG620_S89 > 0),
            asv_count_RG627_S90_gt_0 = sum(relprop_RG627_S90 > 0),
            .groups = "keep" 
        )
})

asvRSA_rp$RG620_S89



names(seqCountbyLevels_all) <- taxonomic_levels
 

# Remove NA's for better output
seqASVbyLevels <- lapply(seqCountbyLevels_all, function(x) {
    x[is.na(x)] <- ""  # Replace "NA" with NA
    x
})

# Add text version of max resolution
seqASVbyLevels <- map(seqASVbyLevels, ~ .x %>%
        mutate(maxResol_txt = taxonomic_levels[maxResolution]))


# send each resoluation level to .csv files in the data folder sequence and ASV counts by ... csv
for (i in 1:length(taxonomic_levels)) {
    write.csv(seqASVbyLevels[[i]][order(seqASVbyLevels[[i]]$seq_all, decreasing=TRUE),], 
              file=paste0("./data/sequence and ASV counts by ", taxonomic_levels[i], ".csv"),
              row.names = FALSE)
}

# Send to keep.Notes.md
# I dunno why but this code wouldn't work in a loop, so I ran it manually (seven times)
    # additional functions needed here    
    # either way, keep.Notes.md has all these drill downs
i=0
i<-1+i
    tmp <- seqASVbyLevels[[i]][order(seqASVbyLevels[[i]]$rp_seq_all, decreasing=TRUE),]
    .s1(paste0("## ", taxonomic_levels[i], "\n\n"))
    .knit()
    kable(tmp)
    .sa()
    
# 
