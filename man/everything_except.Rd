% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{everything_except}
\alias{everything_except}
\title{Get symbols for all columns except ...}
\usage{
everything_except(.DF, ..., .symbols = TRUE)
}
\arguments{
\item{.DF}{A data frame whose variable names are to be differenced.}

\item{...}{A string, strings, vector of strings, or list of strings representing column names to be subtracted from the names of \code{.DF}/}

\item{.symbols}{A boolean that defines the return type: \code{TRUE} for symbols, \code{FALSE} for strings.}
}
\value{
A vector of symbols (when \code{.symbols = TRUE}) or
strings (when \code{symbol = FALSE}) containing all variables names except those given in \code{...}.
}
\description{
This convenience function performs a set difference between
the columns of \code{.DF} and the variable names (or symbols) given in \code{...}.
}
\examples{
DF <- data.frame(a = c(1, 2), b = c(3, 4), c = c(5, 6))
everything_except(DF, "a", "b")
everything_except(DF, "a", "b", symbols = FALSE)
everything_except(DF, c("a", "b"))
everything_except(DF, list("a", "b"))
}
