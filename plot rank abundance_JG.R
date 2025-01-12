library(dplyr)
library(tidyr)
library(ggplot2)
source("library/ggplot_theme.txt")

seqASVbyLevels[[2]]

taxon_summary.RA_noMt = read.csv("./data/taxon_summary_table_euakryome.rel_abd_noMt.csv")

head(taxon_summary.RA_noMt)

class_sum.long_noMt = taxon_summary.RA_noMt %>% 
    group_by(Kingdom, Phylum) %>%
    summarize(across(where(is.numeric), sum)) %>%
    pivot_longer(cols = where(is.numeric), names_to = "sample", values_to = "rel_abd")
class_sum.long_noMt$k_p_c1 = paste(class_sum.long_noMt$Kingdom, class_sum.long_noMt$Phylum, sep = "_")

library(stringr)


# Concatenate two columns
class_sum.long_noMt <- class_sum.long_noMt %>%
    mutate(concatenated = paste0(Kingdom, ": ", Phylum, ""))

class_sum.long_noMt$concatenated[ class_sum.long_noMt$concatenated=="NA: NA"] <- "Unknown (No identified hits)"
class_sum.long_noMt$concatenated[ class_sum.long_noMt$concatenated=="Viridiplantae: Tracheophyta"] <- "Viridiplantae: Tracheophyta\n(Vascular plants)"

class_sum.long_noMt$concatenated[ class_sum.long_noMt$concatenated=="Viridiplantae: Chlorophyta"] <- "Viridiplantae: Chlorophyta\n(Green algae)"


class_sum.long_noMt$concatenated
library(JGTools)
source("https://raw.githubusercontent.com/jg44/JGTools/master/lib/loadPackagesFunctions_main.R")

# class_sum.long1 <- class_sum.long1 %>%
#     mutate(concatenated = ifelse(str_detect(concatenated, "Viridiplantae"), 
#                                  "Plants", category))



class_sum.long_noMt = taxon_summary.RA_noMt %>% 
    group_by(Kingdom, Phylum) %>%
    summarize(across(where(is.numeric), sum)) %>%
    pivot_longer(cols = where(is.numeric), names_to = "sample", values_to = "rel_abd")
class_sum.long_noMt$k_p_c1 = paste(class_sum.long_noMt$Kingdom, class_sum.long_noMt$Phylum, sep = "_")


    colsrp <- c("rp_seq_RG620r_S89", "rp_seq_RG627_S90", "rp_seq_all")
    
tmp2 <-     seqASVbyLevels[[2]] %>% 
    group_by(Kingdom, Phylum) %>%
    summarize(across(where(is.numeric), sum)) %>%
    pivot_longer(cols = all_of(colsrp), names_to = "sample", values_to = "rel_abd") %>%
    mutate(concatenated = paste0(Kingdom, ": ", Phylum, ""))

tmp3 <-     seqASVbyLevels[[3]] %>% 
    group_by(Kingdom, Phylum, Class) %>%
    summarize(across(where(is.numeric), sum)) %>%
    pivot_longer(cols = all_of(colsrp), names_to = "sample", values_to = "rel_abd") %>%
    mutate(concatenated = paste0(Kingdom, ": ", Phylum, ": ", Class))



plot_levs2 <- ggplot(
    tmp2, 
    aes(
        x = reorder(concatenated, -rel_abd), 
        y = rel_abd * 100, 
        fill = sample
    )
) +
    geom_col(position = position_dodge()) +
    scale_fill_brewer(
        palette = "Set1", 
        labels = c("RG620" = "RG620", "RG627" = "RG627", "total_count" = "Global rel. abd.")
    ) +
    scale_y_sqrt() +  # Apply square root scaling to the y-axis
    labs(y = "Relative proportion of quality-filtered sequences (axis scaled)") +
    my_gg_theme.def_size +
    theme(
        axis.title.x = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.85, 0.85),
        axis.text.x = element_text(angle = 72.5, hjust = 1)
    )



plot_levs3 <- ggplot(
    tmp3, 
    aes(
        x = reorder(concatenated, -rel_abd), 
        y = rel_abd * 100, 
        fill = sample
    )
) +
    geom_col(position = position_dodge()) +
    scale_fill_brewer(
        palette = "Set1", 
        labels = c("RG620" = "RG620", "RG627" = "RG627", "total_count" = "Global rel. abd.")
    ) +
    scale_y_sqrt() +  # Apply square root scaling to the y-axis
    labs(y = "Relative proportion of quality-filtered sequences (axis scaled)") +
    my_gg_theme.def_size +
    theme(
        axis.title.x = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.85, 0.85),
        axis.text.x = element_text(angle = 72.5, hjust = 1)
    )

x11(10,6)
plot_levs3
.devpdf("rel_abund_kingdomPhyllumClass", overwrite=FALSE)


kable(
    class_sum.long_noMt %>%
        filter(sample=="total_count")
)
