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

# #clip the raster by the shapefile
# dem_clip<-dem[clip]
# plot(dem_clip)
# 
# 
# 
# #separating the different creeks because I am not sure how I want to do this
# 
# dem_bear<-dem[filter(clip, crk=="Bear")]
# dem_curtis<-dem[filter(clip, crk=="Curtis")]
# dem_ih<-dem[filter(clip, crk=="Inner Harbour")]
# dem_mb<-dem[filter(clip, crk=="Middle Branch")]
# dem_rock<-dem[filter(clip, crk=="Rock")]
# dem_stoney<-dem[filter(clip, crk=="Stoney")]
# 
# plot(dem_stoney) 

#rm(dem)

#is taking a long time but hasn't crashed the computer yet(Update it worked!)
#I have been clearing the workspace and restarting R in between creeks because
#Of memory, but I am not sure if this will work without it or not.
library(nngeo)

stoney_poly<-filter(clip, crk=="Stoney")
stoney<-raster_extract(x = dem, y = stoney_poly,na.rm = TRUE)
k<-unlist(stoney)
l<- k[k <= 0.75]
saveRDS(l, "stoney_cut.RDS")

rock_poly<-filter(clip, crk=="Rock")
rock<-raster_extract(x= dem, y= rock_poly, na.rm = TRUE)
j<-unlist(rock)
m<-j[j <= 0.75]
saveRDS(m,"rock_cut.RDS")


ih_poly<-filter(clip, crk=="Inner Harbour")
ih<-raster_extract(x= dem, y= ih_poly, na.rm = TRUE)
n<-unlist(ih)
o<-n[n <= 0.75]
saveRDS(o,"ih_cut.RDS")

bear_poly<-filter(clip, crk=="Bear")
bear<-raster_extract(x= dem, y= bear_poly, na.rm = TRUE)
p<-unlist(bear)
r<-p[p <= 0.75]
saveRDS(r,"bear_cut.RDS")

mb_poly<-filter(clip, crk=="Middle Branch")
mb<-raster_extract(x= dem, y= mb_poly, na.rm = TRUE)
s<-unlist(mb)
t<-s[s <= 0.75]
saveRDS(t,"mb_cut.RDS")

curtis_poly<-filter(clip, crk=="Curtis")
curtis<-raster_extract(x= dem, y= curtis_poly, na.rm = TRUE)
u<-unlist(curtis)
v<-u[u <= 0.75]
saveRDS(v,"curtis_cut.RDS")

#####After creating vectors#####
library(dplyr)
library(ggplot2)
#v<-readRDS("stoney_cut.RDS")
#v<-readRDS("ih_cut.RDS")
#v<-readRDS("rock_cut.RDS")
#v<-readRDS("bear_cut.RDS")
v<-readRDS("mb_cut.RDS")
#v<-readRDS("curtis_cut.RDS")

deep<-v[v < -3]
n_deep<-length(deep)/length(v)*100
vol<-sum(-v)

a<-ggplot(mapping = aes(-v))+
  geom_histogram(binwidth=0.5, color="black", fill="gray85")+
  xlab("Depth (m)")+
  ggtitle("Curtis Depths")+
  theme_classic()
a
ggsave("curtis_depth_histo.jpg")

get_hist <- function(p) {
  d <- ggplot_build(p)$data[[1]]
  data.frame(x = d$x, xmin = d$xmin, xmax = d$xmax, y = d$y)
}

table<-get_hist(a)
table<-table %>% 
  mutate(norm_depth=y/length(v)*100)
# b<-ggplot(table)+
#   geom_bar(aes(x=x, y=norm_depth),stat="identity", color="black", fill="gray85")+
#   xlab("Depth (m)")+
#   ggtitle("Stoney Depths")+
#   theme_classic()
# b

table2<-table %>% 
  mutate(crk="Curtis")

norm_hist<-readRDS("norm_hist.RDS")
h_combo<-norm_hist %>% 
  bind_rows(., table2)
saveRDS(h_combo, "norm_hist.RDS")

#####Combo Plot!#####
library(ggplot2)
data<-readRDS("norm_hist.RDS")
a<-ggplot(data=data, aes(x=x, y=norm_depth))+
  geom_bar(stat="identity", color="black", fill="gray85")+
  xlab("Depth (m)")+
  ylab("Percent of Creek Area")+
  ggtitle("Creek Depths as a Percent of Creek Area")+
  theme_classic()+facet_grid(crk~.)
a  
  
  
  
  