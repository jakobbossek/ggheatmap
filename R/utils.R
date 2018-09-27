convertToGG = function(x, value.name = "value", ...) {
  rns = rownames(x)
  cns = colnames(x)
  x = as.data.frame(x)
  rownames(x) = rns
  colnames(x) = cns
  x = as.matrix(x)
  x = reshape2::melt(x, value.name = value.name, ...)
  return(x)
}
