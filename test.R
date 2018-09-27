library(devtools)

load_all()

x = matrix(runif(10000)*100, ncol = 100)
y = matrix(runif(10000)*100, ncol = 100)
# rownames(x) = rownames(y) = letters[seq_len(nrow(x))]
# colnames(x) = colnames(y) = letters[seq_len(ncol(x))]

x.df = reshape2::melt(x)

print(ggheatmap(x.df, show.values = TRUE, type = "complete", range = c(10, 70)))

pl = ggheatmap(list(Bla = x, Blu = y), value.name = "Correlation")# + theme_void()
# print(pl)
