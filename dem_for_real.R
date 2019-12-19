library(stars)
library(dplyr)
# You need the not CRAN version of stars because the st_mosaic feature doesn't work
#in the CRAN version as of Dec 12, 2019

# These are from the USGS CoNED database and can be downloaded from the earth explorer
#tool.  They are Topobathys in the NAVD 88 Vertical Datum.  From the Baltimore
#Tidal Station NAVD88 is equal to MSL so -Elevation can be considered Depth

#List of Files to Upload
q = c("F://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_137.TIF",
      "F://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_138.TIF",
       "F://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_149.TIF",
       "F://USGS CoNED Topobathy/Chesapeake_Topobathy_DEM_v1_150.TIF")

#st_mosaic is essentially the same as "Mosaic to Raster" in ArcGIS
#using the proxy=TRUE command means it loads the Metadata for the files
#but not the actual data so a 2GB raster (of which there are 4), doesn't
#fully load and everything runs faster!

dem<-read_stars(st_mosaic(q), proxy=TRUE)

plot(dem)

#load the shapefile from the geodatabase (.gdb)

clip<-st_read("F://patapsco_fm.gdb", layer="patapsco")

#clip the raster by the shapefile
dem_clip<-dem[clip]
plot(dem_clip)

