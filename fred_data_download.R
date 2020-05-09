#source: https://gist.github.com/ehbick01/a2d04e986a0a7ad9676fbeb5f5e74f2b


## Load Packages & Define Theme
library(tidyverse)
library(doParallel)
library(parallel)
library(doSNOW)
library(foreach)
library(lubridate)

# Make function
getEm <- function(x) {
  tryCatch(
    x %>%
      read_csv(col_types = list(col_date(),
                                col_number())) %>%
      mutate(key = x),
    error = function(e)
      NULL
  )
  
}

# Define URLs for zip files
paths <-
  c(
    'https://fred.stlouisfed.org/categories/32991/downloaddata/MBF_csv_2.zip',
    'https://fred.stlouisfed.org/categories/10/downloaddata/EP_csv_2.zip',
    'https://fred.stlouisfed.org/categories/32992/downloaddata/NTLACT_csv_2.zip',
    'https://fred.stlouisfed.org/categories/1/downloaddata/BF_csv_2.zip',
    'https://fred.stlouisfed.org/categories/32455/downloaddata/PRICEINDX_csv_2.zip',
    'https://fred.stlouisfed.org/categories/32263/downloaddata/INTRNTL_csv_2.zip',
    'https://fred.stlouisfed.org/categories/3008/downloaddata/REGION_csv_2.zip'
  )

# Define filenames
fnames <- c(
  'data/MBF_csv_2.zip',
  'data/EP_csv_2.zip',
  'data/NTLACT_csv_2.zip',
  'data/BF_csv_2.zip',
  'data/PRICEINDX_csv_2.zip',
  'data/INTRNTL_csv_2.zip',
  'data/REGION_csv_2.zip'
)

# Download data saving to the current working directory.
cl <- makeCluster(detectCores())

parallel::clusterMap(
  cl,
  download.file,
  url = paths,
  destfile = fnames,
  .scheduling = 'dynamic'
)

stopCluster(cl)

# Build lists of zipped files
business_factors <- unzip('data/BF_csv_2.zip')
population_factors <- unzip('data/EP_csv_2.zip')
# international_factors <- unzip('data/INTRNTL_csv_2.zip')
# financial_factors <- unzip('data/MBF_csv_2.zip')
# national_acct_factors <- unzip('data/NTLACT_csv_2.zip')
# pricing_factors <- unzip('data/PRICEINDX_csv_2.zip')
# regional_factors <- unzip('data/REGION_csv_2.zip')

# Find factors that are within the filepath
all_factors <- list(
  business_factors ,
  population_factors #,
  # international_factors,
  # financial_factors,
  # national_acct_factors,
  # pricing_factors,
  # regional_factors
) %>%
  unlist(recursive = FALSE)

# Count cores and split based on # of cores
cores <- detectCores()
splitAdd <- split(all_factors, ((seq(
  length(all_factors)
) - 1) %/%
  ceiling(length(all_factors) / ceiling(
    length(all_factors) / (ceiling(length(all_factors) / cores))
  ))))

# register cores
cl <- makeCluster(cores)
registerDoSNOW(cl)

econ_alpha <- foreach(
  A = 1:cores,
  # .combine = c,
  # .multicombine = TRUE,
  .verbose = TRUE,
  .packages = c("tidyverse",
                "foreach",
                "doSNOW",
                "iterators")
) %dopar% {
  splitAdd[[A]] %>%
    lapply(., getEm) %>%
    bind_rows() %>%
    spread(key, VALUE)
  
}

stopCluster(cl)