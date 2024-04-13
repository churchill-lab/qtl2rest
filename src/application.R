#
# application.R
#

library(RestRserve)
library(jsonlite)
library(yyjsonr)
library(tictoc)
library(memCompression)
library(magrittr)

middleware_gzip <- Middleware$new(
    process_response = function(request, response) {
        enc = request$get_header("Accept-Encoding")

        if ("gzip" %in% enc) {
            response$set_header("Content-Encoding", "gzip")
            response$set_header("Vary", "Accept-Encoding")
            #tic('charToRaw')
            raw <- charToRaw(response$body)
            #toc()

            #tic('memCompression')
            response$set_body(memCompression::compress(raw, "gzip"))
            #toc()
            response$encode = identity
        }
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

application$append_middleware(middleware_gzip)

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



log_error <- function(error, request) {
    param_string <- paste(
        names(request$parameters_query),
        request$parameters_query,
        sep="=",
        collapse="&")

    logger$error(paste0(request$path, "|", param_string, "|", error))
}


