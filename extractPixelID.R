library(SpaDES.core)
library(SpaDES.tools)
library("fasterize")
library('data.table')
#biomassMaps2011MB<- loadSimList("/home/araymundo/GITHUB/WB_LandCoverClass/inputs/biomassMaps2011_MB.qs")
biomassMaps2011MB<- qs::qread(file.path(getwd(),"inputs", "biomassMaps2011_MB.qs"))
##extract pixel  id numbers that only intersect with the studyArea.
studyArea <- simOutPreamble$studyAreaReporting
pixelGroupMap <- biomassMaps2011MB$pixelGroupMap

#for some reason cohortData loads as a list, so it needs to be reconverted
cohortData <- as.data.table(biomassMaps2011MB$cohortData)


bcrMBpixels<- raster::extract(pixelGroupMap,
                              studyArea,
                              cellnumbers = TRUE, df = TRUE)

##assign the BCR number to the ID
bcrMBpixels$ID <- as.factor(bcrMBpixels$ID)
studyArea$BCR <- as.factor(studyArea$BCR)
levels(bcrMBpixels$ID) <- levels(studyArea$BCR)
unique(pixelCohortData2)
## rename columns for easier reference
names(bcrMBpixels) <- c ("bcrID", "pixelID", "pixelGroup")



#pixelCohortData <- LandR::addPixels2CohortData(cohortData,
 #                                              biomassMaps2011MB$pixelGroupMap,
  #                                             doAssertion = getOption("LandR.assertions", TRUE))
pixelCohortData2 <- LandR::addNoPixel2CohortData(cohortData,
                                               pixelGroupMap,
                                               doAssertion = getOption("LandR.assertions", TRUE))

##merge both DT to have the BCR id in the cohortData
#bcrpixelCohortData<- merge(pixelCohortData, bcrMBpixels, by = "pixelGroup")
bcrCohortData<- merge(pixelCohortData2, bcrMBpixels, by = "pixelGroup")

## Add vegetation type column to the bcr cohortData table
vegTypeTable <- LandR::vegTypeGenerator(bcrCohortData, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = simOutPreamble$sppEquiv,
                                        sppEquivCol = simOutPreamble$sppEquivCol, pixelGroupColName = "pixelGroup")


## subset the pixelCohortData and create a new column with the sum of Biomass(B) & relB
## per pixelGroup and RelB per pixelGroup & speciesCode
vegTypeTable[, sumB := sum(B), by = .(pixelGroup)]
vegTypeTable[, relB := sum(B)/sumB, by = .(pixelGroup, speciesCode)]
vegTypeTable[is.na(relB) & sumB == 0, relB := 0]

## check for missing values in B
if (any(is.na(vegTypeTable$relB))) {
  stop("Missing values in relative Biomass")
}

## subset to a smaller DT
vegTypes <- unique(vegTypeTable[B > 0, .(pixelGroup,leading, speciesCode, bcrID,relB, sumB)])

DT <- data.table::copy(vegTypes)
data.table::setkeyv(DT, cols = "pixelGroup")

##subset cohortData
bcrSelect <- 6
subsetVegTypes<- vegTypes[vegTypes$bcrID %in% bcrSelect, ]


bcr6MB <- studyArea[studyArea$BCR %in% c(6), ]
subsetpixelGroupMapRas <- crop(pixelGroupMap, bcr6MB)
bcrPixelGroupRas <- mask(subsetpixelGroupMapRas, mask = bcr6MB)


sumB_ras <- raster(pixelGroupMap)
sumB_ras[bcrPixelGroupDt_Biomass$pixelIndex] <- bcrPixelGroupDT_Biomass$sumB


names()
##subset pixelGroupMap
subsetpixelGroupMap<- bcrCohortData[bcrCohortData$bcrID %in% bcrSelect, ]
subsetvegTypeTable<- vegTypeTable[vegTypeTable$bcrID %in% bcrSelect, ]


#for some reason cohortData loads as a list, so it needs to be reconverted
cohortData <- as.data.table(biomassMaps2011MB$cohortData)
bcrSApixels <- bcrMBpixels[bcrMBpixels$bcrID == unique(bcrMBpixels$bcrID), ]


# tempRas <- copy(biomassMaps2011MB$pixelGroupMap)
#tempRas[!tempRas[] %in% subsetvegTypeMap$pixelID] <- NA



cohortDataShort <- pixelCohortData[pixelCohortData$pixelGroup %in% bcrSApixels$pixelGroupMap]
all(cohortDataShort$pixelGroup %in% cohortData$pixelGroup)
all(cohortDataShort$pixelGroup %in% pixelCohortData$pixelGroup)
all(bcrMBpixels$pixelID %in% pixelCohortData$pixelIndex)
all(bcrCohortData$pixelGroup %in% bcrMBpixels$pixelGroup)





  # pixelCohortData <- LandR::addNoPixel2CohortData(cohortDataShort,
  #                                                 biomassMaps2011MB$pixelGroupMap,
  #                                                 doAssertion = getOption("LandR.assertions", TRUE))

  ##select only those pixelGroups that are in the studyArea

  ## Add vegetation type column to the bcr cohortData table
vegTypeTable <- LandR::vegTypeGenerator(bcrCohortData, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = simOutPreamble$sppEquiv,
                                        sppEquivCol = simOutPreamble$sppEquivCol, pixelGroupColName = "pixelGroup")

vegTypeMap <- LandR::vegTypeMapGenerator(bcrCohortData, pixelGroupMap = biomassMaps2011MB$pixelGroupMap,
                                        vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = simOutPreamble$sppEquiv,
                                        sppEquivCol = simOutPreamble$sppEquivCol, pixelGroupColName = "pixelGroup")


