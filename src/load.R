

# #############################################################################
#
# Load the main data file.
#
# This was intended to be used in a controlled Docker environment and has
# some assumptions as to where the RData file resides and how it should be
# named.  For SNP association mapping, there also needs to be a SQLite
# database containing SNP information.
#
# Please see: https://github.com/churchill-lab/qtlapi/
#
# There are 2 methods in which we can utilize this script.
#
#     1. Pre load the RData file into the environment and set db.file to
#        the location of where the SNP database resides on disk.
#
#                     - OR -
#
#     2. Place a file with ".RData" extension in /app/qtlapi/data as well as
#        a file with a ".sqlite" extension for the SNP database.
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
    message("Finding the data file to load...")
    data_files <- list.files(
        "/app/qtl2rest/data",
        "\\.RData$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    if (length(data_files) == 0) {
        stop("There needs to be an .RData file in /app/qtl2rest/data")
    } else if (length(data_files) > 1) {
        stop("There needs to be only 1 .RData file in /app/qtl2rest/data")
    }

    message("Loading the data file:", data_files)

    load(data_files, .GlobalEnv)

    db_file <- list.files(
        "/app/qtl2rest/data",
        "\\.sqlite$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    if (length(db_file) == 0) {
        stop("There needs to be an .sqlite file in /app/qtl2rest/data")
    } else if (length(db_file) > 1) {
        stop("There needs to be only 1 .sqlite file in /app/qtl2rest/data")
    }

    message("Using SNP db file:", db_file)
}

