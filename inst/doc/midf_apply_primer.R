## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(dplyr)
library(matsbyname)
library(matsindf)
library(tidyr)

## -----------------------------------------------------------------------------
example_fun <- function(a, b){
  return(list(c = matsbyname::sum_byname(a, b), 
              d = matsbyname::difference_byname(a, b)))
}

## -----------------------------------------------------------------------------
matsindf_apply(FUN = example_fun, a = 2, b = 1)

## -----------------------------------------------------------------------------
tryCatch(
  matsindf_apply(FUN = example_fun, a = 2, b = 1, z = 2),
  error = function(e){e}
)

## -----------------------------------------------------------------------------
tryCatch(
  matsindf_apply(FUN = example_fun, a = 2),
  error = function(e){e}
)

## -----------------------------------------------------------------------------
matsindf_apply(list(a = 2, b = 1), FUN = example_fun)

## -----------------------------------------------------------------------------
matsindf_apply(list(a = 2, b = 1, z = 42), FUN = example_fun)

## -----------------------------------------------------------------------------
matsindf_apply(list(a = 2, b = 1), FUN = example_fun, a = 10)

## -----------------------------------------------------------------------------
matsindf_apply(list(a = 2, b = 1, z = 42),
               FUN = example_fun, a = "z")

## -----------------------------------------------------------------------------
tryCatch(
  matsindf_apply(list(a = 2, b = 1, c = 42), FUN = example_fun),
  warning = function(w){w}
)

## -----------------------------------------------------------------------------
example_fun_with_string <- function(str_a, b) {
  a <- as.numeric(str_a)
  list(added = matsbyname::sum_byname(a, b), subtracted = matsbyname::difference_byname(a, b))
}

# Causes an error
tryCatch(
  matsindf_apply(FUN = example_fun_with_string, str_a = "1", b = 2),
  error = function(e){e}
)
# To solve the problem, wrap "1" in list().
matsindf_apply(FUN = example_fun_with_string, str_a = list("1"), b = 2)
matsindf_apply(FUN = example_fun_with_string, str_a = list("1"), b = list(2))
matsindf_apply(FUN = example_fun_with_string, 
               str_a = list("1", "3"), 
               b = list(2, 4))
matsindf_apply(.dat = list(str_a = list("1"), b = list(2)), FUN = example_fun_with_string)
matsindf_apply(.dat = list(m = list("1"), n = list(2)), FUN = example_fun_with_string, 
               str_a = "m", b = "n")

## -----------------------------------------------------------------------------
matsindf_apply(.dat = data.frame(str_a = c("1", "3"), b = c(2, 4)), 
               FUN = example_fun_with_string)
matsindf_apply(.dat = data.frame(str_a = c("1", "3"), b = c(2, 4)), 
               FUN = example_fun_with_string, 
               str_a = "str_a", b = "b")
matsindf_apply(.dat = data.frame(m = c("1", "3"), n = c(2, 4)), 
               FUN = example_fun_with_string, 
               str_a = "m", b = "n")

## -----------------------------------------------------------------------------
df <- data.frame(a = 2:4, b = 1:3)
matsindf_apply(df, FUN = example_fun)

## -----------------------------------------------------------------------------
# Create a tidy data frame containing data for matrices
tidy <- tibble::tibble(Year = rep(c(rep(2017, 4), rep(2018, 4)), 2),
                       matnames = c(rep("U", 8), rep("V", 8)),
                       matvals = c(1:4, 11:14, 21:24, 31:34),
                       rownames = c(rep(c(rep("p1", 2), rep("p2", 2)), 2), 
                                    rep(c(rep("i1", 2), rep("i2", 2)), 2)),
                       colnames = c(rep(c("i1", "i2"), 4), 
                                    rep(c("p1", "p2"), 4))) |>
  dplyr::mutate(
    rowtypes = case_when(
      matnames == "U" ~ "Product",
      matnames == "V" ~ "Industry", 
      TRUE ~ NA_character_
    ),
    coltypes = case_when(
      matnames == "U" ~ "Industry",
      matnames == "V" ~ "Product",
      TRUE ~ NA_character_
    )
  )

tidy

# Convert to a matsindf data frame
midf <- tidy |>  
  dplyr::group_by(Year, matnames) |> 
  collapse_to_matrices(rowtypes = "rowtypes", coltypes = "coltypes") |> 
  tidyr::pivot_wider(names_from = "matnames", values_from = "matvals")

# Take a look at the midf data frame and some of the matrices it contains.
midf
midf$U[[1]]
midf$V[[1]]

## -----------------------------------------------------------------------------
result <- midf |> 
  dplyr::mutate(
    W = difference_byname(transpose_byname(V), U)
  )
result
result$W[[1]]
result$W[[2]]

## -----------------------------------------------------------------------------
calc_W <- function(.DF = NULL, U = "U", V = "V", W = "W") {
  # The inner function does all the work.
  W_func <- function(U_mat, V_mat){
    # When we get here, U_mat and V_mat will be single matrices or single numbers, 
    # not a column in a data frame or an item in a list.
    if (length(U_mat) == 0 & length(V_mat == 0)) {
      # Tolerate zero-length arguments by returning a zero-length
      # a list with the correct name and return type.
      return(list(numeric()) |> magrittr::setnames(W))
    }
    # Calculate W_mat from the inputs U_mat and V_mat.
    W_mat <- matsbyname::difference_byname(
      matsbyname::transpose_byname(V_mat), 
      U_mat)
    # Return a named list.
    list(W_mat) |> magrittr::set_names(W)
  }
  # The body of the main function consists of a call to matsindf_apply
  # that specifies the inner function in the FUN argument.
  matsindf_apply(.DF, FUN = W_func, U_mat = U, V_mat = V)
}

## -----------------------------------------------------------------------------
midf |> calc_W()

## -----------------------------------------------------------------------------
midf |> calc_W(W = "W_prime")

## -----------------------------------------------------------------------------
midf |> 
  dplyr::rename(X = U, Y = V) |> 
  calc_W(U = "X", V = "Y")

## -----------------------------------------------------------------------------
calc_W(list(U = midf$U[[1]], V = midf$V[[1]]))

## -----------------------------------------------------------------------------
calc_W(U = midf$U[[1]], V = midf$V[[1]])

## -----------------------------------------------------------------------------
data.frame(U = c(1, 2), V = c(3, 4)) |> calc_W()

## -----------------------------------------------------------------------------
calc_W(U = 2, V = 3)

## -----------------------------------------------------------------------------
calc_W(U = numeric(), V = numeric())
calc_W(list(U = numeric(), V = numeric()))

res <- calc_W(list(U = c(2, 3, 4, 5), V = c(3, 4, 5, 6)))
res0 <- calc_W(list(U = numeric(), V = numeric()))
dplyr::bind_rows(res, res0)

