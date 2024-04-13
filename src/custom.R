#
# customExample.R
#

http_get_time <- function(request, response) {
    result <- tryCatch({
        ptm <- proc.time()

        # defined in plugins.R
        theTime <- get_time()

        elapsed <- proc.time() - ptm

        data <- list(
            path       = request$path,
            parameters = request$parameters_query,
            result     = theTime,
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

application$add_get(
    path     = "/time",
    FUN      = http_get_time,
    add_head = FALSE
)



