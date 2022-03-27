library(RestRserve)
library(jsonlite)
library(memCompression)
library(qtl2api)
library(magrittr)
library(dplyr)

middleware_gzip <- Middleware$new(
    process_request = function(request, response) {
        #msg = list(
        #    middleware = 'middleware_gzip',
        #    request_id = request$id,
        #    timestamp = Sys.time()
        #)
        #msg = to_json(msg)
        #cat(msg, sep = '\n')
    },
    process_response = function(request, response) {
        enc = request$get_header("Accept-Encoding")

        if ("gzip" %in% enc) {
            response$set_header("Content-Encoding", "gzip")
            response$set_header("Vary", "Accept-Encoding")
            raw <- charToRaw(response$body)
            response$set_body(memCompression::compress(raw, "gzip"))
            response$encode = identity
        }
    
        #msg = list(
        #    middleware = 'middleware_gzip',
        #    request_id = request$id,
        #    timestamp = Sys.time()
        #)
        
        #msg = to_json(msg)
        #cat(msg, sep = '\n')
    },
    id = "gzip"
)

#' Convert to boolean/logical
#' 
#' Acceptable TRUE boolean values are TRUE, 1, "T", "TRUE", "YES", "Y", "1"
#'
#' @param value The value to check.
#' 
#' @return TRUE if it is a boolean value and it's value is one of the
#'   acceptable matching inputs.
#' 
#' @noRd
to_boolean <- function(value) {
  if (gtools::invalid(value)) {
    return(FALSE)
  } else if (is.numeric(value)) {
    return(value == 1)
  } else if (is.character(value)) {
    return(toupper(value) %in% c("T", "TRUE", "YES", "Y", "1"))
  }
  
  FALSE
}


pretty_JSON <- function(timestamp, level, logger_name, pid, message) {
    x = to_json(
        list(
            timestamp = format(timestamp, "%Y-%m-%d %H:%M:%OS6"),
            level = as.character(level),
            name = as.character(logger_name),
            pid = as.integer(pid),
            message = message
        )
    )
    cat(prettify(x), file = "", append = TRUE, sep = "\n")
}


# setup app and logging
application = Application$new(
    content_type = "application/json",
    middleware = list()
)

# custom logging for RestRServe
printer_pipe <- function(timestamp, level, logger_name, pid, message, ...) {
    timestamp <- format(
        timestamp, 
        "%Y-%m-%d %H:%M:%OS6", 
        usetz=TRUE, 
        tz='America/New_York'
    )
    level <- as.character(level)
    name <- as.character(logger_name)
    pid <- as.character(pid)
    msg <- sprintf("%s|%s|%s|%s|%s", timestamp, level, name, pid, message)
    writeLines(msg)
    flush(stdout())
}


logger = Logger$new("trace", printer = printer_pipe) 

#logger$trace(paste0('time: ', elapsed['elapsed']))
#logger$debug(paste0('time: ', elapsed['elapsed']))
#logger$info(paste0('time: ', elapsed['elapsed']))
#logger$warning(paste0('time: ', elapsed['elapsed']))
#logger$error(paste0('time: ', elapsed['elapsed']))
#logger$fatal(paste0('time: ', elapsed['elapsed']))

application$append_middleware(middleware_gzip)


log_error <- function(error, request) {
    param_string <- paste(
        names(request$parameters_query),
        request$parameters_query,
        sep="=",
        collapse="&")

    logger$error(paste0(request$path, "|", param_string, "|", error))
}

