###Nadza Dzinalija Sept 2023

### Produces ridgeplots with ROIs in custom order, adapted from ridge function in RBA .RData file
### Is called by 9b_improve_RBA_ridge_plots_ROI.R

ridge_alphabet<-function (dat, range_file=NULL, xlim, labx, wi, hi) 
{
  library(data.table)
  library(ggplot2)
  library(ggridges)
  library(dplyr)
  library(tidyr)
  library(scales)
  library(ggtext)
  data <- data.frame(dat)
  data$X <- NULL
  nobj = dim(data)[1]
  rois <- dimnames(dat)[[2]]
  colnames(data) <- rois
  data_stats <- data.frame(1:length(rois))
  data_stats$ROI <- rois
  data_stats$mean <- colMeans(data)
  data_stats$P <- colSums(data > 0)/nobj
  data_stats$Pn <- ifelse(data_stats$P < 0.5, 1 - data_stats$P, 
                          data_stats$P)
  #data_stats <- data_stats[rev(data_stats$ROI), ]
  data_stats<- data_stats[seq(dim(data_stats)[1],1),]
  data_trans <- as.data.frame(t(as.matrix(data)))
  data_trans <- tibble::rownames_to_column(data_trans, "ROI")
  data_trans$X <- 1:nrow(data_trans)
  data_merge <- merge(data_stats, data_trans, by = "ROI")
  data_merge <- data_merge[order(data_merge$X), ]
  data_long <- reshape2::melt(data_trans, id = c("ROI", "X"))
  data_long <- data_long[order(data_long$X), ]
  data_long$mean <- rep(data_merge$mean, each = nobj)
  data_long$P <- rep(data_merge$P, each = nobj)
  data_long$Pn <- rep(data_merge$Pn, each = nobj)
  y.axis.labs <- sub("^[^-]*-","",data_stats$ROI)
  if (!is.null(range_file)) {
    range <- read.csv(range_file)
    i=1
    sec.y.axis.labs = c()
    for (ROI in y.axis.labs){
      P_min = range$Min_P[range$ROI==ROI]
      P_max = range$Max_P[range$ROI==ROI]
      #sec.y.axis.labs[i] <- paste0(round(data_stats$P[i], 2)," (", P_min ,"-", P_max,")")
      sec.y.axis.labs[i] <- paste0("**", round(data_stats$P[i], 2), "** (", P_min ,"-", P_max,")")
      i = i + 1
    }
  } else {
    sec.y.axis.labs = round(data_stats$P, 2)
    #sec.y.axis.labs = paste0("**", round(data_stats$P, 2), "**")
  }
  x.axis.labs <- NULL
  x.labs.pos <- NULL
  graph.title <- "D (% signal change)"
  legend.title <- "P+"
  y.axis.title <- NULL
  x.axis.title <- NULL
  dataset <- data_long
  x.values <- dataset$value
  y.values <-  rev(as.numeric(sub("-.*", "", dataset$ROI)))
  #y.values <- rev(as.numeric(gsub("\\D", "", dataset$ROI)))
  distrib.fill <- dataset$P
  group <- sort(dataset$ROI)
  dpi <- 500
  units <- "in"
  file.type <- ".jpeg"
  gradient.colors <- c("blue", "cyan","gray","gray","gray","yellow","#C9182B")
  ROI.label.size <- 15
  P.label.size <- 15
  title.size <- 20
  x.axis.size <- 15
  ggplot(dataset, aes(x = x.values, y = y.values, fill = distrib.fill, group = group)) + 
    guides(fill = guide_colorbar(barwidth = 1, barheight = 20, 
                                 nbin = 100, frame.colour = "black", frame.linewidth = 1.5, 
                                 ticks.colour = "black", title.position = "top", 
                                 title.hjust = 0.5)) + stat_density_ridges(quantile_lines = TRUE, 
                                                                           quantiles = 2, size = 0.6, alpha = 0.8, scale = 2, color = "black") + 
    geom_vline(xintercept = 0, linetype = "solid", alpha = 1, 
               size = 1, color = "green") + scale_fill_gradientn(colors = gradient.colors, 
                                                                 values = c(0, 0.15,0.20,0.80,0.85,1), 
                                                                 limits = c(0, 1), 
                                                                 name = legend.title, 
                                                                 breaks = c(0, 0.05, 0.1, 0.9, 0.95, 1), 
                                                                 expand = expansion(0), 
                                                                 labels = c("0", "0.05", "0.1", "0.9", "0.95", "1")) + 
    scale_y_continuous(breaks = 1:length(rois), labels = y.axis.labs, 
                       sec.axis = sec_axis(~., breaks = 1:length(rois),labels = sec.y.axis.labs)) + 
    theme_ridges(font_size = ROI.label.size, grid = TRUE, center_axis_labels = TRUE) + 
    theme(plot.title = element_text(vjust = -0.5, size = title.size), axis.text.y.left = element_text(size = ROI.label.size),
                                                                          axis.text.y.right = ggtext::element_markdown(size = P.label.size), 
                                                                          axis.text.x = element_text(size = x.axis.size), legend.title.align = 5, 
                                                                          legend.title = element_text(size = 20),legend.text = element_text(size = 15),
                                                                          legend.key.size = unit(1.5, 'cm')) +
    labs(x = NULL,y = NULL) + scale_x_continuous(limits = xlim)
  
  ggsave(file = paste0(labx, "_alphabet.jpg"), width = wi, height = hi, 
         dpi = 500)
}


