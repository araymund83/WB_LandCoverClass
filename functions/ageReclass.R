#' Reclassification of pixel ages into age-classes for the WB_project.
#' #'
#' @param DT A cohortData with pixelGroup from LandR \c
#' @return a data.table with an extra column \code{"ageGroup"}

ageReclass <- function(DT, 
                       ageBreaks = c( 0, 10,20,30,40,50,60,70,80,90,100,110,120, 130, 140,400),
                       ageLabels = c ("0-10", "11-20", "21-30", "31-40", "41-50", "51-60",
                       "61-70","71-80","81-90", "91-100", "101-110", "111-120",
                      "121-130", "131-140","141+")){
  DT[, ageGroup := cut(ageMax,
                               breaks = ageBreaks,
                               right =  FALSE,
                               labels = ageLabels)]
  return (DT)
}