#do.call(SpaDES.core::setPaths, paths1)

bcrzip <- "https://www.birdscanada.org/download/gislab/bcr_terrestrial_shape.zip"

targetCRS <- paste("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95",
                   "+x_0=0 +y_0=0 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
#################################################################################
## BCR regions 
#################################################################################
bcrshp <- Cache(prepInputs,
                url = bcrzip,
                destinationPath = Paths$inputPath,
                targetCRS = targetCRS,
                fun = "sf::st_read")

#################################################################################
## Canada Provinces 
#################################################################################
canProvs <- Cache(prepInputs,
                  "GADM",
                  fun = "base::readRDS",
                  dlFun = "raster::getData",
                  country = "CAN", level = 1, 
                  #targetCRS = targetCRS, ## TODO: fails on Windows
                  targetFile = "gadm36_CAN_1_sp.rds", ## TODO: this will change as GADM data update
                  destinationPath = Paths$inputPath) %>%
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
                                 destinationPath = Paths$inputPath, filename2 = "WB_studyArea") 
studyArea <- as_Spatial(studyArea)
#st_write(studyArea, "inputs/studyArea/BCR_WB.shp", driver = "ESRI Shapefile")

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
                              destinationPath = Paths$inputPath,
                              filename2 = "bcr6_studyArea")

## in order to be able to rasterize, we need to create a numeric column to ID each of the provinces
## for BCR6
bcr6SA$ID <- as.numeric(as.factor(bcr6SA$NAME_1))

## In addition, this object has problems when rasterize, that is why geometry is being 
## homogenize by using st_cast
bcr6SA <- st_cast(bcr6SA,"MULTIPOLYGON")
bcr6SA <-as_Spatial(bcr6SA)
## BCR6 Alberta - British Columbia
bcr6ABBC <- reproducible::Cache(postProcess,
                                ABBC, 
                                studyArea = ABBC, 
                                useSAcrs =  TRUE,
                                destinationPath = Paths$inputPath)

## BCR6 North West Territories
bcr6NWT <- reproducible::Cache(postProcess,
                               NWT, 
                               studyArea = bcr6SA, 
                               useSAcrs = TRUE,
                               destinationPath = Paths$inputPath)

## BCR6 Saskatchewan - Manitoba
bcr6SKMB <- postProcess(SKMB, studyArea = bcr6SA, 
                        useSAcrs = TRUE,
                        destinationPath = Paths$inputPath)

## saving shapefiles (only do it once!)
# st_write(bcr6SA, "inputs/studyArea/BCR6/BCR6.shp", driver = "ESRI Shapefile")
# st_write(bcr6ABBC, "inputs/studyArea/BCR6/BCR6_ABBC.shp", driver = "ESRI Shapefile")
# st_write(bcr6SKMB, "inputs/studyArea/BCR6/BCR6_SKMB.shp", driver = "ESRI Shapefile")
# st_write(bcr6NWT, "inputs/studyArea/BCR6/BCR6_NWT.shp", driver = "ESRI Shapefile")




#################################################################################
## LCC 2005
#################################################################################
LCC05Ras <- reproducible::Cache(prepInputsLCC,
                                destinationPath = Paths$inputPath,
                                studyArea = studyArea,
                                year = 2005,
                                filename2 = "LCC05_WB")



## crop and mask with BCR6
LCC05_6Ras <- reproducible::Cache(postProcess,
                                  LCC05Ras, 
                                  studyArea = bcr6SA,
                                  destinationPath = Paths$inputPath,
                                  filename2 = "LCC05_BCR6")
bcr6ABBC <- as_Spatial(bcr6ABBC)
LCC05_ABBCRas <- reproducible::Cache(postProcess,
                                  LCC05Ras, 
                                  studyArea = bcr6ABBC,
                                  destinationPath = Paths$inputPath,
                                  filename2 = "LCC05_BCR6")


#################################################################################
## Age
#################################################################################
standAgeMapURL <- paste0(
  "ftp://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
  "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
  "NFI_MODIS250m_2011_kNN_Structure_Stand_Age_v1.tif")

