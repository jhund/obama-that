setwd("~/Dropbox/code/obama-that")

library(ggplot2)

# Plot individual distributions

x = seq(0, 1, by = 0.0001)
y_delivered = dbeta(x, 1240, 48219)
y_prepared = dbeta(x, 113, 8190)

qplot(x, y_delivered, geom = "line", main = "P(that-frequency in delivered data = q | delivered data) ~ Beta(1240, 48219)", xlab = "q", ylab = "density")
qplot(x, y_prepared, geom = "line", main = "P(that-frequency in prepared data = r | prepared data) ~ Beta(113, 8190)", xlab = "r", ylab = "density")

d = data.frame(x = c(x, x), y = c(y_delivered, y_prepared), which = rep(c("delivered", "prepared"), each = length(x)))
qplot(x, y, colour = which, data = d, geom = "line", xlim = c(0, 0.04), ylab = "density")

# Simulate the difference

delivered_sim = rbeta(10000, 1240, 48219)
prepared_sim = rbeta(10000, 113, 8190)
diff = delivered_sim - prepared_sim

qplot(diff, geom = "density", xlab = "q - r", xlim = c(0, 1))

mean(diff) # 0.01147737
length(diff[diff > 0]) / length(diff) # 1.0