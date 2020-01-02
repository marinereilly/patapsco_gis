library(stars)
library(dplyr)
#library(ggplot2)
# You need the not CRAN version of stars because the st_mosaic feature doesn't work
#in the CRAN version as of Dec 12, 2019

# These are from the USGS CoNED database and can be downloaded from the earth explorer
#tool.  They are Topobathys in the NAVD 88 Vertical Datum.  From the Baltimore
#Tidal Station NAVD88 is equal to MSL so -Elevation can be considered Depth

#List of Files to Upload
q = c("M://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_137.TIF",
      "M://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_138.TIF",
       "M://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_149.TIF",
       "M://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_150.TIF")

#st_mosaic is essentially the same as "Mosaic to Raster" in ArcGIS
#using the proxy=TRUE command means it loads the Metadata for the files
#but not the actual data so a 2GB raster (of which there are 4), doesn't
#fully load and everything runs faster!

dem<-read_stars(st_mosaic(q), proxy=TRUE)

plot(dem)

#load the shapefile from the geodatabase (.gdb)

clip<-st_read("M://patapsco_fm.gdb", layer="patapsco")

area<-clip %>% 
  group_by(crk) %>% 
  st_area()

#clip the raster by the shapefile
dem_clip<-dem[clip]
plot(dem_clip)



#separating the different creeks because I am not sure how I want to do this

dem_bear<-dem[filter(clip, crk=="Bear")]
dem_curtis<-dem[filter(clip, crk=="Curtis")]
dem_ih<-dem[filter(clip, crk=="Inner Harbour")]
dem_mb<-dem[filter(clip, crk=="Middle Branch")]
dem_rock<-dem[filter(clip, crk=="Rock")]
dem_stoney<-dem[filter(clip, crk=="Stoney")]

plot(dem_stoney) 

#rm(dem)

#is taking a long time but hasn't crashed the computer yet(Update it worked!)
stoney_poly<-filter(clip, crk=="Stoney")

library(nngeo)
stoney<-raster_extract(x = dem, y = stoney_poly,na.rm = TRUE)
stoney<-stoney<=0.75

k<-unlist(stoney)
l<- k[k <= 0.75]



saveRDS(l, "stoney_cut.RDS")





#The code below makes a true/false raster
stoney_3<-dem_stoney>=(-3)
plot(stoney_3)

# DON'T RUN THIS. IT TAKES SO MUCH MEMORY
# a<-ggplot()+
#   geom_stars(data=dem_clip)+
#   theme_stars()
# a
