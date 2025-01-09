library(dplyr)
library(tidyr)
library(ggplot2)
source("library/ggplot_theme.txt")

taxon_summary.RA = read.csv("data/taxon_summary_table_euakryome.rel_abd.csv")

head(taxon_summary.RA)

class_sum.long = taxon_summary.RA %>% 
    group_by(Kingdom, Phylum, Class) %>%
    summarize(across(where(is.numeric), sum)) %>%
    pivot_longer(cols = where(is.numeric), names_to = "sample", values_to = "rel_abd")
class_sum.long$k_p_c = paste(class_sum.long$Kingdom, class_sum.long$Phylum, class_sum.long$Class, sep = "_")
    
p1 = ggplot(class_sum.long, 
    aes(
        x = reorder(paste(Kingdom, Phylum, Class, sep = "_"), rel_abd), 
        y = rel_abd*100, 
        fill = sample
    )
) +
    geom_col(position = position_dodge()) +
    scale_fill_brewer(
        palette = "Set1", 
        labels = c("RG620" = "RG620", "RG627" = "RG627", "total_count" = "Global rel. abd.")
    ) +
    labs(y = "Relative abundance (%)") +
    my_gg_theme.def_size +
    theme(
        axis.title.x = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.15,0.85),
        axis.text.x = element_text(angle = 72.5, hjust = 1)
    )
p1    

pdf("figures/class_rel_abd.pdf", width = 10, height = 7)    
p1
dev.off()
