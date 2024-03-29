test_that("small example works as expected", {
  tidy <- tibble::tibble(matrix = c("V1", "V1", "V1", "V2", "V2"),
                 row = c("i1", "i1", "i2", "i1", "i2"),
                 col = c("p1", "p2", "p2", "p1", "p2"),
                 vals = c(1, 2, 3, 4, 5)) |>
    dplyr::mutate(
      rowtypes = "Industries",
      coltypes  = "Products"
    )
  # Group on too many columns and expect an error.
  expect_error(collapse_to_matrices(tidy |> dplyr::group_by(matrix, row),
                                    matnames = "matrix", matvals = "vals",
                                    rownames = "row", colnames = "col",
                                    rowtypes = "rowtypes", coltypes = "coltypes"),
               "row is/are grouping variable/s. Cannot group on rownames, colnames, rowtypes, coltypes, or matvals in argument .DF of collapse_to_matrices.")
  # Try with NULL rowtypes but non-NULL coltypes and expect an error.
  expect_error(collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                    matnames = "matrix", matvals = "vals",
                                    rownames = "row", colnames = "col",
                                    rowtypes = NULL, coltypes = "coltypes"),
               "One of rowtypes or coltypes was non-NULL while the other was NULL. Both need to be NULL or both need to be non-NULL in collapse_to_matrices.")
  # Try with NULL coltypes but non-NULL rowtypes and expect an error.
  expect_error(collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                    matnames = "matrix", matvals = "vals",
                                    rownames = "row", colnames = "col",
                                    rowtypes = "rowtypes", coltypes = NULL),
               "One of rowtypes or coltypes was non-NULL while the other was NULL. Both need to be NULL or both need to be non-NULL in collapse_to_matrices.")
  # Group on the right things and expect success.
  mats <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                               matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               rowtypes = "rowtypes", coltypes = "coltypes")
  # Check that groups are discarded.
  expect_equal(length(dplyr::group_vars(mats)), 0)
  # Check that factors are not created for String columns.
  expect_false(is.factor(mats$matrix))
  # Test for V1
  expect_equal(mats$vals[[1]], matrix(c(1, 2, 0, 3), nrow = 2, ncol = 2, byrow = TRUE,
                                      dimnames = list(c("i1", "i2"), c("p1", "p2"))) |>
                 matsbyname::setrowtype("Industries") |> matsbyname::setcoltype("Products"))
  # Test for V2
  expect_equal(mats$vals[[2]], matrix(c(4, 0, 0, 5), nrow = 2, ncol = 2, byrow = TRUE,
                                      dimnames = list(c("i1", "i2"), c("p1", "p2"))) |>
                 matsbyname::setrowtype("Industries") |> matsbyname::setcoltype("Products"))
  # Now expand everything back out, just for good measure
  tidy2 <- mats |>
    expand_to_tidy(matnames = "matrix", matvals = "vals",
                   rownames = "row", colnames = "col",
                   rowtypes = "rowtypes", coltypes = "coltypes", drop = 0) # |>
  # No need to convert to factors. R4.0.0 has stringsAsFactors = FALSE by default.
  # dplyr::mutate(
  #   # The original tidy data frame had factors
  #   row = as.factor(row),
  #   col = as.factor(col)
  # )
  expect_equal(tidy2, tidy)

  # Try the test when we are missing the rowtype and coltype columns
  tidy_trimmed <- tidy |>
    dplyr::mutate(
      rowtypes = NULL,
      coltypes = NULL
    )
  mats_trimmed <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                       matnames = "matrix", matvals = "vals",
                                       rownames = "row", colnames = "col",
                                       rowtypes = NULL, coltypes = NULL)
  # Test for V1
  expect_equal(mats_trimmed$vals[[1]], matrix(c(1, 2, 0, 3), nrow = 2, ncol = 2, byrow = TRUE,
                                              dimnames = list(c("i1", "i2"), c("p1", "p2"))))
  # Test for V2
  expect_equal(mats_trimmed$vals[[2]], matrix(c(4, 0, 0, 5), nrow = 2, ncol = 2, byrow = TRUE,
                                              dimnames = list(c("i1", "i2"), c("p1", "p2"))))
})


