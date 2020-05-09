# econ_plot
ideas around fetching and plotting FRED data


`fred_fetch.R` is my attempt to iterate over FRED API and pull data... it currently pulls only cetegories. It fetches no data. Depends on having an environment variable called `FRED_KEY` that contains a FRED API key

`fred_data_download.R` is from @ehbick01 and it pulls everything (I think) but from CSVs which are scheduled to be deprecated. 