# "http://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
# "canada-forests-attributes_attributs-forests-canada/2001-attributes_attributs-2001/",
# "NFI_MODIS250m_2001_kNN_Structure_Stand_Age_v1.tif")

standAgeMap2011 <- Cache(LandR::prepInputsStandAgeMap,
                             destinationPath = Paths$inputPath,
                             ageURL = standAgeMapURL,
                             agefun = "raster::raster",
                             studyArea = studyAreaLarge,
                             rasterToMatch = rasterToMatchLarge,
                             #maskWithRTM = TRUE,
                             method = "bilinear",
                             useCache = TRUE,
                             datatype = "INT2U",
                             filename2 = "standAgeMap.tif",
                             startTime = 1970
                          )

#################################################################################
## Wetlands
#################################################################################
# wetlandzip <- "https://drive.google.com/file/d/1R1AkkD06E-x36cCHWL4U5450mSDu_vD0/view?usp=sharing"
# wetlandWB <- Cache(prepInputs,
#                 url = wetlandzip,
#                 destinationPath = getPaths()$inputPath,
#                 studyArea = studyArea,
#                 destinationPath = paths1$inputPath,
#                 rasterToMatch = LCC05Ras,
#                 targetFile = "CA_wetlands_post2000.tif",
#                 userTags = c("wetlandWB")
#                 )
# wetland6 <-  reproducible::Cache(postProcess,
#                                  wetlandWB,
#                                  studyArea = bcr6SA, 
#                                  useSAcrs = TRUE)
studyAreaLarge<- studyArea 
rasterToMatchLarge <- LCC05Ras
rstLCC <- LCC05Ras
studyArea <- bcrABBC
rasterToMatch <- LCC05_ABBCRas

flammableMap <- LandR::defineFlammable(LandCoverClassifiedMap = rstLCC,
                                       nonFlammClasses = c(33, 36:39),
                                       mask = rasterToMatchLarge)
biomassMapURL <- paste0(
  "https://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
  "canada-forests-attributes_attributs-forests-canada/2001-attributes_attributs-2001/",
  "NFI_MODIS250m_2001_kNN_Structure_Biomass_TotalLiveAboveGround_v1.tif")

rawbiomassMap2001 <- Cache(prepInputs, 
                               destinationPath = Paths$inputPath,
                               url = biomassMapURL,
                               fun = "raster::raster",
                               studyArea = studyAreaLarge,
                               rasterToMatch = rasterToMatchLarge,
                               maskWithRTM = TRUE,
                               method = "bilinear",
                               datatype = "INT2U",
                               filename2 = "rawBiomassMap01"
                               )

speciesLayers2001 <- Cache(loadkNNSpeciesLayers,
                           dPath = Paths$inputPath,
                           rasterToMatch = rasterToMatchLarge,
                           studyArea = studyAreaLarge,
                           sppEquiv = sppEquivalencies_CA,
                           sppEquivCol = sppEquivCol,
                           filename2 = "speciesLayers2001",
                           url = paste0("https://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                                        "canada-forests-attributes_attributs-forests-canada/",
                                        "2001-attributes_attributs-2001/"))

 vegMap <- Cache(prepInputsLCC,
                 year = 2005,
                 destinationPath = Paths$inputPath,
                 studyArea = studyAreaLarge,
                 rasterToMatch = rasterToMatchLarge,
                 filename2 = "vegMap.tif")
              

firePoints <- Cache(prepInputs,
                    destinationPath = Paths$inputPath,
                    studyArea = studyAreaLarge,
                    rasterToMathc = rasterToMatchLarge,
                    fun = sf::st_read,
                    targetCRS = targetCRS,
                    filename2 = "firePointsWB",
                    url = paste0("http://cwfis.cfs.nrcan.gc.ca/downloads/nfdb/",
                                 "/current_version/NFDB_point.zip")
                    )
                                        
                           
                           
                           