test_that("small example works with Matrix objects", {
  tidy <- tibble::tibble(matrix = c("V1", "V1", "V1", "V2", "V2"),
                         row = c("i1", "i1", "i2", "i1", "i2"),
                         col = c("p1", "p2", "p2", "p1", "p2"),
                         vals = c(1, 2, 3, 4, 5)) |>
    dplyr::mutate(
      rowtypes = "Industries",
      coltypes  = "Products"
    )
  # Group on too many columns and expect an error.
  expect_error(collapse_to_matrices(tidy |> dplyr::group_by(matrix, row),
                                    matnames = "matrix", matvals = "vals",
                                    rownames = "row", colnames = "col",
                                    rowtypes = "rowtypes", coltypes = "coltypes",
                                    matrix_class = "Matrix"),
               "row is/are grouping variable/s. Cannot group on rownames, colnames, rowtypes, coltypes, or matvals in argument .DF of collapse_to_matrices.")
  # Try with NULL rowtypes but non-NULL coltypes and expect an error.
  expect_error(collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                    matnames = "matrix", matvals = "vals",
                                    rownames = "row", colnames = "col",
                                    rowtypes = NULL, coltypes = "coltypes",
                                    matrix_class = "Matrix"),
               "One of rowtypes or coltypes was non-NULL while the other was NULL. Both need to be NULL or both need to be non-NULL in collapse_to_matrices.")
  # Try with NULL coltypes but non-NULL rowtypes and expect an error.
  expect_error(collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                    matnames = "matrix", matvals = "vals",
                                    rownames = "row", colnames = "col",
                                    rowtypes = "rowtypes", coltypes = NULL,
                                    matrix_class = "Matrix"),
               "One of rowtypes or coltypes was non-NULL while the other was NULL. Both need to be NULL or both need to be non-NULL in collapse_to_matrices.")
  # Group on the right things and expect success.
  mats <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                               matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               rowtypes = "rowtypes", coltypes = "coltypes",
                               matrix_class = "Matrix")
  # Check that groups are discarded.
  expect_equal(length(dplyr::group_vars(mats)), 0)
  # Check that factors are not created for String columns.
  expect_false(is.factor(mats$matrix))
  # Test for V1
  expect_true(matsbyname::equal_byname(mats$vals[[1]],
                                       Matrix::sparseMatrix(i = c(1, 1, 2),
                                                            j = c(1, 2, 2),
                                                            x = c(1, 2, 3),
                                                            dims = c(2, 2),
                                                            dimnames = list(c("i1", "i2"), c("p1", "p2"))) |>
                                         matsbyname::setrowtype("Industries") |> matsbyname::setcoltype("Products")))
  # Test for V2
  expect_true(matsbyname::equal_byname(mats$vals[[2]],
                                       Matrix::sparseMatrix(i = c(1, 2),
                                                            j = c(1, 2),
                                                            x = c(4, 5),
                                                            dims = c(2, 2),
                                                            dimnames = list(c("i1", "i2"), c("p1", "p2"))) |>
                                         matsbyname::setrowtype("Industries") |> matsbyname::setcoltype("Products")))

  # Now expand everything back out, just for good measure
  tidy2 <- mats |>
    expand_to_tidy(matnames = "matrix", matvals = "vals",
                   rownames = "row", colnames = "col",
                   rowtypes = "rowtypes", coltypes = "coltypes", drop = 0) # |>
  # No need to convert to factors. R4.0.0 has stringsAsFactors = FALSE by default.
  # dplyr::mutate(
  #   # The original tidy data frame had factors
  #   row = as.factor(row),
  #   col = as.factor(col)
  # )
  expect_equal(tidy2, tidy)

  # Try the test when we are missing the rowtype and coltype columns
  tidy_trimmed <- tidy |>
    dplyr::mutate(
      rowtypes = NULL,
      coltypes = NULL
    )
  mats_trimmed <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                       matnames = "matrix", matvals = "vals",
                                       rownames = "row", colnames = "col",
                                       rowtypes = NULL, coltypes = NULL,
                                       matrix_class = "Matrix")
  # Test for V1
  expect_true(matsbyname::equal_byname(mats_trimmed$vals[[1]],
                                       Matrix::sparseMatrix(i = c(1, 1, 2),
                                                            j = c(1, 2, 2),
                                                            x = c(1, 2, 3),
                                                            dims = c(2, 2),
                                                            dimnames = list(c("i1", "i2"), c("p1", "p2")))))
  # Test for V2
  expect_true(matsbyname::equal_byname(mats_trimmed$vals[[2]],
                                       # matsbyname::Matrix(c(4, 0, 0, 5), nrow = 2, ncol = 2, byrow = TRUE,
                                       #                    dimnames = list(c("i1", "i2"), c("p1", "p2"))))
                                       Matrix::sparseMatrix(i = c(1, 2),
                                                            j = c(1, 2),
                                                            x = c(4, 5),
                                                            dims = c(2, 2),
                                                            dimnames = list(c("i1", "i2"), c("p1", "p2")))))
})