http_get_env_info <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        envObjects <- envElements
    
        elapsed <- proc.time() - ptm
        
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = envElements,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve environment elements",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_markers <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
    
        chrom <- request$parameters_query[["chrom"]]

        markers <- qtl2api::get_markers(chrom)

        elapsed <- proc.time() - ptm
        
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = markers,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve markers",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_datasets <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        datasets <- get_dataset_info()

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = datasets,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve datasets",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_datasets_stats <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        datasets <- get_dataset_stats()

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = datasets,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve dataset stats",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_lod_peaks <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
      
        dataset_id <- request$parameters_query[["dataset"]]
        expand <- to_boolean(request$parameters_query[["expand"]])

        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        }

        # get the LOD peaks for each covarint
        dataset <- get_dataset_by_id(dataset_id)
        peaks <- get_lod_peaks_all(dataset)
      
        if (!expand) {
            # by converting to data.frame and setting column names to NULL, 
            # when converted to JSON, the result will be a 2 dimensional array
            for (n in names(peaks)) {
                peaks[[n]] <- as.data.frame(peaks[[n]])
                colnames(peaks[[n]]) <- NULL
            }
        }
      
        elapsed <- proc.time() - ptm
      
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = peaks,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve lod peaks",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_rankings <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
    
        dataset_id <- request$parameters_query[["dataset"]]
        chrom <- request$parameters_query[["chrom"]]
        max_value <- nvl_int(request$parameters_query[["max_value"]], 1000)

        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        rankings <- get_rankings(
            dataset   = dataset,
            chrom     = chrom,
            max_value = max_value
        )
        
        elapsed <- proc.time() - ptm
        
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = rankings,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve rankings",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_id_exists <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
      
        id <- request$parameters_query[["id"]]
        dataset_id <- request$parameters_query[["dataset"]]
        
        if (gtools::invalid(id)) {
            stop("id is required")
        }

        if (gtools::invalid(dataset_id)) {
            ret <- qtl2api::id_exists(id)
        } else {
            dataset <- get_dataset_by_id(dataset_id)
            ret <- qtl2api::id_exists(id, dataset)
        }
        
        elapsed <- proc.time() - ptm
  
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = ret,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to determine if id exists",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_lodscan <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
      
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        intcovar <- request$parameters_query[["intcovar"]]
        cores <- nvl_int(request$parameters_query[["cores"]], 5)
        expand <- to_boolean(request$parameters_query[["expand"]])
        
        if (tolower(nvl(intcovar, "")) %in% c("", "additive")) {
            intcovar <- NULL
        }
        
        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        lod <- get_lod_scan(
            dataset  = dataset,
            id       = id,
            intcovar = intcovar,
            cores    = cores
        )
        
        # we don't need the peaks, etc
        lod <- lod$lod_scores
        
        if (!expand) {
            # by converting to data.frame and setting column names to NULL, 
            # when converted to JSON, the result will be a 2 dimensional array
            lod <- as.data.frame(lod)
            colnames(lod) <- NULL
        }
        
        elapsed <- proc.time() - ptm
  
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = lod,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve LOD scan data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_lodscan_samples <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
        
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        intcovar <- request$parameters_query[["intcovar"]]
        chrom <- request$parameters_query[["chrom"]]
        cores <- nvl_int(request$parameters_query[["cores"]], 5)
        expand <- to_boolean(request$parameters_query[["expand"]])
        
        if (tolower(nvl(intcovar, "")) %in% c("", "additive")) {
            intcovar <- NULL
        }
        
        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        } else if (gtools::invalid(intcovar)) {
            stop("intcovar is required")
        } else if (gtools::invalid(chrom)) {
            stop("chrom is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        lod <- get_lod_scan_by_sample(
            dataset  = dataset, 
            id       = id,
            chrom    = chrom,
            intcovar = intcovar,
            cores    = cores
        )
        
        if (!expand) {
            # by converting to data.frame and setting column names to NULL, 
            # when converted to JSON, the result will be a 2 dimensional array
            for (element in names(lod)) {
                lod[[element]] <- as.data.frame(lod[[element]])
                colnames(lod[[element]]) <- NULL
            }
        }
        
        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = lod,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve LOD scan data by sample",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_foundercoefficients <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
        
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        chrom <- request$parameters_query[["chrom"]]
        intcovar <- request$parameters_query[["intcovar"]]
        blup <- to_boolean(request$parameters_query[["blup"]])
        cores <- nvl_int(request$parameters_query[["cores"]], 5)
        expand <- to_boolean(request$parameters_query[["expand"]])
        center <- to_boolean(nvl(request$parameters_query[["center"]], "TRUE"))

        if (tolower(nvl(intcovar, "")) %in% c("", "additive")) {
            intcovar <- NULL
        }

        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        } else if (gtools::invalid(chrom)) {
            stop("chrom is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        effect <- get_founder_coefficients(
            dataset  = dataset, 
            id       = id,
            chrom    = chrom, 
            intcovar = intcovar,
            blup     = blup, 
            center   = center,
            cores    = cores
        )
        
        if (!expand) {
            # by converting to data.frame and setting column names to NULL, 
            # when converted to JSON, the result will be a 2 dimensional array
            for (element in names(effect)) {
                effect[[element]] <- as.data.frame(effect[[element]])
                colnames(effect[[element]]) <- NULL
            }
        }

        elapsed <- proc.time() - ptm
  
        data <- list(
            request    = request$path,
            parameters = request$parameters_query, 
            result     = effect,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve founder coefficient data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_expression <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
      
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
      
        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        expression <- get_expression(
            dataset = dataset, 
            id      = id
        )
      
        # eliminate the _row column down line for JSON
        rownames(expression$data) <- NULL

        elapsed <- proc.time() - ptm
      
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = expression,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve expression data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_mediation <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
        
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        marker_id <- request$parameters_query[["marker_id"]]
        dataset_id_mediate <- request$parameters_query[["dataset_mediate"]]
        expand <- to_boolean(request$parameters_query[["expand"]])

        #if (tolower(nvl(intcovar, "")) %in% c("", "none")) {
        #    intcovar <- NULL
        #}

        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        } else if (gtools::invalid(marker_id)) {
            stop("marker_id is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        dataset_mediate <- 
            get_dataset_by_id(nvl(dataset_id_mediate, dataset_id))

        mediation <- get_mediation(
            dataset         = dataset, 
            id              = id,
            marker_id       = marker_id,
            dataset_mediate = dataset_mediate
        )
        
        if (!expand) {
            # by converting to data.frame and setting column names to NULL, 
            # when converted to JSON, the result will be a 2 dimensional array
            mediation <- as.data.frame(mediation)
            colnames(mediation) <- NULL
        }

        elapsed <- proc.time() - ptm
        
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = mediation,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve mediation data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}


http_get_snp_assoc_mapping <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
        
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        chrom <- request$parameters_query[["chrom"]]
        location <- request$parameters_query[["location"]]
        window_size <- nvl_int(request$parameters_query[['window_size']], 
                               500000)
        intcovar <- request$parameters_query[["intcovar"]]
        cores <- nvl_int(request$parameters_query[["cores"]], 5)
        expand <- to_boolean(request$parameters_query[["expand"]])
        
        if (tolower(nvl(intcovar, "")) %in% c("", "additive")) {
            intcovar <- NULL
        }

        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        } else if (gtools::invalid(chrom)) {
            stop("chrom is required")
        } else if (gtools::invalid(location)) {
            stop("location is required")
        }
        
        dataset <- get_dataset_by_id(dataset_id)
        snp_assoc <- get_snp_assoc_mapping(
            dataset     = dataset, 
            id          = id,
            chrom       = chrom,
            location    = location,
            db_file     = db_file, # GLOBAL
            window_size = window_size,
            intcovar    = intcovar,
            cores       = cores
        )
        
        if (!expand) {
            # by converting to data.frame and setting column names to NULL, 
            # when converted to JSON, the result will be a 2 dimensional array
            snp_assoc <- as.data.frame(snp_assoc)
            colnames(snp_assoc) <- NULL
        }

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = snp_assoc,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve SNP association mapping data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}

