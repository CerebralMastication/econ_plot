library(fredr)
library(tidyverse)

fredr_set_key(Sys.getenv("FRED_KEY"))

crawl_children <- function(category_ids) {
  # take a vector of categories and fetch children
  
  out <- tibble()
  
  for (category_id in category_ids) {
    print(paste("now fetching id:", category_id))
    children <- fredr_category_children(category_id)
    children %>%
      bind_rows(out) ->
      out
  }
  
  return(out)
}

need_to_crawl <- function(children_df) {
  # return children who need to be crawled
  
  children_df %>%
    select(id) ->
    ids
  
  children_df %>%
    select(parent_id) ->
    parent_ids
  
  ids %>%
    anti_join(parent_ids, by = c("id" = "parent_id")) %>%
    distinct(id) %>%
    pull(id) ->
    needed
  
  return(needed)
}

start_df <- crawl_children(0:6)
out_df <- start_df
new_df <- start_df

loop <- 1

while (nrow(new_df) > 0) {
  print(paste(
    "now on loop:",
    loop,
    "------------------------------------------------" 
  ))
  
  start_df %>%
    need_to_crawl %>%
    crawl_children ->
    new_df
  
  new_df %>%
    bind_rows(out_df) ->
    out_df
  print(paste("we've now pulled this many categories:", nrow(out_df)))
  start_df <- new_df
  
  loop <- loop + 1
}

out_df %>%
  write_csv("out_df_crawl.csv")

out_df %>%
  left_join(out_df, by=c('id'='parent_id')) %>% View
