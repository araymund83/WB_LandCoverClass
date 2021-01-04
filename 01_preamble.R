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

#################################################################################
## Canada Provinces 
#################################################################################
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
#################################################################################
## BCR for Western Boreal
#################################################################################
provs <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba")

terrs <- c("Yukon", "Northwest Territories", "Nunavut")
WB <- c(provs, terrs)

bcrWB <- bcrshp[bcrshp$BCR %in% c(4, 6:8), ]
provsWB <- canProvs[canProvs$NAME_1 %in% WB, ]

studyArea <- reproducible::Cache(postProcess,
                                 provsWB, studyArea= bcrWB, useSAcrs = TRUE,
                                 cacheRepo = cPath, filename2 = NULL, overwrite = TRUE) 

st_write(studyArea, "inputs/studyArea/BCR_WB.shp", driver = "ESRI Shapefile")

#################################################################################
## BCR6 subdivision
#################################################################################
provBCR6 <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", 
              "Northwest Territories")
provs2 <- c("British Columbia", "Alberta")
provs3 <- c("Saskatchewan", "Manitoba")
provs4 <- c("Northwest Territories")

bcr6 <- bcrshp[bcrshp$BCR %in% c(6), ]

provsBCR6 <- canProvs[canProvs$NAME_1 %in% provBCR6, ]
NWT <- canProvs[canProvs$NAME_1 %in% provs4, ]
ABBC <- canProvs[canProvs$NAME_1 %in% provs2, ]
SKMB <- canProvs[canProvs$NAME_1 %in% provs3, ]

bcr6SA <- reproducible::Cache(postProcess,
                              provsBCR6,
                              studyArea = bcr6, 
                              useSAcrs = TRUE,
                              cacheRepo = cPath, 
                              filename2 = NULL, 
                              overwrite = TRUE)
## BCR6 Alberta - British Columbia
bcr6ABBC <- reproducible::Cache(postProcess,
                                bcr6SA, 
                                studyArea = ABBC, 
                                useSAcrs =  TRUE,
                                cacheRepo = cPath,
                                overwrite = TRUE)

## BCR6 North West Territories
bcr6NWT <- reproducible::Cache(postProcess,
                               NWT, 
                               studyArea = bcr6SA, 
                               useSAcrs = TRUE,
                               cacheRepo = cPath, 
                               filename2 = NULL,
                               overwrite = TRUE)
## BCR6 Saskatchewan - Manitoba
bcr6SKMB <- postProcess(SKMB, studyArea = bcr6SA, useSAcrs = TRUE,
                        cacheRepo = cPath, filename2 = NULL,
                        overwrite = TRUE)

## saving shapefiles (only do it once!)
# st_write(bcr6SA, "inputs/studyArea/BCR6/BCR6.shp", driver = "ESRI Shapefile")
# st_write(bcr6ABBC, "inputs/studyArea/BCR6/BCR6_ABBC.shp", driver = "ESRI Shapefile")
# st_write(bcr6SKMB, "inputs/studyArea/BCR6/BCR6_SKMB.shp", driver = "ESRI Shapefile")
# st_write(bcr6NWT, "inputs/studyArea/BCR6/BCR6_NWT.shp", driver = "ESRI Shapefile")


bcr6SA$Province[bcr6SA$NAME_1 == "Alberta"] <- "AB"
bcr6SA$Province[bcr6SA$NAME_1 == "British Columbia"] <- "BC"
bcr6SA$Province[bcr6SA$NAME_1 == "Manitoba"] <- "MB"
bcr6SA$Province[bcr6SA$NAME_1 == "Saskatchewan"] <- "SK"
bcr6SA$Province[bcr6SA$NAME_1 == "Northwest Territories"] <- "NWT"

## this sf object has problems when rasterize, that is why geometry is being h
## homogenize by using st_cast
bcr6SA2 <- st_cast(bcr6SA,"MULTIPOLYGON")


#################################################################################
## LCC 2005
#################################################################################
LCC05 <- reproducible::Cache(prepInputsLCC,year = 2005, 
                             studyArea = studyArea,
                             destinationPath = getPaths()$inputPath)
## crop and mask with BCR6
LCC05_6Ras <- reproducible::Cache(postProcess,
                                  LCC05, 
                                  studyArea = bcr6SA, 
                                  useSAcrs = TRUE)

#################################################################################
## Wetlands
#################################################################################
wetlandzip <- "https://drive.google.com/file/d/1R1AkkD06E-x36cCHWL4U5450mSDu_vD0/view?usp=sharing"
wetlandWB <- Cache(prepInputs,
                url = wetlandzip,
                destinationPath = dPath,
                targetFile = "CA_wetlands_post2000.tif",
                userTags = c("wetlandWB")
                )
wetland6 <-  reproducible::Cache(postProcess,
                                 wetlandWB, 
                                 studyArea = bcr6SA, 
                                 useSAcrs = TRUE)