http_get_correlation <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
        
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        dataset_id_correlate <- request$parameters_query[["dataset_correlate"]]
        intcovar <- request$parameters_query[["intcovar"]]
        max_items <- nvl_int(request$parameters_query[["max_items"]], 10000)
        
        if (tolower(nvl(intcovar, "")) %in% c("", "none")) {
            intcovar <- NULL
        }
        
        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        dataset_correlate <- 
            get_dataset_by_id(nvl(dataset_id_correlate, dataset_id))

        correlation <- get_correlation(
            dataset           = dataset, 
            id                = id,
            dataset_correlate = dataset_correlate,
            intcovar          = intcovar
        )

        data <- correlation$correlations        
        data <- data[1:min(max_items, NROW(data)), ]    

        ret <- list(correlations    = data,
                    imputed_samples = correlation$imputed_samples)

        elapsed <- proc.time() - ptm
        
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = ret,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve correlation data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}

http_get_correlation_plot_data <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()
        
        dataset_id <- request$parameters_query[["dataset"]]
        id <- request$parameters_query[["id"]]
        dataset_id_correlate <- request$parameters_query[["dataset_correlate"]]
        id_correlate <- request$parameters_query[["id_correlate"]]
        intcovar <- request$parameters_query[["intcovar"]]
        
        if (tolower(nvl(intcovar, "")) %in% c("", "none")) {
            intcovar <- NULL
        }
        
        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        } else if (gtools::invalid(id)) {
            stop("id is required")
        } else if (gtools::invalid(dataset_id_correlate)) {
            stop("dataset_correlate is required")
        } else if (gtools::invalid(id_correlate)) {
            stop("id_correlate is required")
        }

        dataset <- get_dataset_by_id(dataset_id)
        dataset_correlate <- 
            get_dataset_by_id(nvl(dataset_id_correlate, dataset_id))

        correlation <- get_correlation_plot_data(
            dataset           = dataset,
            id                = id,
            dataset_correlate = dataset_correlate,
            id_correlate      = id_correlate,
            intcovar          = intcovar
        )

        elapsed <- proc.time() - ptm
        
        data <- list(
            path       = request$path,
            parameters = request$parameters_query, 
            result     = correlation,
            time       = elapsed["elapsed"]
        )
        
        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <- toJSON(data, auto_unbox = TRUE)
    },
    error = function(e) {
        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            error      = "Unable to retrieve correlation plot data",
            details    = e$message
        )
        log_error(e, request)
        response$status_code <- 400
        response$body <- toJSON(data, auto_unbox = TRUE)
    })
}