## subset the pixelCohortData and create a new column with the sum of Biomass(B) & relB
## per pixelGroup and RelB per pixelGroup & speciesCode
vegTypeTable[, sumB := sum(B), by = .(pixelGroup)]
vegTypeTable[, relB := sum(B)/sumB, by = .(pixelGroup, speciesCode)]
vegTypeTable[is.na(relB) & sumB == 0, relB := 0]

## check for missing values in B
if (any(is.na(vegTypeTable$relB))) {
  stop("Missing values in relative Biomass")
}

## subset to a smaller DT
vegTypes <- unique(vegTypeTable[B > 0, .(pixelGroup,leading, speciesCode, bcrID,relB, sumB)])

DT <- data.table::copy(vegTypes)
data.table::setkeyv(DT, cols = "pixelGroup")

vegTypes[, vegClass:= convertToVegTypeBCR6MBSK(.SD, pureCutoff = 0.8,
                                       deciSp = c("Popu_tre", "Popu_bal","Betu_pap"),
                                       coniSp = c("Pinu_ban", "Pinu_con", "Abie_bal", "Abie_las"),
                                       wetland = c("Pinu_ban", "Pinu_con")),
         by = pixelGroup, .SDcols = c("speciesCode", "relB", "leading", "bcrID")]

vegTypes$vegClass <- as.factor(vegTypes$vegClass)

vegTypesCD <- vegTypes[, list(vegType = unique(vegClass)), by = "pixelGroup"]

vegTypesRas <- SpaDES.tools::rasterizeReduced(reduced = vegTypesCD,
                                              fullRaster = pixelGroupMap,
                                              mapcode = "pixelGroup", newRasterCols ="vegType")

## get pixelGroup per bcr polygon
studyArea <-st_as_sf(studyArea)
bcrPixelGroupRas <- fasterize(studyArea, pixelGroupMap, field = "BCR")

bcrPixelGroupDT <- data.table(bcrID = getValues(bcrPixelGroupRas), pixelGroup = getValues(pixelGroupMap))
bcrPixelGroupDT <- na.omit(bcrPixelGroupDT)


bcr6MB <- studyArea[studyArea$BCR %in% c(6), ]
subsetpixelGroupMapRas <- crop(pixelGroupMap, bcr6MB)
bcrPixelGroupRas <- mask(subsetpixelGroupMapRas, mask = bcr6MB)


##subset bcrPixelGroupDT
bcrSelect <- 1
subsetbcrPixelGroup<- bcrPixelGroupDT[bcrPixelGroupDT$bcrID %in% bcrSelect, ]




levels(bcrPixelGroupDT$bcrID) <- levels(simOutPreamble$studyAreaReporting$BCR)


bcrCDPG<- merge(pixelCohortData2, bcrPixelGroupDT, by = "pixelGroup")
vegTypes2Ras <- SpaDES.tools::rasterizeReduced(reduced = subsetVegTypes,
                                              fullRaster = bcrPixelGroupRas,
                                              mapcode = "pixelGroup", newRasterCols ="leading")

tempRas <- raster(pixelGroupMap)

leading_ras <- raster(pixelGroupMap)
leading_ras[subsetbcrPixelGroupDT$pixelIndex] <- subsetVegTypeTable$leading

##extracting non forested pixels for cohortData

cohortDataEX <- as.data.table(biomassMaps2011SA$cohortData)

pixelCohortData2 <- LandR::addPixels2CohortData(cohortDataEX,
                                             biomassMaps2011SA$pixelGroupMap,
                                            doAssertion = getOption("LandR.assertions", TRUE))

##merge both DT to have the BCR id in the cohortData
lccpixelCohortData<- merge(pixelCohortData2, rstLCCDT, by = "pixelIndex")


rstLCC <- reproducible::Cache(LandR::prepInputsLCC,
                                  destinationPath = asPath(paths1$inputPath),
                                  studyArea = studyArea,
                                  rasterToMatch = simOutPreamble$rasterToMatchReporting,
                                  year = 2005)
writeRaster(rstLCC, filename= "rstLCC_MB.tif")
qs::qsave(pixelCohortData2, file = "pixelCohortData.qs")

pixelGroupMapDT <- data.table(pixelIndex = 1:length(pixelGroupMap), pixelGroup = getValues(pixelGroupMap))
rstLCCDT <- data.table(pixelIndex= 1:ncell(rstLCC), LCCClass = getValues(rstLCC))
all(pixelCohortData2$pixelIndex %in% rstLCCDT$pixelIndex)
rstLCCDT$pixelIndex[!rstLCCDT$pixelIndex %in% pixelCohortData2$pixelIndex]
nonForestedPixels <- lccpixelCohortData[LCCClass >15,]

library(RColorBrewer)
display.brewer.all()

## assuming cohortData and pixelGroupMap were saved at year 0 of the simulation
pixelCohortData <- LandR::addPixels2CohortData(cohortData, pixelGroupMap)
#nonForestPix <- setdiff(pixelCohortData2$pixelIndex, which(!is.na(pixelGroupMap[])))
#nonForestPix <- setdiff(which(!is.na(pixelGroupMap[])), pixelCohortData2$pixelIndex)

nonForestPix <- setdiff(1:ncell(pixelGroupMap), pixelCohortData$pixelIndex)
nonForestLCC <- rstLCC[nonForestPix]
nonForestLCC <- as.matrix(nonForestLCC)
nonForestLCCPix <- as.data.table(nonForestLCC)
