library(SpaDES.core)
library(SpaDES.tools)
#biomassMaps2011MB<- loadSimList("/home/araymundo/GITHUB/WB_LandCoverClass/inputs/biomassMaps2011_MB.qs")
biomassMaps2011MB<- qs::qread(file.path(getwd(),"inputs", "biomassMaps2011_MB.qs"))
##extract pixel  id numbers that only intersect with the studyArea.

bcrMBpixels<- raster::extract(biomassMaps2011MB$pixelGroupMap,
                              simOutPreamble$studyAreaReporting,
                              cellnumbers = TRUE, df = TRUE)

##assign the BCR number to the ID
bcrMBpixels$ID <- as.factor(bcrMBpixels$ID)
simOutPreamble$studyAreaReporting$BCR <- as.factor(simOutPreamble$studyAreaReporting$BCR)
levels(bcrMBpixels$ID) <- levels(simOutPreamble$studyAreaReporting$BCR)

## rename columns for easy reference
names(bcrMBpixels) <- c ("bcrID", "pixelID", "pixelGroup")

##merge both DT to have the BCR id in the cohortData
bcrCohortData<- merge(pixelCohortData2, bcrMBpixels, by = "pixelGroup")


pixelCohortData <- LandR::addPixels2CohortData(cohortData,
                                               biomassMaps2011MB$pixelGroupMap,
                                               doAssertion = getOption("LandR.assertions", TRUE))
pixelCohortData2 <- LandR::addNoPixel2CohortData(cohortData,
                                               biomassMaps2011MB$pixelGroupMap,
                                               doAssertion = getOption("LandR.assertions", TRUE))


bcrSelect <- 6
subsetPixels<- bcrMBpixels[bcrMBpixels$bcrID %in% bcrSelect, ]

plot(biomassMaps2011MB$pixelGroupMap)
#for some reason cohortData loads as a list, so it needs to be reconverted
cohortData <- as.data.table(biomassMaps2011MB$cohortData)
bcrSApixels <- bcrMBpixels[bcrMBpixels$bcrID == unique(bcrMBpixels$bcrID), ]


# tempRas <- copy(biomassMaps2011MB$pixelGroupMap)
# tempRas[!tempRas[] %in% bcr6MBpixels$cell] <- NA

cohorDataShort <- lapply(cohortData, unique)


cohortDataShort <- pixelCohortData[pixelCohortData$pixelGroup %in% bcrSApixels$pixelGroupMap]
all(cohortDataShort$pixelGroup %in% cohortData$pixelGroup)
all(cohortDataShort$pixelGroup %in% pixelCohortData$pixelGroup)
all(bcrMBpixels$pixelID %in% pixelCohortData$pixelIndex)
all(pixelCohortData$pixelGroup %in% bcrMBpixels$pixelGroup)





  # pixelCohortData <- LandR::addNoPixel2CohortData(cohortDataShort,
  #                                                 biomassMaps2011MB$pixelGroupMap,
  #                                                 doAssertion = getOption("LandR.assertions", TRUE))

  ##select only those pixelGroups that are in the studyArea

  ## Add vegetation type column to the cohortData table
vegTypeTable <- LandR::vegTypeGenerator(cohortDataShort, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = simOutPreamble$sppEquiv,
                                        sppEquivCol = simOutPreamble$sppEquivCol, pixelGroupColName = "pixelGroup")
