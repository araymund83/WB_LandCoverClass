library(SpaDES.core)
library(SpaDES.tools)
outSimSppLayers <- loadSimList("/home/araymundo/GITHUB/WB_LandCoverClass/inputs/simOutSpeciesLayers_ABBC.qs")

# Ana's work below --------------------------------------------------------------------------------

## Add the pixel number to the cohortData
pixelCohortData <- LandR::addNoPixel2CohortData(outSimSppLayers$cohortData,
                                                outSimSppLayers$pixelGroupMap,
                                                doAssertion = getOption("LandR.assertions", TRUE))

## Add vegetation type column to the cohortData table
vegTypeTable <- LandR::vegTypeGenerator(pixelCohortData, vegLeadingProportion = 0.7,
                                        mixedType = 2, sppEquiv = outSimSppLayers$sppEquiv,
                                        sppEquivCol = "WB", pixelGroupColName = "pixelGroup")
vegTypeTable2 <- data.table::copy(vegTypeTable)


vegTypeMap <- LandR::vegTypeMapGenerator(pixelCohortData, vegLeadingProportion = 0.8,
                                         mixedType = 2, sppEquiv = outSimSppLayers$sppEquiv,
                                         pixelGroupMap = outSimSppLayers$pixelGroupMap,
                                         sppEquivCol = "WB", pixelGroupColName = "pixelGroup")

##subset the pixelCohortData and create a new column with the max age per pixelGroup
newAgeCD <- vegTypeTable[, list(ageMax = max(age)), by = "pixelGroup"]  ## TODO: BIOMASS WEIGHTED MEAN ?

##apply reclass function to the subset data.table
newAgeCD <- ageReclass(newAgeCD)

## create a new  RasterLayer of Age reclassified
ageGroupRas <- rasterizeReduced(reduced = newAgeCD,
                                fullRaster = outSimSppLayers[["pixelGroupMap"]],
                                mapcode = "pixelGroup", newRasterCols =  "ageGroup")
writeRaster(ageRas, "ageRas.tif")

vegTypeRas <- rasterizedReduced(reduced =)

## subset the pixelCohortData and create a new column with the sum of Biomass(B)
## per pixelGroup and RelB per pixelGroup & speciesCode
sumBCD <- vegTypeTable2[, list(sumB = sum(B)), by =  "pixelGroup"]

## create the sumB RasterLayer
sumBRas <- rasterizeReduced(reduced = sumBCD,
                            fullRaster = outSimSppLayers[["pixelGroupMap"]],
                            mapcode = "pixelGroup", newRasterCols =  "sumB")
## subset the pixelCohortData and create a new column with the sum of Biomass(B) & relB
## per pixelGroup and RelB per pixelGroup & speciesCode
vegTypeTable2[, sumB := sum(B), by = .(pixelGroup)]
vegTypeTable2[, relB := sum(B)/sumB, by = .(pixelGroup, speciesCode)]
vegTypeTable2[is.na(relB) & sumB == 0, relB := 0]

if (any(is.na(vegTypeTable2$relB))) {
  stop("Missing values in relative Biomass")
}

## subset to a smaller DT
vegTypes <- unique(vegTypeTable2[B > 0, .(pixelGroup,leading, speciesCode, B, relB, sumB)])


# a <- DT[ , list(vegClass), by = "pixelGroup"]
# rasterTemplate <- outSimSppLayers$pixelGroupMap
# rasterTemplate[!is.na(rasterTemplate)] <- 0
#
# r <- SpaDES.tools::rasterizeReduced(reduced = a,
#                                     fullRaster = outSimSppLayers[["pixelGroupMap"]],
#                                     mapcode = "pixelGroup", newRasterCols = "vegClass")

# Alex testing --------------------------------------------------------------------------------
DT <- data.table::copy(vegTypes)
data.table::setkeyv(DT, cols = "pixelGroup")

## TODO: use DT instead of DT2
DT2 <- DT[pixelGroup >= 3200000,]
#DT2 <- DT[pixelGroup == 500,]
DT2[, vegClass := convertToVegType(.SD, pureCutoff = 0.5,
                                   deciSp = c("Popu_tre", "Popu_bal","Betu_pap"),
                                   coniSp = c("Pinu_ban", "Pinu_con", "Abie_bal", "Abie_las")),
   by = pixelGroup, .SDcols = c("leading", "speciesCode", "relB")]


DTNA <- DT[is.na(vegClass)]

# end Alex testing ----------------------------------------------------------------------------

################################################################################
#                        non-forested pixels
################################################################################
treepixels <- simOutPreamble$rstLCC[] %in% forestedLCCClasses
vals <- raster::getValues(simOutPreamble$rasterToMatch)
uniqueLCCClasses <- na.omit(unique(simOutPreamble$rasterToMatch))
nontreeClasses <- sort(uniqueLCCClasses[!uniqueLCCClasses %in% forestedLCCClasses])

remapDT <- data.table::as.data.table(expand.grid(LCC2005 = c(NA_integer_, sort(uniqueLCCClasses)),
                         NFtype = c(NA_integer_, 0:5)))
remapDT[LCC2005 == 0, newLCC := NA_integer_]
remapDT[is.na(NFtype) | NFtype == 5, newLCC := LCC2005]
remapDT[LCC2005 == 4, newLCC := NA_integer_]
remapDT[CC %in% 0:3, newLCC := LCC2005]
remapDT[is.na(LCC2005) & CC %in% 0:2, newLCC := 99] ## reclassification needed
remapDT[LCC2005 %in% P(sim)$treeClassesToReplace, newLCC := 99] ## reclassification needed




