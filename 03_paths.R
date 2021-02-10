
#### setting paths --------------------------------------------------------------
setPaths(cachePath = file.path(getwd(), "cache"),
         inputPath = checkPath(file.path(getwd(), "inputs"),create = TRUE),
         modulePath = file.path(getwd(), "modules"),
         outputPath = checkPath(file.path(getwd(), "outputs"),
                                create = TRUE))