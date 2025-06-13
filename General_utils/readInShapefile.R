


readInShapefile<-function(path,tmpName){

  # Purpose of this function: This function reads in the shapefile data and does a bit of manipulate on names.

# shape<- shapefile(path)
# shape <- readOGR(dsn = path,layer= tmpName,use_iconv=TRUE, encoding="UTF-8")
  shape <- sf::st_read(dsn = path, layer = tmpName)
#shape <- readOGR(dsn = path,layer= tmpName)

# adding a row number to the shape2 object, will be handy for plotting later on
# shape@data$row_num<-1:nrow(shape@data)
shape$row_num <- 1:nrow(shape)


# adminName_key<-shape@data[,c("row_num","dot_name")]
# colnames(adminName_key)[colnames(adminName_key)=="dot_name"] <- "state"
adminName_key<-shape[,c("row_num","NAME_1")]
colnames(adminName_key)[colnames(adminName_key)=="NAME_1"] <- "state"

# if(length(shape$dot_name)>1){
#   nb.r <- poly2nb(shape, queen=F)
#   if(sum(card(nb.r))>0){
#     mat <- nb2mat(nb.r, style="B",zero.policy=TRUE)
#   } else{
#     mat <- NA
#   }
# } else{
#   mat <- NA
# }

if(length(shape$NAME_1)>1){
  nb.r <- poly2nb(shape, queen=F)
    if(sum(card(nb.r))>0){
      mat <- nb2mat(nb.r, style="B",zero.policy=TRUE)
    } else{
      mat <- NA
    }
  } else{
    mat <- NA
  }

return(list(shape=shape,adminName_key=adminName_key,mat=mat))

}
