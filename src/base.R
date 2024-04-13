#
# base.R
#

library(qtl2api)

# define the default functionality
api_get_analysis <- function(...) qtl2api::get_analysis(...)
api_get_dataset_info <- function(...) qtl2api::get_dataset_info(...)
api_get_dataset_stats <- function(...) qtl2api::get_dataset_stats(...)
api_get_dataset_by_id <- function(...) qtl2api::get_dataset_by_id(...)
api_get_expression <- function(...) qtl2api::get_expression(...)
api_get_lod_peaks_dataset <- function(...) qtl2api::get_lod_peaks(...)
api_get_markers <- function(...) qtl2api::get_markers(...)
api_get_qtl2api_version <- function(...) qtl2api::version(...)

api_calc_correlation <- function(...) qtl2api::calc_correlation(...)
api_calc_correlation_plot <- function(...) qtl2api::calc_correlation_plot(...)
api_calc_founder_coefficients <- function(...) qtl2api::calc_founder_coefficients(...)
api_calc_mediation <- function(...) qtl2api::calc_mediation(...)
api_calc_lod_scores <- function(...) qtl2api::calc_lod_scores(...)
api_calc_lod_scores_by_covar <- function(...) qtl2api::calc_lod_scores_by_covar(...)
api_calc_rankings <- function(...) qtl2api::calc_rankings(...)
api_calc_snp_assoc_mapping <- function(...) qtl2api::calc_snp_assoc_mapping(...)

api_id_exists <- function(...) qtl2api::id_exists(...)

qtl2_info <- function() {
    version_packages <- tibble::as_tibble(installed.packages()) |>
        dplyr::select(Package, Version) |>
        dplyr::filter(
            stringr::str_like(Package, "qtl2%") | stringr::str_like(Package, "Rest%")
        )

    return(list(
        version_packages = version_packages,
        version_R        = R.version.string
    ))
}

