##Extract LCCO5 values for each BCR and get frequencies

## fasterize sf objects for all BCR
BCRs <- unique(bcrWB$BCR)
BCRRas <- fasterize(bcrWB, LCC05Ras, field = "BCR")
eachPoly <- lapply(BCRs, FUN = function(bcr, ras = BCRRas, lccRas =LCC05Ras){
  BCRRas[!is.na(BCRRas[]) & (BCRRas[]!= bcr)] <- NA
  lccRas[is.na(BCRRas)] <- NA
  dat <- data.table(lcc = getValues(lccRas), bcr = bcr)
  dat <- dat[!is.na(lcc)]
  return(dat)
})

###producing plots with lapply and ggplot

plots <- lapply(eachPoly, function(x) {
  ggplot(x, aes(lcc, ..count..), group = bcr) + 
    geom_bar() + 
    labs(y = "Frequency", x = "LCC") +
    theme(axis.text= element_text(size = 9),
          axis.title = element_text(size = 11, face = "bold")) +
    scale_x_continuous(breaks = seq(from = 1, to = 39, by = 1)) + 
    #facet_wrap(~BCR) +
    labs(title="BCR", subtitle =names(eachPoly))})
lapply(names(plots), 
       function(x) ggsave(filename=paste(x,".emf",sep=""), plot=plots[[x]]))

## proportion plots 

plots <- lapply(eachPoly, function(x) {
  ggplot(x, aes(lcc, group = bcr)) + 
    geom_bar(aes(y = ..prop.., fill = factor(..x..)), stat = "count") + 
    scale_y_continuous(labels = scales::percent) + 
    labs(y ="Relative Freq", x = "LCC") +
    theme(axis.text= element_text(size = 9),
          axis.title = element_text(size = 11, face = "bold"),
          legend.position = "none") +
    scale_x_continuous(breaks = seq(from = 1, to = 39, by = 1)) + 
    facet_grid(~bcr) +
    labs(title="BCR", subtitle =names(eachPoly))})
lapply(names(plots), 
       function(x) ggsave(filename=paste(x,".emf",sep=""), plot=plots[[x]]))

plots
do.call(grid.arrange, plots)

###BCR6 SPLIT

## Extract LCC05 values for BCR6 subdivision
bcr6Vals <- raster::extract(LCC05_6Ras, bcr6SA2)
vals <- lapply(bcr6Vals, table)
valsDT <- rbindlist(lapply(vals, as.data.frame.list), fill = T)

valsDT = as.data.table(t(as.matrix(valsDT)))
setnames(valsDT, c("AB","BC","MB","SK","NWT"))
valsDT$LCC <- seq(1:40)
valsDT <- valsDT[, lapply(.SD, as.numeric), by= "LCC"]


#add columns by group of provinces AB-BC, MB-SK
valsDT[, ABBC:= sum(AB,BC), by = .(AB, BC)]
valsDT[, MBSK:= sum(MB,SK), by = .(MB, SK)]


plotseriesbarplots <- function(yvar){
  ggplot(valsDT, aes_(x=~LCC,y=as.name(yvar))) +
    geom_bar(stat = "identity") + 
    labs(x = "LCC", y = "Frequency") +
    theme(axis.text= element_text(size = 9),
          axis.title = element_text(size = 11, face = "bold"),
          legend.position = "none") +
    scale_x_continuous(breaks = seq(from = 1, to = 39, by = 1)) +
    ggtitle(paste("LCC in",yvar))
  
}
bcr6Plots<- lapply(names(valsDT[c(6:8)]), plotseriesbarplots)
fp <- file.path("outputs","figures")
lapply(names(bcr6Plots),function(x) ggsave(path = fp, filename = paste0(x, ".png", sep = ""), 
                                      plot = plotseriesbarplots[[x]]))

## SUBSET THE NON FORESTED CLASSES 

nonForest <- valsDT[valsDT[['LCC']] > 15, ]

#create palette of colours
colourCount = length(unique(nonForest$LCC))
getPalette = colorRampPalette(brewer.pal(8, "Set2"))
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

nonforestbarplots <- function(yvar){
  ggplot(nonForest, aes_(x=~LCC,y=as.name(yvar), fill = "LCC")) +
    geom_bar(stat = "identity") + 
    scale_fill_manual(values = getPalette(colourCount)) +
   # scale_fill_manual(values =getPalette(colourCount)) +
    labs(x = "No-forested LCC", y = "Frequency") +
    theme(axis.text= element_text(size = 9),
          axis.title = element_text(size = 11, face = "bold"),
          legend.position = "none") +
    scale_x_continuous(breaks = seq(from = 16, to = 39, by = 1)) +
    ggtitle(paste("BCR6",yvar))
  
}
NFbcr6Plots <- lapply(names(valsDT[c(6:8)]), nonforestbarplots)
fp <- file.path("outputs","figures")
lapply(names(NFbcr6Plots),function(x) ggsave(path = fp, filename = paste0(x, ".png", sep = ""), 
                                           plot = nonforestbarplots[[x]]))

