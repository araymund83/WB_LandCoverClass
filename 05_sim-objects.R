###############################################################################
## additional simulation object definitions
################################################################################
  data("sppEquivalencies_CA", package = "LandR")
  sppEquivalencies_CA[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
                                               EN_generic_full = "Pine",
                                               Leading = "Pine leading")]
  
  
  ## Make WB spp equivalences 
  sppEquivCol <- "WB"
  data("sppEquivalencies_CA", package = "LandR")
  # sppEquivalencies_CA[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
  #                                              EN_generic_full = "Pine",
  #                                              Leading = "Pine leading")]
  
  sppEquivalencies_CA[, WB := c(Pice_mar = "Pice_mar", Pice_gla = "Pice_gla",
                                Pinu_con = "Pinu_con", Popu_tre = "Popu_tre",
                                Popu_bal = "Popu_bal", Lari_lar = "Lari_lar",
                                Pinu_ban = "Pinu_ban", Betu_pap = "Betu_pap",
                                Abie_las = "Abie_las", Abie_bal = "Abie_bal")[LandR]]
                                #Frax_pen = "Frax_pen", Acer_neg = "Acer_neg",
                               # Ulmu_ame = "Ulmu_ame", Sali_sp = "Sali_sp")[LandR]]
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!LANDIS_traits == "PINU.CON.CON"]
  
  sppEquivalencies_CA[WB == "Abie_las", EN_generic_full := "Subalpine Fir"]
  sppEquivalencies_CA[WB == "Abie_las", EN_generic_short := "Fir"]
  sppEquivalencies_CA[WB == "Abie_las", Leading := "Fir leading"]
  sppEquivalencies_CA[WB == "Popu_tre", Leading := "Pop leading"]
  sppEquivalencies_CA[WB == "Betu_pap", EN_generic_short := "Betula"]
  sppEquivalencies_CA[WB == "Betu_pap",  Leading := "Betula leading"]
  sppEquivalencies_CA[WB == "Betu_pap",  EN_generic_full := "Paper birch"]
 # sppEquivalencies_CA[WB == "Acer_neg",  EN_generic_full := "Boxelder maple"]
  #sppEquivalencies_CA[WB == "Frax_ame",  EN_generic_full := "American beech"]
  #sppEquivalencies_CA[WB == "Sali_sp",  EN_generic_full := "Willow leading"]
  
  sppEquivalencies_CA$EN_generic_short <- sppEquivalencies_CA$WB
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!is.na(WB)]
  sppEquivalencies_CA[WB == "Pinu_con", KNN := "Pinu_Con"]
  
  #Assign colour
  sppColorVect <- LandR::sppColors(sppEquiv = sppEquivalencies_CA, 
                                   sppEquivCol = sppEquivCol,
                                   palette = "Set3")
  mixed <- structure("#D0FB84", names = "Mixed")
  sppColorVect[length(sppColorVect)+1] <- mixed
  attributes(sppColorVect)$names[length(sppColorVect)] <- "Mixed"
  
  
  