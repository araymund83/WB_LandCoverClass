################################################################################
##  Options
################################################################################

cacheDBconn <- if (cacheDB == "sqlite") {
  Require("RSQLite")
  NULL ## default to sqlite
} else if (cacheDB == "postgresql") {
  Require("RPostgres")
  DBI::dbConnect(drv = RPostgres::Postgres(),
                 host = Sys.getenv("PGHOST"),
                 port = Sys.getenv("PGPORT"),
                 dbname = Sys.getenv("PGDATABASE"),
                 user = Sys.getenv("PGUSER"),
                 password = Sys.getenv("PGPASSWORD"))
} else {
  stop("Unsupported cache database type '", cacheDB, "'")
}

raster::rasterOptions(default = TRUE)
options(
  "spades.recoveryMode" = 2,
  # "spades.lowMemory" = TRUE,
  "spades.useRequire" = TRUE,
  "LandR.assertions" = FALSE,
  "LandR.verbose" = 1,
  "map.dataPath" = paths1$inputPath,
  "map.useParallel" = TRUE,
  "map.overwrite" = TRUE,
  "reproducible.futurePlan" = FALSE,
  "future.globals.maxSize" = 6000*1024^2,
  "rasterMaxMemory" = rasterMaxMemory,
  "rasterTmpDir" = scratchDirRas,
  "reproducible.inputPaths" = paths1$inputPath,
  "reproducible.cacheSaveFormat" = "qs",
  "reproducible.qsPreset" = "fast",
  "reproducible.useGDAL" = FALSE,
  #"reproducible.destinationPath" = normPath(paths1$inputPath),
  "reproducible.polygonShortcut" = FALSE,
  "reproducible.inputPaths" = NULL,
  "reproducible.overwrite" = TRUE,
  "reproducible.useMemoise" = TRUE, # Brings cached stuff to memory during the second run
  "reproducible.useNewDigestAlgorithm" = 2,  # use the new less strict hashing algorithm
  "reproducible.useCache" = TRUE,
  #"reproducible.cachePath" = paths3$cachePath,
  "reproducible.showSimilar" = TRUE,
  "reproducible.useCloud" = FALSE,
  "spades.moduleCodeChecks" = FALSE, ## Turn off all module's code checking
  "spades.restartR.restarDir" = Paths$outputPath,
  "spades.useRequire" = TRUE, ##asuming all pkgs are installed correctly
  "pemisc.useParallel" = TRUE
)

Require(c("googledrive", "httr"))
httr::set_config(httr::config(http_version = 0))
drive_auth(email = userEmail, use_oob = quickPlot::isRstudioServer())
message(crayon::silver("Authenticating as: "), crayon::green(drive_user()$emailAddress))
