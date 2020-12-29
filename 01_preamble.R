
library(magrittr)
library(sf)
library(sp)
library(raster)
library(reproducible)

bcrzip <- "https://www.birdscanada.org/download/gislab/bcr_terrestrial_shape.zip"

cPath <- "inputs/studyArea/cache"
dPath <- "inputs/studyArea/data"
targetCRS <- paste("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95",
                   "+x_0=0 +y_0=0 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
#################################################################################
## BCR regions 
#################################################################################

bcrshp <- Cache(prepInputs,
                url = bcrzip,
                cacheRepo = cPath,
                destinationPath = dPath,
                targetCRS = targetCRS,
                fun = "sf::st_read")


canProvs <- Cache(prepInputs,
                  "GADM",
                  fun = "base::readRDS",
                  dlFun = "raster::getData",
                  country = "CAN", level = 1, path = dPath,
                  #targetCRS = targetCRS, ## TODO: fails on Windows
                  targetFile = "gadm36_CAN_1_sp.rds", ## TODO: this will change as GADM data update
                  cacheRepo = cPath,
                  destinationPath = dPath) %>%
  st_as_sf(.) %>%
  st_transform(., targetCRS)

provs <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba")
provBCR6 <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", 
              "Northwest Territories")
provs2 <- c("British Columbia", "Alberta")
provs3 <- c("Saskatchewan", "Manitoba")
provs4 <- c("Northwest Territories")
terrs <- c("Yukon", "Northwest Territories", "Nunavut")
WB <- c(provs, terrs)

bcrWB <- bcrshp[bcrshp$BCR %in% c(4, 6:8), ]
bcr6 <- bcrshp[bcrshp$BCR %in% c(6), ]
bcrWB2 <- postProcess(bcrWB, studyArea = studyArea, useSAcrs = TRUE)
bcrWB2 <- as_Spatial(bcrWB2)

st_write(bcrWB2, "inputs/studyArea/WB_BCR2.shp", driver = "ESRI Shapefile")
provsWB <- canProvs[canProvs$NAME_1 %in% WB, ]
provsBCR6 <- canProvs[canProvs$NAME_1 %in% provBCR6, ]
NWT <- canProvs[canProvs$NAME_1 %in% provs4, ]
ABBC <- canProvs[canProvs$NAME_1 %in% provs2, ]
SKMB <- canProvs[canProvs$NAME_1 %in% provs3, ]


studyArea <- reproducible::Cache(postProcess,
                   provsWB, studyArea= bcrWB, useSAcrs = TRUE,
                   cacheRepo = cPath, filename2 = NULL, overwrite = TRUE) %>%
# studyArea <- postProcess(provsWB, studyArea = bcrWB, useSAcrs = TRUE, cacheRepo = cPath,
#                          filename2 = NULL, overwrite = TRUE) %>%
  as_Spatial(.)


bcr6SA <- postProcess(provsBCR6, studyArea = bcr6, useSAcrs = TRUE,
                       cacheRepo = cPath, filename2 = NULL, overwrite = TRUE)
bcr6ABBC <- postProcess(bcr6SA, studyArea = ABBC, useSAcrs =  TRUE)
st_write(bcrWB2, "inputs/studyArea/BCR6_ABBC.shp", driver = "ESRI Shapefile")
bcr6ABBC <- postProcess(bcr6SA, studyArea = ABBC, useSAcrs =  TRUE)
st_write(bcr6ABBC, "inputs/studyArea/BCR6_ABBC.shp", driver = "ESRI Shapefile")


bcr6SA$Province[bcr6SA$NAME_1 == "Alberta"] <- "AB"
bcr6SA$Province[bcr6SA$NAME_1 == "British Columbia"] <- "BC"
bcr6SA$Province[bcr6SA$NAME_1 == "Manitoba"] <- "MB"
bcr6SA$Province[bcr6SA$NAME_1 == "Saskatchewan"] <- "SK"
bcr6SA$Province[bcr6SA$NAME_1 == "Northwest Territories"] <- "NWT"

## this sf object has problems with rasterize, that is why geometry is being h
## homogenize by using st_cast
bcr6SA2 <- st_cast(bcr6SA,"MULTIPOLYGON")

bcr6SA$Prov[bcr6SA$Province == "AB"] <- 1
bcr6SA$Prov[bcr6SA$Province == "BC"] <- 2
bcr6SA$Prov[bcr6SA$Province == "MB"] <- 3
bcr6SA$Prov[bcr6SA$Province == "SK"] <- 4
bcr6SA$Prov[bcr6SA$Province == "NWT"] <- 5

as_Spatial(bcr6SA2)
bcr6NWT <- postProcess(NWT, studyArea = bcr6SA, useSAcrs = TRUE,
                              cacheRepo = cPath, filename2 = NULL,
                               overwrite = TRUE)
bcr6ABBC <- postProcess(ABBC, studyArea = bcr6SA, useSAcrs = TRUE,
                              cacheRepo = cPath, filename2 = NULL,
                               overwrite = TRUE)
bcr6SKMB <- postProcess(SKMB, studyArea = bcr6SA, useSAcrs = TRUE,
                              cacheRepo = cPath, filename2 = NULL,
                               overwrite = TRUE)
class(bcr6Split)

plot(studyArea)


st_write(studyArea, "inputs/studyArea/studyAreaWB.shp", driver = "ESRI Shapefile")
st_write(bcr6ABBC, "inputs/studyArea/BCR6_ABBC.shp", driver = "ESRI Shapefile")
st_write(bcr6SKMB, "inputs/studyArea/BCR6_SKMB.shp", driver = "ESRI Shapefile")
st_write(bcr6NWT, "inputs/studyArea/BCR6_NWT.shp", driver = "ESRI Shapefile")


#################################################################################
## LCC 2005
#################################################################################
LCC05 <- reproducible::Cache(prepInputsLCC,year = 2005, 
                             studyArea = studyArea,
                             destinationPath = getPaths()$inputPath)
## crop and mask with studyArea
LCC05_6Ras <- postProcess(LCC05, studyArea = bcr6SA, useSAcrs = TRUE)

  #LCC05Ras[LCC05Ras == 0] <- NA

## convert to categorical values
LCC05Ras <- as.factor(LCC05Ras)
##add a look-up table for the vegetation classes
fpath <- file.path(getwd(),"inputs", "LCC05ClookUp.csv" )
levelRas<- read.csv(file = fpath, header = TRUE, sep = ",")

levels(LCC05Ras) <- levelRas
