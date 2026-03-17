### 1 - Load libraries ####
library(dplyr)
library(readr)
library(glue)

### 2 - Define covariates of interest ####

covariate_fields <- c(
  # Demographics
  "participant.eid",         # eid
  "participant.p21022",      # Age
  "participant.p31",         # Sex
  "participant.p21000_i0",   # Ethnicity
  "participant.p22189",      # Townsend Index
  "participant.p20160_i0",   # Ever smoked
  
  # Baseline date
  "participant.p53_i0",     # Baseline date
  
  # Alcohol
  "participant.p20117_i0",   # Alcohol status
  "participant.p1558_i0",    # Alcohol frequency (beer)
  "participant.p1568_i0",    # Alcohol frequency (wine)
  "participant.p1578_i0",    # Alcohol frequency (spirits)
  "participant.p1588_i0",    # Alcohol frequency (fortified)
  "participant.p1598_i0",    # Alcohol frequency (other)
  "participant.p1608_i0",    # Alcohol frequency (total)
  
  # Physical measures
  "participant.p21001_i0",   # BMI
  
  # Blood pressure
  "participant.p4080_i0_a0", # SBP 1
  "participant.p4080_i0_a1", # SBP 2
  "participant.p4079_i0_a0", # DBP 1
  "participant.p4079_i0_a1", # DBP 2
  
  # Lipids
  "participant.p23400_i0",   # Total cholesterol
  "participant.p23405_i0",   # LDL cholesterol
  "participant.p23406_i0",   # HDL cholesterol
  "participant.p23407_i0",   # Triglycerides
  
  # Blood biomarkers
  "participant.p30700_i0",   # Creatinine
  
  # Principal components (PC1–PC10)
  "participant.p22009_a1",
  "participant.p22009_a2",
  "participant.p22009_a3",
  "participant.p22009_a4",
  "participant.p22009_a5",
  "participant.p22009_a6",
  "participant.p22009_a7",
  "participant.p22009_a8",
  "participant.p22009_a9",
  "participant.p22009_a10",
  
  # Proteomics batch variables
  "participant.p30901_i0",   # Proteomics plate ID
  "participant.p30902_i0"    # Proteomics well ID
)


### 3 - Construct field string for CLI ####
field_string <- paste(covariate_fields, collapse = ",")

### 4 - Build and run extract_dataset command ####
dx_cmd <- glue("
dx extract_dataset /Proteomics/proteomics_baseline \\
  --fields \"{field_string}\" \\
  --delimiter '\\t' \\
  --output ~/afib/data/raw/covariates.tsv
")

# Run it
system(dx_cmd)

# View it
covariates <- read_tsv("~/afib/data/raw/covariates.tsv")

### 5 - UPLOAD ####

# Define path and destination
local_file <- path.expand("~/afib/data/raw/covariates.tsv")
remote_folder <- "/Proteomics/"

# Build the command
upload_cmd <- paste(
  "dx upload", shQuote(local_file),
  "--destination", shQuote(remote_folder)
)

# Run it
system(upload_cmd)



### 6 - let's name them ####

rename_map <- c(
  # Demographics
  "participant.eid"         = "eid",
  "participant.p21022"      = "age",
  "participant.p31"         = "sex",
  "participant.p21000_i0"   = "ethnicity",
  "participant.p22189"      = "townsend_index",
  "participant.p20160_i0"   = "ever_smoked",
  
  # Dates
  "participant.p53_i0"         = "baseline_date",
  
  # Alcohol
  "participant.p20117_i0"   = "alcohol_status",
  "participant.p1558_i0"    = "alcohol_freq_beer",
  "participant.p1568_i0"    = "alcohol_freq_wine",
  "participant.p1578_i0"    = "alcohol_freq_spirits",
  "participant.p1588_i0"    = "alcohol_freq_fortified",
  "participant.p1598_i0"    = "alcohol_freq_other",
  "participant.p1608_i0"    = "alcohol_freq_total",
  
  # Physical measures
  "participant.p21001_i0"   = "bmi",
  
  # Blood pressure
  "participant.p4080_i0_a0" = "sbp_1",
  "participant.p4080_i0_a1" = "sbp_2",
  "participant.p4079_i0_a0" = "dbp_1",
  "participant.p4079_i0_a1" = "dbp_2",
  
  # Lipids
  "participant.p23400_i0"   = "total_cholesterol",
  "participant.p23405_i0"   = "ldl_cholesterol",
  "participant.p23406_i0"   = "hdl_cholesterol",
  "participant.p23407_i0"   = "triglycerides",
  
  # Blood biomarkers
  "participant.p30700_i0"   = "creatinine",
  
  # Principal components (genetic ancestry)
  "participant.p22009_a1"   = "PC1",
  "participant.p22009_a2"   = "PC2",
  "participant.p22009_a3"   = "PC3",
  "participant.p22009_a4"   = "PC4",
  "participant.p22009_a5"   = "PC5",
  "participant.p22009_a6"   = "PC6",
  "participant.p22009_a7"   = "PC7",
  "participant.p22009_a8"   = "PC8",
  "participant.p22009_a9"   = "PC9",
  "participant.p22009_a10"  = "PC10",
  
  # Proteomics batch
  "participant.p30901_i0"   = "olink_plate",
  "participant.p30902_i0"   = "olink_well"
)

covariates_named <- covariates %>%
  rename_with(~ rename_map[.x], .cols = names(rename_map))

write_tsv(covariates_named, "~/afib/data/raw/covariates_named.tsv")

local_file <- path.expand("~/afib/data/raw/covariates_named.tsv")
remote_folder <- "/Proteomics/"

# Build the command
upload_cmd <- paste(
  "dx upload", shQuote(local_file),
  "--destination", shQuote(remote_folder)
)

# Run it
system(upload_cmd)