test_that("collapse_to_matrices() works as expected", {
  ptype <- "Products"
  itype <- "Industries"
  tidy <- data.frame(Country  = c("GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "US",  "US",  "US",  "US", "GH", "US"),
                     Year     = c(1971,  1971,  1971,  1971,  1971,  1971,  1971,  1980,  1980,  1980,  1980, 1971, 1980),
                     matrix   = c("U",  "U",  "Y",  "Y",  "Y",  "V",  "V",  "U",  "U",  "Y",  "Y", "eta", "eta"),
                     row      = c("p1", "p2", "p1", "p2", "p2", "i1", "i2", "p1", "p1", "p1", "p2",   NA,    NA),
                     col      = c("i1", "i2", "i1", "i2", "i3", "p1", "p2", "i1", "i2", "i1", "i2",   NA,    NA),
                     rowtypes = c(ptype, ptype, ptype, ptype, ptype, itype, itype, ptype, ptype, ptype, ptype, NA, NA),
                     coltypes = c(itype, itype, itype, itype, itype, ptype, ptype, itype, itype, itype, itype, NA, NA),
                     vals     = c(11  ,  22,    11 ,   22 ,   23 ,   11 ,   22 ,   11 ,   12 ,   11 ,   22,   0.2, 0.3),
                     stringsAsFactors = FALSE) |>
    dplyr::group_by(Country, Year, matrix)
  mats <- collapse_to_matrices(tidy, matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               rowtypes = "rowtypes", coltypes = "coltypes")
  A <- matrix(c(11, 0,
                0, 22),
              nrow = 2, ncol = 2, byrow = TRUE,
              dimnames = list(c("p1", "p2"), c("i1", "i2"))) |>
    matsbyname::setrowtype("Products") |> matsbyname::setcoltype("Industries")

  # Check that the single values turned out OK
  expect_equal((mats |> dplyr::filter(Country == "GH", matrix == "eta"))$vals[[1]], 0.2 )
  expect_equal((mats |> dplyr::filter(Country == "US", matrix == "eta"))$vals[[1]], 0.3 )

  # Check that GH U turned out OK
  expect_equal((mats |> dplyr::filter(Country == "GH", matrix == "U"))$vals[[1]], A)
  # Check that US U turned out OK
  expect_equal((mats |> dplyr::filter(Country == "US", matrix == "U"))$vals[[1]],
               matrix(c(11, 12),
                      nrow = 1, ncol = 2, byrow = TRUE,
                      dimnames = list(c("p1"), c("i1", "i2"))) |>
                 matsbyname::setrowtype("Products") |> matsbyname::setcoltype("Industries"))
  # Check that GH V turned out OK
  expect_equal((mats |> dplyr::filter(Country == "GH", matrix == "V"))$vals[[1]], A |> matsbyname::transpose_byname())
  # Check that GH Y turned out OK
  expect_equal((mats |> dplyr::filter(Country == "GH", matrix == "Y"))$vals[[1]],
               matrix(c(11, 0, 0,
                        0, 22, 23),
                      nrow = 2, ncol = 3, byrow = TRUE,
                      dimnames = list(c("p1", "p2"), c("i1", "i2", "i3"))) |>
                 matsbyname::setrowtype("Products") |> matsbyname::setcoltype("Industries"))
  # Check that US Y turned out OK
  expect_equal((mats |> dplyr::filter(Country == "US", matrix == "Y"))$vals[[1]], A)
  # Check that groups are discarded.
  expect_equal(length(dplyr::group_vars(mats)), 0)
})


test_that("collapse_to_matrices() works with Matrix objects", {
  ptype <- "Products"
  itype <- "Industries"
  tidy <- data.frame(Country  = c("GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "US",  "US",  "US",  "US", "GH", "US"),
                     Year     = c(1971,  1971,  1971,  1971,  1971,  1971,  1971,  1980,  1980,  1980,  1980, 1971, 1980),
                     matrix   = c("U",  "U",  "Y",  "Y",  "Y",  "V",  "V",  "U",  "U",  "Y",  "Y", "eta", "eta"),
                     row      = c("p1", "p2", "p1", "p2", "p2", "i1", "i2", "p1", "p1", "p1", "p2",   NA,    NA),
                     col      = c("i1", "i2", "i1", "i2", "i3", "p1", "p2", "i1", "i2", "i1", "i2",   NA,    NA),
                     rowtypes = c(ptype, ptype, ptype, ptype, ptype, itype, itype, ptype, ptype, ptype, ptype, NA, NA),
                     coltypes = c(itype, itype, itype, itype, itype, ptype, ptype, itype, itype, itype, itype, NA, NA),
                     vals     = c(11  ,  22,    11 ,   22 ,   23 ,   11 ,   22 ,   11 ,   12 ,   11 ,   22,   0.2, 0.3),
                     stringsAsFactors = FALSE) |>
    dplyr::group_by(Country, Year, matrix)
  mats <- collapse_to_matrices(tidy, matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               rowtypes = "rowtypes", coltypes = "coltypes",
                               matrix_class = "Matrix")
  A <- Matrix::sparseMatrix(i = c(1, 2),
                            j = c(1, 2),
                            x = c(11, 22),
                            dims = c(2, 2),
                            dimnames = list(c("p1", "p2"), c("i1", "i2"))) |>
    matsbyname::setrowtype("Products") |> matsbyname::setcoltype("Industries")

  # Check that the single values turned out OK
  expect_equal((mats |> dplyr::filter(Country == "GH", matrix == "eta"))$vals[[1]], 0.2 )
  expect_equal((mats |> dplyr::filter(Country == "US", matrix == "eta"))$vals[[1]], 0.3 )

  # Check that GH U turned out OK
  expect_true(matsbyname::equal_byname((mats |> dplyr::filter(Country == "GH", matrix == "U"))$vals[[1]], A))
  # Check that US U turned out OK
  expect_true(matsbyname::equal_byname((mats |> dplyr::filter(Country == "US", matrix == "U"))$vals[[1]],
                                       Matrix::sparseMatrix(i = c(1, 1),
                                                            j = c(1, 2),
                                                            x = c(11, 12),
                                                            dims = c(1, 2),
                                                            dimnames = list(c("p1"), c("i1", "i2"))) |>
                                         matsbyname::setrowtype("Products") |> matsbyname::setcoltype("Industries")))
  # Check that GH V turned out OK
  expect_true(matsbyname::equal_byname((mats |> dplyr::filter(Country == "GH", matrix == "V"))$vals[[1]], A |> matsbyname::transpose_byname()))
  # Check that GH Y turned out OK
  expect_true(matsbyname::equal_byname((mats |> dplyr::filter(Country == "GH", matrix == "Y"))$vals[[1]],
                                       Matrix::sparseMatrix(i = c(1, 2, 2),
                                                            j = c(1, 2 ,3),
                                                            x = c(11, 22, 23),
                                                            dims = c(2, 3),
                                                            dimnames = list(c("p1", "p2"), c("i1", "i2", "i3"))) |>
                                         matsbyname::setrowtype("Products")|> matsbyname::setcoltype("Industries")))
  # Check that US Y turned out OK
  expect_true(matsbyname::equal_byname((mats |> dplyr::filter(Country == "US", matrix == "Y"))$vals[[1]], A))
  # Check that groups are discarded.
  expect_equal(length(dplyr::group_vars(mats)), 0)
})


test_that("collapse_to_matrices() works correctly when row and col types are NULL", {
  tidy <- tibble::tibble(matrix = c("V1", "V1", "V1", "V2", "V2"),
                         row = c("i1", "i1", "i2", "i1", "i2"),
                         col = c("p1", "p2", "p2", "p1", "p2"),
                         vals = c(1, 2, 3, 4, 5))

  mats <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                               matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               rowtypes = NULL, coltypes = NULL)

  expect_null(mats$vals[[1]] |> matsbyname::rowtype())
  expect_null(mats$vals[[1]] |> matsbyname::coltype())
  expect_null(mats$vals[[2]] |> matsbyname::rowtype())
  expect_null(mats$vals[[2]] |> matsbyname::coltype())

  # Now rely on the new default expressions for rowtypes and coltypes.
  mats2 <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                               matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col")

  expect_null(mats2$vals[[1]] |> matsbyname::rowtype())
  expect_null(mats2$vals[[1]] |> matsbyname::coltype())
  expect_null(mats2$vals[[2]] |> matsbyname::rowtype())
  expect_null(mats2$vals[[2]] |> matsbyname::coltype())
})


test_that("collapse_to_matrices() works correctly when row and col types are NULL in Matrix objects", {
  tidy <- tibble::tibble(matrix = c("V1", "V1", "V1", "V2", "V2"),
                         row = c("i1", "i1", "i2", "i1", "i2"),
                         col = c("p1", "p2", "p2", "p1", "p2"),
                         vals = c(1, 2, 3, 4, 5))

  mats <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                               matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               rowtypes = NULL, coltypes = NULL,
                               matrix_class = "Matrix")

  expect_null(mats$vals[[1]] |> matsbyname::rowtype())
  expect_null(mats$vals[[1]] |> matsbyname::coltype())
  expect_null(mats$vals[[2]] |> matsbyname::rowtype())
  expect_null(mats$vals[[2]] |> matsbyname::coltype())

  # Now rely on the new default expressions for rowtypes and coltypes.
  mats2 <- collapse_to_matrices(tidy |> dplyr::group_by(matrix),
                                matnames = "matrix", matvals = "vals",
                                rownames = "row", colnames = "col",
                                matrix_class = "Matrix")

  expect_null(mats2$vals[[1]] |> matsbyname::rowtype())
  expect_null(mats2$vals[[1]] |> matsbyname::coltype())
  expect_null(mats2$vals[[2]] |> matsbyname::rowtype())
  expect_null(mats2$vals[[2]] |> matsbyname::coltype())
})


