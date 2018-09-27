#' @title Plot heatmap.
#'
#' @description Given a data frame, a matrix or a list of matrices this function
#' visualizes the given data by a heatmap utilizing \pkg{ggplot2}.
#'
#' @param x [\code{matrix} | \code{list of matrices} | \code{data.frame}]\cr
#'   Data frame, matrix or a list of matrices.
#' @param value.name [\code{character(1)}]\cr
#'   Name for the values represented by the matrix.
#'   Internally, the matrix is transformed into a \code{data.frame}
#'   via \code{\link[reshape2]{melt}} in order to obtain a format
#'   which may be processed by \code{\link[ggplot2]{ggplot}} easily.
#'   Default is \dQuote{value}.
#' @param show.diag [\code{logical(1)}]\cr
#'   If \code{x} is a square matrix, e.g., a correlation matrix, or \code{x} is
#'   a list of square matrices this argument controls whether the diagonal elements
#'   should be visualized.
#'   Default is \code{TRUE}.
#' @param type [\code{character(1)}]|cr
#'   Values \dQuote{lower.tri} and \dQuote{upper.tri} respectively display the lower
#'   or upper triangular matrix only. Option \dQuote{complete} is the default and
#'   displays all values.
#'   This option is ignored if \code{x} is already a data frame or the passed
#'   matrix/matrices are not square.
#' @param range [\code{numeric(2)}]\cr
#'   Possibility to cap values below \code{range[1]} and above \code{range[2]}.
#'   Defaults to \code{NULL}, i.e., no capping at all.
#' @param show.values [\code{logical(1L)}]\cr
#'   Should the values be printed within the heatmap cells?
#'   Default is \code{FALSE}.
#' @param value.size [\code{numeric(1)}]\cr
#'   Size of the printed values.
#'   Only relevant if \code{show.values} is \code{TRUE}.
#'   Default is 1.5.
#' @param value.color [\code{character(1)}]\cr
#'   Color of text in cells.
#'   Only relevant if \code{show.values} is \code{TRUE}.
#'   Default is \dQuote{white}.
#' @return [\code{\link[ggplot2]{ggplot}}] ggplot object.
#' @examples
#' # simulate two (correlation) matrizes
#' x = matrix(runif(100), ncol = 10)
#' y = matrix(runif(100), ncol = 10)
#'
#' # matrix x in ggplot2-friendly long format
#' x.df = reshape2::melt(x)
#'
#' \dontrun{
#' # Single heatmap with default settings
#' pl = plotHeatmap(x.df)
#'
#' # Show values and display lower triangular matrix only
#' pl = plotHeatmap(x, show.values = TRUE, type = "lower.tri", show.diag = FALSE)
#'
#' # Now we omit value outside the interval [10, 80]
#' pl = plotHeatmap(x, range = c(10, 80))
#'
#' # Two heatmaps side by side
#' pl = plotHeatmap(list(x, y), value.name = "Similarity")
#'
#' # Same as above with custom names
#' pl = plotHeatmap(list(MatrixX = x, MatrixY = y), value.name = "Similarity")
#'
#' }
#' @export
ggheatmap = function(x, value.name = "value", show.diag = TRUE, type = "complete", range = NULL, show.values = FALSE, value.size = 1.5, value.color = "white") {
  checkmate::assertString(value.name)
  checkmate::assertFlag(show.values)
  checkmate::assertNumber(value.size, lower = 0.1)
  checkmate::assertString(value.color)

  ggdf = x
  if (!is.data.frame(ggdf))
    ggdf = reshapeToLongFormat(ggdf, value.name = value.name, show.diag = show.diag, type = type, range = range)

  # plot heatmap
  pl = ggplot2::ggplot(ggdf, ggplot2::aes_string(x = "Var1", y = "Var2"))
  pl = pl + ggplot2::geom_tile(ggplot2::aes_string(fill = value.name), color = "white", size = 0.1)

  # workaround to get rounded values
  if (show.values) {
    ggdf2 = ggdf
    ggdf2[[value.name]] = round(ggdf2[[value.name]], 1L)
    pl = pl + ggplot2::geom_text(data = ggdf2, ggplot2::aes_string(label = value.name), color = value.color, size = value.size)
  }

  pl = pl + ggplot2::coord_equal()

  # split if multiple problems available
  if (!is.null(ggdf$prob))
    pl = pl + ggplot2::facet_wrap(~ prob, nrow = 1L)#, scales = "free")

  # default layout
  val.range = range(ggdf[[value.name]])
  breaks = seq(val.range[1L], val.range[2L], length.out = 5L)
  pl = pl + viridis::scale_fill_viridis(
    #breaks = breaks,
    #guide = guide_legend(keyheight = unit(10, units = "mm"), keywidth=unit(10, units = "mm"), label.position = "bottom", title.position = 'top', nrow=1)
  )
  pl = pl + ggplot2::theme(
    axis.ticks = ggplot2::element_blank(),
    axis.text = ggplot2::element_text(size = 7),
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    legend.position = "top")
  pl = pl + ggplot2::xlab("") + ggplot2::ylab("")
  return(pl)
}

reshapeToLongFormat = function(x, value.name = "Value", show.diag = TRUE, type = "full", range = NULL) {
  checkmate::assertFlag(show.diag)
  checkmate::assertChoice(type, choices = c("complete", "lower.tri", "upper.tri"))
  checkmate::assertNumeric(range, len = 2L, null.ok = TRUE)

  if (!is.list(x))
    x = list(x)
  checkmate::assertList(x, types = "matrix", any.missing = FALSE, all.missing = FALSE)

  is.square = function(x) {
    dims = dim(x)
    dims[1L] == dims[2L]
  }

  prepare = function(x, is.square) {
    # values outside range
    if (!is.null(range)) {
      x[x < range[1L] | x > range[2L]] = NA
    }
    if (is.square) {
      # values on diagonal
      if (!show.diag) {
        x[diag(x)] = NA
      }
      # values on upper/lower half
      if (type == "lower.tri") {
        x[upper.tri(x)] = NA
      } else if (type == "upper.tri") {
        x [lower.tri(x)] = NA
      }
    }
    return(x)
  }

  n.maps = length(x)

  # check if all passed matrices share the same dimensions
  all.equal.dims = sum(!duplicated(t(sapply(x, dim))))
  if (all.equal.dims != 1L) {
    stop("[ggheatmap] All matrices must have the same dimensions!")
  }

  # check if matrices are square
  is.square = all(vapply(x, is.square, logical(1L)))
  x = lapply(x, prepare, is.square)

  # check naming
  ns = names(x)
  if (is.null(ns))
    ns = as.character(seq_len(n.maps))
  if (any(ns == ""))
    stop("[ggheatmap] Either all or none elements of passed list must be named.")

  ggdf = do.call(rbind, lapply(seq_len(n.maps), function(i) {
    tmp = x[[i]]
    tmp = convertToGG(tmp, value.name = value.name, na.rm = TRUE)
    tmp$prob = ns[i]
    return(tmp)
  }))
  if (n.maps == 1L)
    ggdf$prob = NULL

  return(ggdf)
}
