# Spatial analysis
# Load Packages --------------------------------------------------------------------------------------
library(raster)
library(sp)
library(dismo)
library(maptools)

## Species selection
Name the two selected species. Here I am going to use the species _Bradypus variegatus_ as an example. 
Be aware that not all reptile species have records on GBIF. 

## Occurrence data from gbif

```{r message=FALSE, warning=FALSE}
cuteSleepy<-gbif("Bradypus","variegatus")
```

### Cleaning occurrence

```{r}
# Delete occurrence without geographic information
cuteSleepy<-
  cuteSleepy %>% 
  filter(!is.na(lon)&!is.na(lat))

## Get rid of duplicate occurrences
dups=duplicated(cuteSleepy[, c("lon", "lat")])
cuteSleepy <-cuteSleepy[!dups, ]
```

## Extract climatic variables

```{r}
# using the raster package
bio_ly <- getData("worldclim",var="bio",res=10, path="./data/")

tempRast <- bio_ly$bio1/10
precipRast <- bio_ly$bio12


##Convert Ocurrence data to spatial points 
cuteSleepy_geo<-cuteSleepy
coordinates(cuteSleepy_geo)<-~lon + lat

## Changing projection (tempRast and precipiRast have the same projection)
proj4string(cuteSleepy_geo)<-proj4string(tempRast)


## Extracting Temperature and precipitation

## using the expression 'raster::extract' make sure that the function that I am calling is from the raster package. Extract as a function is also found in the tidyr package.

cuteSleepy$temp<-raster::extract(tempRast,cuteSleepy_geo)
cuteSleepy$precip<-raster::extract(precipRast,cuteSleepy_geo)
```


## Plot species occurrences


## Plotting climatic variable and coordinates
new_map<-crop(tempRast,extent(cuteSleepy_geo))

plot(new_map)
points(cuteSleepy_geo,pch=20,col=alpha("blue",0.5))


## Species climatic distribution


hist(cuteSleepy$temp)

cuteSleepy %>% 
  ggplot(aes(precip)) +
  geom_density(color="darkblue", fill="lightblue")