test_that("new defaults for rowtypes and coltypes arguments works", {
  tidy <- data.frame(Country  = c("GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "US",  "US",  "US",  "US", "GH", "US"),
                     Year     = c(1971,  1971,  1971,  1971,  1971,  1971,  1971,  1980,  1980,  1980,  1980, 1971, 1980),
                     matrix   = c("U",  "U",  "Y",  "Y",  "Y",  "V",  "V",  "U",  "U",  "Y",  "Y", "eta", "eta"),
                     row      = c("p1", "p2", "p1", "p2", "p2", "i1", "i2", "p1", "p1", "p1", "p2",   NA,    NA),
                     col      = c("i1", "i2", "i1", "i2", "i3", "p1", "p2", "i1", "i2", "i1", "i2",   NA,    NA),
                     vals     = c(11  ,  22,    11 ,   22 ,   23 ,   11 ,   22 ,   11 ,   12 ,   11 ,   22,   0.2, 0.3)) |>
    dplyr::group_by(Country, Year, matrix)
  # Do not specify the rowtypes or coltypes arguments.
  # They should default to NULL.
  mats <- collapse_to_matrices(tidy, matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col") |>
    tidyr::pivot_wider(names_from = matrix, values_from = vals)
  expect_null(mats$U[[1]] |> matsbyname::rowtype())
  expect_null(mats$U[[2]] |> matsbyname::rowtype())
  expect_null(mats$V[[1]] |> matsbyname::rowtype())
  expect_null(mats$V[[2]])
  expect_null(mats$Y[[1]] |> matsbyname::rowtype())
  expect_null(mats$Y[[2]] |> matsbyname::rowtype())
})


test_that("new defaults for rowtypes and coltypes arguments work with Matrix objects", {
  tidy <- data.frame(Country  = c("GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "GH",  "US",  "US",  "US",  "US", "GH", "US"),
                     Year     = c(1971,  1971,  1971,  1971,  1971,  1971,  1971,  1980,  1980,  1980,  1980, 1971, 1980),
                     matrix   = c("U",  "U",  "Y",  "Y",  "Y",  "V",  "V",  "U",  "U",  "Y",  "Y", "eta", "eta"),
                     row      = c("p1", "p2", "p1", "p2", "p2", "i1", "i2", "p1", "p1", "p1", "p2",   NA,    NA),
                     col      = c("i1", "i2", "i1", "i2", "i3", "p1", "p2", "i1", "i2", "i1", "i2",   NA,    NA),
                     vals     = c(11  ,  22,    11 ,   22 ,   23 ,   11 ,   22 ,   11 ,   12 ,   11 ,   22,   0.2, 0.3)) |>
    dplyr::group_by(Country, Year, matrix)
  # Do not specify the rowtypes or coltypes arguments.
  # They should default to NULL.
  mats <- collapse_to_matrices(tidy, matnames = "matrix", matvals = "vals",
                               rownames = "row", colnames = "col",
                               matrix_class = "Matrix") |>
    tidyr::pivot_wider(names_from = matrix, values_from = vals)
  expect_null(mats$U[[1]] |> matsbyname::rowtype())
  expect_null(mats$U[[2]] |> matsbyname::rowtype())
  expect_null(mats$V[[1]] |> matsbyname::rowtype())
  expect_null(mats$V[[2]])
  expect_null(mats$Y[[1]] |> matsbyname::rowtype())
  expect_null(mats$Y[[2]] |> matsbyname::rowtype())
})


test_that("collapse_to_matrices() works with various matnames arguments", {
  tidy <- tibble::tibble(row = c("i1", "i1", "i2"),
                         col = c("p1", "p2", "p2"),
                         vals = c(1, 2, 3))

  # Try wtih NULL
  mats <- collapse_to_matrices(tidy, matnames = NULL,
                               matvals = "vals", rownames = "row", colnames = "col")
  expect_equal(mats$vals[[1]], matrix(c(1, 2,
                                        0, 3), byrow = TRUE, nrow = 2, ncol = 2,
                                      dimnames = list(c("i1", "i2"), c("p1", "p2"))))

  # Try with unspecified
  mats2 <- collapse_to_matrices(tidy, matvals = "vals", rownames = "row", colnames = "col")
  expect_equal(mats2$vals[[1]], matrix(c(1, 2,
                                         0, 3), byrow = TRUE, nrow = 2, ncol = 2,
                                       dimnames = list(c("i1", "i2"), c("p1", "p2"))))
})


test_that("collapse_to_matrices() works with various matnames arguments and Matrix objects", {
  tidy <- tibble::tibble(row = c("i1", "i1", "i2"),
                         col = c("p1", "p2", "p2"),
                         vals = c(1, 2, 3))

  # Try with NULL
  mats <- collapse_to_matrices(tidy, matnames = NULL,
                               matvals = "vals", rownames = "row", colnames = "col",
                               matrix_class = "Matrix")
  expect_true(matsbyname::equal_byname(mats$vals[[1]],
                                       Matrix::sparseMatrix(i = c(1, 1, 2),
                                                            j = c(1, 2, 2),
                                                            x = c(1, 2, 3),
                                                            dims = c(2, 2),
                                                            dimnames = list(c("i1", "i2"), c("p1", "p2")))))
  # Try with unspecified
  mats2 <- collapse_to_matrices(tidy, matvals = "vals", rownames = "row", colnames = "col",
                                matrix_class = "Matrix")
  expect_true(matsbyname::equal_byname(mats2$vals[[1]],
                                       Matrix::sparseMatrix(i = c(1, 1, 2),
                                                            j = c(1, 2, 2),
                                                            x = c(1, 2, 3),
                                                            dims = c(2, 2),
                                                            dimnames = list(c("i1", "i2"), c("p1", "p2")))))
})


test_that("collapse_to_matrices() deprecation is correct", {
  tidy <- tibble::tibble(row = c("i1", "i1", "i2"),
                         col = c("p1", "p2", "p2"),
                         vals = c(1, 2, 3))

  expect_warning(collapse_to_matrices(tidy, matnames = NULL,
                                      matvals = "vals", rownames = "row", colnames = "col",
                                      matrix.class = "matrix"))
})


# test_that("collapse_to_matrices() works quickly with large data frames", {
#   # Build a big data frame to collapse into small matrices
#   # n_mats <- 1000
#   n_mats <- 100
#   n_rows_mat <- 3
#   n_cols_mat <- 2
#   df <- data.frame(
#     rownames = paste0("r", 1:n_rows_mat) |>
#       rep(n_cols_mat) |> # in each matrix
#       rep(n_mats), # for all matrices
#     colnames = paste0("c", 1:n_cols_mat) |>
#       rep(n_rows_mat) |> # in each matrix
#       rep(n_mats), # for all matrices
#     matvals = 1:(n_rows_mat*n_cols_mat) |>
#       rep(n_mats),
#     matnames = paste0("m", 1:n_mats) |>
#       rep(n_rows_mat * n_cols_mat) |>
#       sort(),
#     rowtypes = "rtype",
#     coltypes = "ctype"
#   ) |>
#     dplyr::group_by(matnames)
#
#   exec_time_secs <- df |>
#     collapse_to_matrices(matrix_class = "Matrix") |>
#     system.time() |>
#     magrittr::extract2("user.self")
#   # As of 10 Jan 2024, it takes about 0.6 secs per 100 matrices.
#   # I want to get this much smaller, say to one tenth of the time
#   prev_time_per_matrix <- 0.6 / 100 # seconds/matrix
#   current_time_per_matrix <- exec_time_secs / n_mats
#   speedup <- prev_time_per_matrix / current_time_per_matrix
#   expect_true(speedup > 3)
# })
