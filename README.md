# ggheatmap: Elegant Heatmaps with ggplot2

[![CRAN Status Badge](http://www.r-pkg.org/badges/version/ggheatmap)](http://cran.r-project.org/web/packages/ggheatmap)
[![CRAN Downloads](http://cranlogs.r-pkg.org/badges/ggheatmap)](http://cran.rstudio.com/web/packages/ggheatmap/index.html)
[![CRAN Downloads](http://cranlogs.r-pkg.org/badges/grand-total/ggheatmap?color=orange)](http://cran.rstudio.com/web/packages/ggheatmap/index.html)
[![Build Status](https://travis-ci.org/jakobbossek/ggheatmap.svg?branch=master)](https://travis-ci.org/jakobbossek/ggheatmap)
[![Build status](https://ci.appveyor.com/api/projects/status/eu0nns2dsgocwntw/branch/master?svg=true)](https://ci.appveyor.com/project/jakobbossek/ggheatmap/branch/master)
[![Coverage Status](https://coveralls.io/repos/github/jakobbossek/ggheatmap/badge.svg?branch=master)](https://coveralls.io/github/jakobbossek/ggheatmap?branch=master)
[![Research software impact](http://depsy.org/api/package/cran/ggheatmap/badge.svg)](http://depsy.org/package/r/ggheatmap)

## What is this all about?

The package offers a single exported function, namely `ggheatmap`, which takes a data frame, a matrix or a (named) list of matrices and generates a nice heatmap with [ggplot2](https://ggplot2.tidyverse.org).

```r
library(ggheatmap)

data(mtcars)
cor.mat = cor(mtcars)

# Basic heatmap
pl = ggheatmap::ggheatmap(cor.mat)

# Customized heatmap
pl = ggheatmap::ggheatmap(cor.mat, type = "lower.tri", show.diag = FALSE, show.values = TRUE, digits = 1L)

# Now we simulate two non-square matrices
x = matrix(runif(50L), ncol = 5L)
y = matrix(runif(50L), ncol = 5L)

pl = ggheatmap::ggheatmap(list(X = x, Y = y), range = c(0.1, 0.9), value.name = "Range")
```

## Installation Instructions

The package will be available at [CRAN](http://cran.r-project.org) soon. Install the release version via:
```r
install.packages("ggheatmap")
```
If you are interested in trying out and playing around with the current github developer version use the [devtools](https://github.com/hadley/devtools) package and type the following command in R:

```r
devtools::install_github("jakobbossek/ggheatmap")
```

## Contact

Please address questions and missing features about the **ggheatmap** to the author Jakob Bossek <j.bossek@gmail.com>. Found some nasty bugs? Please use the [issue tracker](https://github.com/jakobbossek/ggheatmap/issues) for this. Pay attention to explain the problem as good as possible. At its best you provide an example, so I can reproduce your problem quickly.



