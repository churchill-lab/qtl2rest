#
# restapi.R
#

http_qtl2_info <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        ret <- qtl2_info()

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = ret,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}

http_get_analysis <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        analysis_info <- api_get_analysis()

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = analysis_info,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}

http_get_markers <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        chrom <- request$parameters_query[["chrom"]]

        # NEW
        markers <- api_get_markers

        # OLD
        # markers <- qtl2api::get_markers(chrom)

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = markers,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_get_datasets <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        collapse <- to_boolean(request$parameters_query[["collapse"]])

        # NEW
        ds_info <- api_get_dataset_info()

        # OLD
        # ds_info <- qtl2api::get_dataset_info()

        datasets <- ds_info$datasets
        ensembl_version <- ds_info$ensembl_version

        if (collapse) {
            # by converting to data.frame and setting column names to NULL,
            # when converted to JSON, the result will be a 2 dimensional array
            for (n in 1:length(datasets)) {
                annots <- datasets[[n]]$annotations
                annots_columns <- colnames(annots)
                annots <- as.data.frame(annots)
                colnames(annots) <- NULL

                datasets[[n]]$annotations <- list(
                    columns = annots_columns,
                    data    = annots
                )

                samples <- datasets[[n]]$samples
                samples_columns <- colnames(samples)
                samples <- as.data.frame(samples)
                colnames(samples) <- NULL

                datasets[[n]]$samples <- list(
                    columns = samples_columns,
                    data    = samples
                )
            }
        }

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = list(
                datasets        = datasets,
                ensembl_version = ensembl_version
            ),
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_get_datasets_stats <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        # NEW
        datasets <- api_get_dataset_stats()

        # OLD
        # datasets <- qtl2api::get_dataset_stats()

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = datasets,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        peaks <- api_get_lod_peaks_dataset(dataset)

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # peaks <- qtl2api::get_lod_peaks_dataset(dataset)

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_calc_rankings <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        dataset_id <- request$parameters_query[["dataset"]]
        chrom <- request$parameters_query[["chrom"]]
        max_value <- nvl_int(request$parameters_query[["max_value"]], 1000)

        if (gtools::invalid(dataset_id)) {
            stop("dataset is required")
        }

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        rankings <- api_calc_rankings(
            dataset   = dataset,
            chrom     = chrom,
            max_value = max_value
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # rankings <- qtl2api::get_rankings(
        #     dataset   = dataset,
        #     chrom     = chrom,
        #     max_value = max_value
        # )

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = rankings,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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

        # NEW
        if (gtools::invalid(dataset_id)) {
            ret <- api_id_exists(id)
        } else {
            dataset <- api_get_dataset_by_id(dataset_id)
            ret <- api_id_exists(id, dataset)
        }

        # OLD
        # if (gtools::invalid(dataset_id)) {
        #     ret <- qtl2api::id_exists(id)
        # } else {
        #     dataset <- qtl2api::get_dataset_by_id(dataset_id)
        #     ret <- qtl2api::id_exists(id, dataset)
        # }

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = ret,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_calc_lod_scores <- function(request, response) {
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        lod <- api_calc_lod_scores(
            dataset  = dataset,
            id       = id,
            intcovar = intcovar,
            cores    = cores
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # lod <- qtl2api::get_lod_scan(
        #     dataset  = dataset,
        #     id       = id,
        #     intcovar = intcovar,
        #     cores    = cores
        # )

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}

http_calc_lod_scores_by_covar <- function(request, response) {
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        lod <- api_calc_lod_scores_by_covar(
            dataset  = dataset,
            id       = id,
            chrom    = chrom,
            intcovar = intcovar,
            cores    = cores
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # lod <- qtl2api::get_lod_scan_by_sample(
        #     dataset  = dataset,
        #     id       = id,
        #     chrom    = chrom,
        #     intcovar = intcovar,
        #     cores    = cores
        # )

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_calc_founder_coefficients <- function(request, response) {
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        effect <- api_calc_founder_coefficients(
            dataset  = dataset,
            id       = id,
            chrom    = chrom,
            intcovar = intcovar,
            blup     = blup,
            center   = center,
            cores    = cores
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # effect <- qtl2api::get_founder_coefficients(
        #     dataset  = dataset,
        #     id       = id,
        #     chrom    = chrom,
        #     intcovar = intcovar,
        #     blup     = blup,
        #     center   = center,
        #     cores    = cores
        # )

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        expression <- api_get_expression(
            dataset = dataset,
            id      = id
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # expression <- qtl2api::get_expression(
        #     dataset = dataset,
        #     id      = id
        # )

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_calc_mediation <- function(request, response) {
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        dataset_mediate <-
            api_get_dataset_by_id(nvl(dataset_id_mediate, dataset_id))

        mediation <- api_calc_mediation(
            dataset         = dataset,
            id              = id,
            marker_id       = marker_id,
            dataset_mediate = dataset_mediate
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # dataset_mediate <-
        #     qtl2api::get_dataset_by_id(nvl(dataset_id_mediate, dataset_id))
        #
        # mediation <- qtl2api::get_mediation(
        #     dataset         = dataset,
        #     id              = id,
        #     marker_id       = marker_id,
        #     dataset_mediate = dataset_mediate
        # )

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_calc_snp_assoc_mapping <- function(request, response) {
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        snp_assoc <- api_calc_snp_assoc_mapping(
            dataset     = dataset,
            id          = id,
            chrom       = chrom,
            location    = location,
            db_file     = db_file, # GLOBAL
            window_size = window_size,
            intcovar    = intcovar,
            cores       = cores
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # snp_assoc <- qtl2api::get_snp_assoc_mapping(
        #     dataset     = dataset,
        #     id          = id,
        #     chrom       = chrom,
        #     location    = location,
        #     db_file     = db_file, # GLOBAL
        #     window_size = window_size,
        #     intcovar    = intcovar,
        #     cores       = cores
        # )

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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}


http_calc_correlation <- function(request, response) {
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

        # NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        dataset_correlate <-
            api_get_dataset_by_id(nvl(dataset_id_correlate, dataset_id))

        correlations <- api_calc_correlation(
            dataset           = dataset,
            id                = id,
            dataset_correlate = dataset_correlate,
            intcovar          = intcovar
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # dataset_correlate <-
        #     qtl2api::get_dataset_by_id(nvl(dataset_id_correlate, dataset_id))
        #
        # correlations <- qtl2api::get_correlation(
        #     dataset           = dataset,
        #     id                = id,
        #     dataset_correlate = dataset_correlate,
        #     intcovar          = intcovar
        # )

        data <- correlations
        data <- data[1:min(max_items, NROW(data)), ]

        ret <- list(correlations = data)

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = ret,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}

http_calc_correlation_plot_data <- function(request, response) {
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

        #NEW
        dataset <- api_get_dataset_by_id(dataset_id)
        dataset_correlate <-
            api_get_dataset_by_id(nvl(dataset_id_correlate, dataset_id))

        correlation <- api_calc_correlation_plot(
            dataset           = dataset,
            id                = id,
            dataset_correlate = dataset_correlate,
            id_correlate      = id_correlate,
            intcovar          = intcovar
        )

        # OLD
        # dataset <- qtl2api::get_dataset_by_id(dataset_id)
        # dataset_correlate <-
        #     qtl2api::get_dataset_by_id(nvl(dataset_id_correlate, dataset_id))
        #
        # correlation <- qtl2api::get_correlation_plot_data(
        #     dataset           = dataset,
        #     id                = id,
        #     dataset_correlate = dataset_correlate,
        #     id_correlate      = id_correlate,
        #     intcovar          = intcovar
        # )

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = correlation,
            time       = elapsed["elapsed"]
        )

        logger$info(paste0(request$path, "|", elapsed["elapsed"]))
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
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
        response$body <-
            yyjsonr::write_json_str(data, opts = yyjsonr::opts_write_json(auto_unbox = TRUE))
    })
}

application$add_get(
    path     = "/qtl2info",
    FUN      = http_qtl2_info,
    add_head = FALSE
)

application$add_get(
    path     = "/analysis",
    FUN      = http_get_analysis,
    add_head = FALSE
)

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
    FUN      = http_calc_rankings,
    add_head = FALSE
)

application$add_get(
    path     = "/idexists",
    FUN      = http_id_exists,
    add_head = FALSE
)

application$add_get(
    path     = "/lodscores",
    FUN      = http_calc_lod_scores,
    add_head = FALSE
)

application$add_get(
    path     = "/lodscoresbycovar",
    FUN      = http_calc_lod_scores_by_covar,
    add_head = FALSE
)

application$add_get(
    path     = "/foundercoefficients",
    FUN      = http_calc_founder_coefficients,
    add_head = FALSE
)

application$add_get(
    path     = "/expression",
    FUN      = http_get_expression,
    add_head = FALSE
)

application$add_get(
    path     = "/mediate",
    FUN      = http_calc_mediation,
    add_head = FALSE
)

application$add_get(
    path     = "/snpassocmapping",
    FUN      = http_calc_snp_assoc_mapping,
    add_head = FALSE
)

application$add_get(
    path     = "/correlation",
    FUN      = http_calc_correlation,
    add_head = FALSE
)

application$add_get(
    path     = "/correlationplot",
    FUN      = http_calc_correlation_plot_data,
    add_head = FALSE
)

