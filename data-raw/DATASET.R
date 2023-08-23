
library(usethis)

# Colors
tn_colors<-read.csv("J:\\SSI\\_Greg\\TNTools\\data-raw\\colors\\tn_colors.csv")
use_data(tn_colors, overwrite = T)


tn_palettes<-list()
for(i in unique(tn_colors$Palette)){
  pcol<-tn_colors$hex[tn_colors$Palette==i]
  names(pcol)<-tn_colors$Name1[tn_colors$Palette==i]
  tn_palettes[[i]]<-pcol
}

use_data(tn_palettes, overwrite = T)

# Logos
#tn_logo_files_full<-list.files("J:\\SSI\\_Greg\\TNTools\\data-raw\\logos\\", full.names=T)
tn_logo_files<-list.files("J:\\SSI\\_Greg\\TNTools\\inst\\logos\\")
tn_logo_name_list<-gsub('\\.png','',tn_logo_files)

#tn_logos<-list()
#for(i in 1:length(tn_logo_files)){
#  message(tn_logo_names[i])
#  tn_logos[[tn_logo_names[i]]]<-image_read(tn_logo_files_full[i])
#}

use_data(tn_logo_name_list, overwrite = T)


# Shapefiles
load('J:\\SSI\\_Greg\\TNTools\\data-raw\\Shapefiles\\county_shapefiles.rdata')
use_data(tn_county_shapefiles, overwrite = T)


# On load (put elsewhere)
options(
  ggplot2.discrete.fill= list(c(tn_palettes[['Official']], tn_palettes[['Secondary']], tn_palettes[['Support1']]))
  ,ggplot2.discrete.colour= list(c(tn_palettes[['Official']], tn_palettes[['Secondary']],tn_palettes[['Support1']]))
)