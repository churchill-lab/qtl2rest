

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

library(magrittr)
library(dplyr)


#' Fix the environment.
fix_environment <- function(suffix = NULL) {
    message("Fixing the enviroment")
    
    datasets <- grep("^dataset*", apropos("dataset\\."), value = TRUE)

    for (dataset_id in datasets) {
        ds <- get(dataset_id)
        
        # fix annotations
        if (tolower(ds$datatype) == "mrna") {
            ds$annot.mrna %<>% 
                rename(
                    gene_id           = matches("gene.id|gene_id"),
                    nearest_marker_id = 
                        matches("nearest.marker.id|nearest_marker_id")
                )
        } else if (tolower(ds$datatype) == "protein") {
            ds$annot.protein %<>% 
                rename(
                    gene_id           = matches("gene.id|gene_id"),
                    protein_id        = matches("protein.id|protein_id"),
                    nearest_marker_id = 
                        matches("nearest.marker.id|nearest_marker_id")
                )
        } else {
            ds$annot.phenotype %<>% janitor::clean_names()
        }
        
        for (peak in names(ds$lod.peaks)) {
            ds$lod.peaks[[peak]] %<>% janitor::clean_names()
        }
        
        # fix samples
        # ds$annot.samples %<>% janitor::clean_names()
        
        # fix covar.info
        ds$covar.info %<>% janitor::clean_names()
        
        if (!gtools::invalid(suffix)) {
            dataset_id <- paste0(dataset_id, suffix)
        }
        
        assign(dataset_id, ds, envir = .GlobalEnv)
    }
}


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
    
    fix_environment()
}

