#load proteomics data

library(readr)
library(dplyr)
library(impute)
library(stringr)

olink_df <- read_tsv("/mnt/project/Proteomics/olink_npx_full.tsv")

prot_df <- olink_df

#drop proteins with >10% missingness
prot_df_clean <- prot_df %>%
  select(olink_instance_0.eid, where(~ mean(is.na(.)) <= 0.10))

dim(prot_df_clean)

#drop individlas with >10% missingness
prot_df_clean <- prot_df_clean %>%
  filter(rowMeans(is.na(select(., -olink_instance_0.eid))) <= 0.10)

dim(prot_df_clean)


# Let's impute missing values

# Save ID column
eid_col <- prot_df_clean$olink_instance_0.eid

# Run imputation
imputed_mat <- impute.knn(as.matrix(prot_df_clean[,-1]), 
                          rowmax = 0.1, colmax = 0.1, k = 10, rng.seed = 1)$data

# Combine with eid
prot_df_imputed <- cbind(eid = eid_col, as.data.frame(imputed_mat))

# SCale all protein columns
prot_df_scaled <- prot_df_imputed
prot_df_scaled[,-1] <- scale(prot_df_scaled[,-1])

# rename stuff!
prot_df_scaled <- prot_df_scaled %>%
  rename_with(~ str_remove(., "^olink_instance_0\\."), .cols = -eid)


#save
write_tsv(prot_df_clean, "olink_npx_clean.tsv", na = "NA")
write_tsv(prot_df_scaled, "olink_npx_clean_imputed.tsv", na = "NA")


# Upload to RAP Proteomics folder
system("dx upload olink_npx_clean.tsv --destination /Proteomics/")
system("dx upload olink_npx_clean_imputed.tsv --destination /Proteomics/")
