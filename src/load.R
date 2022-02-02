# #############################################################################
#
# Load the main data file(s).
#
# This was intended to be used in a controlled Docker environment and has
# some assumptions as to where the RData file resides and how it should be
# named.  For SNP association mapping, there also needs to be a SQLite
# database containing SNP information.
#
# Please see: https://github.com/churchill-lab/qtl2api/
#
# There are 3 methods in which we can utilize this script.
#
#     1. Pre load the RData file into the environment and set db.file to
#        the location of where the SNP database resides on disk.
#
#                     - OR -
#
#     2. Place a file with ".RData" and/or ".RDS" extension in 
#        /app/qtlapi/data as well as a file with a ".sqlite" extension
#        for the SNP database.
#
# #############################################################################

# set a variable called debug_mode to TRUE for step 1 above.

if (exists("debug_mode")) {
    debug_mode <- get("debug_mode")
} else {
    debug_mode <- FALSE
}

if (debug_mode) {
    message("DEBUG MODE: Make sure the data is loaded and db_file is defined")
    message("DEBUG MODE: Make sure to run fix_environment")
} else {
    message("Finding the data files to load...")
    envElements <- list()

    rdata_files <- list.files(
        "/app/qtl2rest/data/rdata",
        "\\.RData$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    if (length(rdata_files) >= 0) {
        for (f in rdata_files) {
            message("Loading the RDATA file:", f)
            tempElems <- load(f, .GlobalEnv)
            elem <- list (
                fileName = basename(f),
                fileSize = file.size(f),
                elements = sort(tempElems)
            )

            envElements <- c(envElements, list(elem))
        }
    }

    rds_files <- list.files(
        "/app/qtl2rest/data/rdata",
        "\\.Rds$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    if (length(rds_files) >= 0) {
        for (f in rds_files) {
            elemName <- tools::file_path_sans_ext(basename(f))

            message("Loading the RDS file: ", f, " into ", elemName)
            temp <- readRDS(f)

            # check for dataset
            if (exists('annot.samples', temp) &&
                exists('covar.info', temp) &&
                exists('datatype', temp) &&
                exists('data', temp)) {

                if ("dataset." != tolower(substr(elemName, 1, 8))) {
                    # making the element start with "dataset." confirms a dataset
                    elemName <- paste0("dataset.", elemName)
                }
            }

            assign(elemName, temp, .GlobalEnv)

            elem <- list(
                fileName = basename(f),
                fileSize = file.size(f),
                elements = elemName
            )

            envElements <- c(envElements, list(elem))
        }
    }

    if ((length(rdata_files) == 0) && (length(rds_files) == 0)) {
        stop("There needs to be .RData/.Rds file(s) in /app/qtl2rest/data/rdata")
    }

    rm(f, elem, temp, rdata_files, rds_files)

    db_file <- list.files(
        "/app/qtl2rest/data/sqlite",
        "\\.sqlite$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    if (length(db_file) == 0) {
        stop("There needs to be an .sqlite file in /app/qtl2rest/data/sqlite")
    } else if (length(db_file) > 1) {
        stop("There needs to be only 1 .sqlite file in /app/qtl2rest/data/sqlite")
    }

    message("Using SNP db file:", db_file)
}

