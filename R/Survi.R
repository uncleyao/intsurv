################################################################################
##
##   R package intsurv by Wenjie Wang, Kun Chen and Jun Yan
##   Copyright (C) 2017
##
##   This file is part of the R package intsurv.
##
##   The R package intsurv is free software: You can redistribute it and/or
##   modify it under the terms of the GNU General Public License as published
##   by the Free Software Foundation, either version 3 of the License, or
##   any later version (at your option). See the GNU General Public License
##   at <http://www.gnu.org/licenses/> for details.
##
##   The R package intsurv is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
##
################################################################################


## collation after class.R
##' @include class.R
NULL


##' Formula Response for Survival Data With Uncertainty
##'
##' \code{Survi} returns an S4 class that represents formula response for
##' survival data with uncertain records due to imperfect data integration.  The
##' last letter 'i' in \code{Survi} represents 'integration'.
##'
##' @param ID Identificator of each subject.
##' @param time Time of reccurence event or censoring.
##' @param event The status indicator, 0 = censored, 1 = event.
##' @param check A logical value specifying whether to perform check on input
##'     data.
##' @param ... Other arguments for future usage.
##' @aliases Survi
##' @export
Survi <- function(ID, time, event, check = TRUE, ...)
{
    ## some quick checks
    if (missing(ID))
        stop("'ID' cannot be missing.")
    if (any(is.na(ID)))
        stop("'ID' cannot be missing.")
    if (missing(time))
        stop("'time' cannot be missing.")
    if (! is.numeric(time))
        stop("'time' has to be numeric.")
    if (missing(event))
        stop("'event' cannot be missing.")
    event <- as.integer(event)
    if (any(! event %in% c(0, 1)))
        stop("'event' must be coded as 0 (censoring) or 1 (event).")

    dat <- data.frame(ID, time, event)
    if (check)
        dat <- check_Survi(dat)
    ## convert IDs to numeric and save original IDs in attributes (slot)
    id0 <- as.character(dat$ID)
    dat$ID <- as.numeric(factor(dat$ID, levels = unique(id0)))
    mat <- with(dat, as.matrix(cbind(ID, time, event)))
    methods::new("Survi", mat,
                 ID = id0,
                 time = time,
                 event = event)
}



### internal functions =========================================================
check_Survi <- function(dat)
{
    ## check 0: event or censoring times cannot contain missing values
    idx0 <- is.na(dat$time)
    if (any(idx0))
        stop("'time' cannot contain missing values.",
             "\nPlease check subject:",
             paste(unique(sDat$ID[idx0]), collapse = ", "))

    ## check 1: each subject has at most one censoring time later than events
    sDat <- dat[with(dat, order(ID, time, 1L - event)), ]
    dupIdx <- duplicated(sDat$ID, fromLast = TRUE)
    cenIdx <- sDat$event != 1L
    idx1 <- dupIdx & cenIdx
    if (any(idx1))
        stop("Every subject must have at most one censored time",
             "later than all the possible event times.",
             "\nPlease check subject:",
             paste(unique(sDat$ID[idx1]), collapse = ", "))
    dat
}
