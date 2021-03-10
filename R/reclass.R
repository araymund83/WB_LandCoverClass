library(SpaDES.core)
library(SpaDES.tools)
outSimSppLayers <- loadSimList("~/Downloads/simOutSpeciesLayers_ABBC.qs")

# Ana's work below --------------------------------------------------------------------------------

## Add the pixel number to the cohortData
pixelCohortData <- LandR::addNoPixel2CohortData(outSimSppLayers$cohortData,
                                                outSimSppLayers$pixelGroupMap,
                                                doAssertion = getOption("LandR.assertions", TRUE))

## Add vegetation type column to the cohortData table
vegTypeTable <- LandR::vegTypeGenerator(pixelCohortData, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = sppEquiv,
                                        sppEquivCol = "WB", pixelGroupColName = "pixelGroup")
vegTypeTable2 <- copy(vegTypeTable)


vegTypeMap <- LandR::vegTypeMapGenerator(pixelCohortData, vegLeadingProportion = 0.8,
                                         mixedType = 2, sppEquiv = sppEquiv,
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

## subset the pixelCohortData and create a new column with the sum of Biomass(B)
## per pixelGroup and RelB per pixelGroup & speciesCode
sumBCD <- vegTypeTable[, list(sumB = sum(B)), by =  "pixelGroup"]

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
vegTypes <- unique(vegTypeTable2[B > 0, .(pixelGroup,speciesCode, relB, sumB)])

## TODO: romev this block -- it was Ana's 2nd attempt at reclassification
# vegTypes$vegClass <- ifelse(vegTypes$speciesCode %in% c("Pinu_ban", "Pinu_con") &
#                               sum(vegTypes$relB >= pureCutoff)
#                             & vegTypes$speciesCode %in% c("Popu_tre", "Popu_bal","Betu_pap","Abie_las","Abie_bal")
#                             & sum(vegTypes$relB >= .20), "pine",
#                             ifelse(vegTypes$speciesCode %in% c("Pice_mar") &  sum(vegTypes$relB >= pureCutoff) &
#                                      vegTypes$speciesCode %in% deciSp & sum(vegTypes$relB >= 0.2), "BkSp",
#                                    ifelse(vegTypes$speciesCode %in% c("Pice_gla", "Abie_bal") & sum(vegTypes$relB >= pureCutoff), "WhSp",
#                                           ifelse(vegTypes$speciesCode %in% c("Popu_tre", "Popu_bal", "Betu_pap") & sum(vegTypes$relB >= pureCutoff), "Deciduous",
#                                                  ifelse(vegTypes$speciesCode %in% c("Popu_tre", "Popu_bal", "Betu_pap") & sum(vegTypes$relB >= .20), "Mixedwood",
#                                                         ifelse(vegTypes$speciesCode %in% c("Pice_mar") & sum(vegTypes$relB >= pureCutoff), "wetland", "NonVeg"))))))

a <- vegTypes[ , list(vegClass), by = "pixelGroup"]
rasterTemplate <- outSimSppLayers$pixelGroupMap
rasterTemplate[!is.na(rasterTemplate)] <- 0

r <- SpaDES.tools::rasterizeReduced(reduced = a,
                                    fullRaster = vegTypes$pixelGroup,
                                    mapcode = "pixelGroup", newRasterCols = "vegClass")

# Alex testing --------------------------------------------------------------------------------
DT <- copy(vegTypes)
setkeyv(DT, cols = "pixelGroup")

## TODO: use DT instead of DT2
DT2 <- DT[pixelGroup >= 3260400,]
DT2[, vegClass := convertToVegType(.SD, pureCutoff = 0.8,
                                   deciSp = c("Popu_tre", "Popu_bal","Betu_pap"),
                                   coniSp = c("Pinu_ban", "Pinu_con", "Abie_bal", "Abie_las")),
   by = pixelGroup, .SDcols = c("speciesCode", "relB")]

# DT[, vegClass := convertToVegType(.SD, pureCutoff = 0.8,
#                                   deciSp = c("Popu_tre", "Popu_bal","Betu_pap"),
#                                   coniSp = c("Pinu_ban", "Pinu_con", "Abie_bal", "Abie_las")),
#    by = pixelGroup, .SDcols = c("speciesCode", "relB")]
# end Alex testing ----------------------------------------------------------------------------

convertToVegType <- function(DT, pureCutoff = 0.8,
                             deciSp = c("Popu_tre", "Popu_bal","Betu_pap"),
                             coniSp = c("Pinu_ban", "Pinu_con", "Abie_bal", "Abie_las")) {
    ## TODO: use factors or integers for vegClass ???
    if (.sumRelBs(c("Pinu_ban", "Pinu_con"), DT) >= pureCutoff &&
        .sumRelBs(c("Popu_tre", "Popu_bal", "Betu_pap"), DT) < 1 - pureCutoff) {
      ## Pine dominant: dominated by Pinu_ban(jackpine) &/or Pinu_con (Lodgepole pine) > 80%
      ## deciduous species less than 20%
      "Pine"
    } else if (.sumRelBs("Pice_mar", DT) >= pureCutoff &&
                .sumRelBs(deciSp, DT) > 0) {
      ## Black Spruce (BkSp): dominated by Pice_mar (black spruce) > 80%
      "BkSp"
    } else if (.sumRelBs(c("Pice_gla", "Abie_bal"), DT) >= pureCutoff) {
      ## White Spruce (WhSp): dominated by Pice_gla (white spruce) & Abie_bal (balsam fir) > 80%
      "WhSp"
    } else if (.sumRelBs(deciSp, DT) >= pureCutoff &&
               .sumRelBs(coniSp, DT) < 1 - pureCutoff) {
      ## Deciduous: Popu_tre(trembling aspen) &/or Popu_bal (balsam poplar) &/or
      ## Betu_pap(white birch) > 80%
      "Decid"
    } else if (.sumRelBs(c("Popu_tre", "Popu_bal", "Betu_pap"), DT) >= 1 - pureCutoff &&
               .sumRelBs(c(coniSp, "Pice_gla", "Pice_mar"), DT) > 1 - pureCutoff) {
      ## Mixedwood : Deciduous species more than 20%
      "Mixed"
    } else if (.sumRelBs("Pice_mar", DT) >= pureCutoff) {
      ## Wetland :Black spruce dominated and  Deciduous species more than 20%
      "Wtlnd"
    } else {
      ## just in case there are any not covered
      NA_character_
    }
}

#' internal function that sums relative biomasses for species matching a character string,
#' but that can be appear duplicated in another species coding column.
#' @param sppToMatch character string of species to match against for summing B.
#' @param DT data.table with columns 'speciesCode', 'relB'.
.sumRelBs <- function(sppToMatch, DT) {
  DT[speciesCode %in% sppToMatch, relB] %>% sum()
}

out <- convertToVegType(DT = vegTypes, groupingCol = "pixelGroup")