application$add_get(
    path     = "/envinfo", 
    FUN      = http_get_env_info, 
    add_head = FALSE
)

application$add_get(
    path     = "/markers", 
    FUN      = http_get_markers, 
    add_head = FALSE
)

application$add_get(
    path     = "/datasets", 
    FUN      = http_get_datasets, 
    add_head = FALSE
)

application$add_get(
    path     = "/datasetsstats", 
    FUN      = http_get_datasets_stats, 
    add_head = FALSE
)

application$add_get(
    path     = "/lodpeaks", 
    FUN      = http_get_lod_peaks, 
    add_head = FALSE
)

application$add_get(
    path     = "/rankings", 
    FUN      = http_get_rankings, 
    add_head = FALSE
)

application$add_get(
    path     = "/idexists", 
    FUN      = http_id_exists, 
    add_head = FALSE
)

application$add_get(
    path     = "/lodscan", 
    FUN      = http_get_lodscan, 
    add_head = FALSE
)

application$add_get(
    path     = "/lodscansamples", 
    FUN      = http_get_lodscan_samples, 
    add_head = FALSE
)

application$add_get(
    path     = "/foundercoefs", 
    FUN      = http_get_foundercoefficients, 
    add_head = FALSE
)

application$add_get(
    path     = "/expression", 
    FUN      = http_get_expression, 
    add_head = FALSE
)

application$add_get(
    path     = "/mediate", 
    FUN      = http_get_mediation, 
    add_head = FALSE
)

application$add_get(
    path     = "/snpassoc", 
    FUN      = http_get_snp_assoc_mapping, 
    add_head = FALSE
)

application$add_get(
    path     = "/correlation", 
    FUN      = http_get_correlation, 
    add_head = FALSE
)

application$add_get(
    path     = "/correlationplot", 
    FUN      = http_get_correlation_plot_data, 
    add_head = FALSE
)

#application$add_get(path = "/hasannotation", FUN = http_has_annotation, add_head = FALSE)

#RestRserveApp$add_openapi(path = '/openapi.yaml', file_path = 'openapi.yaml')
#RestRserveApp$add_swagger_ui(path = '/swagger', 
#                   path_openapi = '/openapi.yaml', 
#                   path_swagger_assets = '/__swagger__')


#application$add_openapi()
#application$add_swagger_ui('/')


backend = BackendRserve$new()
backend$start(application, 
              http_port = 8001, 
              encoding = "utf8", 
              port = 6311, 
              daemon = "disable", 
              pid.file = "Rserve.pid")




