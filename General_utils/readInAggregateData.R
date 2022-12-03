readInAggregateData<-function(path_in,path_out){
  
  # Purpose of this function: This function reads in the country aggregated data from an intermediate file.
  
  if(length(list.files(path_in))==0){
    print(paste0("Please provide intermediate data files here: ",path_in))
    stop()
  }
  
  quiet(f <- list.files(path=path_in,full.names = TRUE) %>% 
    lapply(function(x)read_csv(x,col_types=cols(.default = "c"))) %>% 
    bind_rows%>%
    readr::type_convert()) 
  
  
  # quiet(f <- list.files(path=path_in,full.names = TRUE) %>% 
  #         lapply(read_csv) %>% 
  #         bind_rows) 
  
  write_excel_csv(as.data.frame(f),path_out)
  return(data=f)
}
