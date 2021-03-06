% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{add_UKEnergy2000_row_col_meta}
\alias{add_UKEnergy2000_row_col_meta}
\title{Add row, column, row type, and column type metadata}
\usage{
add_UKEnergy2000_row_col_meta(
  .DF,
  matname_colname = "matname",
  U_name = "U",
  V_name = "V",
  Y_name = "Y",
  product_colname = "Product",
  flow_colname = "Flow",
  industry_type = "Industry",
  product_type = "Product",
  sector_type = "Sector",
  rowname_colname = "rowname",
  colname_colname = "colname",
  rowtype_colname = "rowtype",
  coltype_colname = "coltype"
)
}
\arguments{
\item{.DF}{a data frame containing \code{matname_colname}.}

\item{matname_colname}{the name of the column in \code{.DF} that contains names of matrices
(a string).  Default is "\code{matname}".}

\item{U_name}{the name for use matrices (a string). Default is "\code{U}".}

\item{V_name}{the name for make matrices (a string). Default is "\code{V}".}

\item{Y_name}{the name for final demand matrices (a string). Default is "\code{Y}".}

\item{product_colname}{the name of the column in \code{.DF} where Product names
is found (a string). Default is "\code{Product}".}

\item{flow_colname}{the name of the column in \code{.DF} where Flow information is found
(a string).
The Flow column usually contains the industries involved in this flow.
Default is "\code{Flow}".}

\item{industry_type}{the name that identifies production industries and
and transformation processes (a string). Default is "\code{Industry}".}

\item{product_type}{the name that identifies energy carriers (a string).
Default is "\code{Product}".}

\item{sector_type}{the name that identifies final demand sectors (a string).
Default is "\code{Sector}".}

\item{rowname_colname}{the name of the output column that contains row names for matrices
(a string). Default is "\code{rowname}".}

\item{colname_colname}{the name of the output column that contains column names for matrices
(a string). Default is "\code{colname}".}

\item{rowtype_colname}{the name of the output column that contains row types for matrices
(a string). Default is "\code{rowtype}".}

\item{coltype_colname}{the name of the output column that contains column types for matrices
(a string). Default is "\code{coltype}".}
}
\value{
\code{.DF} with additional columns named
\code{rowname_colname}, \code{colname_colname},
\code{rowtype_colname}, and \code{coltype_colname}.
}
\description{
Add row, column, row type, and column type metadata
}
\examples{
UKEnergy2000 \%>\%
  matsindf:::add_UKEnergy2000_matnames(.) \%>\%
  matsindf:::add_UKEnergy2000_row_col_meta(.)
}
