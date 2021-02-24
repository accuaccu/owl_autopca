ow.pca <- function(X, hero, alpha) {
  require(tidyverse)
  require(DescTools)
  D_mains <- X %>%
    group_by(hero_name, player_name, stat_name) %>%
    filter(hero_name == hero, stat_name == 'Time Played') %>%
    summarise(TotalTimePlayed = sum(stat_amount) > 240) # 240 minutes is supposed to mark that a player is "main x" player and not once-in-a-season
  
  D_mains <- droplevels(D_mains)
  main_players <- D_mains$player_name[D_mains$TotalTimePlayed == T]
  main_players <-  droplevels(main_players)
  
  
  # Yields error, dev version could solve that; does not affect calculus though
  B <- X %>%
    group_by(hero_name, player_name, stat_name) %>%
    summarise(median = median(stat_amount)) %>%
    filter(hero_name == hero, player_name %in% main_players) %>%
    arrange(stat_name)
  
  B <- droplevels(B)
  
  
  # Test for normality
  normal_test <- tapply(B$median, B$stat_name, function(x) JarqueBeraTest(x)$p.value) < alpha
  normal_covariates <- names(normal_test[normal_test == T])
  
  # Reduce data; remove non-normal
  C <- B %>%
    filter(stat_name %in% normal_covariates, .preserve = T)
  
  C <- droplevels(C)
  
  # Re-arrange table; wide format
  E <- C[,-1] %>% 
    pivot_wider(names_from = stat_name, values_from = median)
  
  G <- as.data.frame(E)
  
  # Remove covariates with NA any values: when player has not recorded any such stat, it is essentially zero;
  # however, is it fair when comparing, no, and does it destroy the model, most likely --> take only the complete.cases.
  
  G <- G[,apply(G,2,function(x) !any(is.na(x)))]
  PCA.G <- princomp(G[,-1], cor = T)
  pca_scores <- PCA.G$scores[,1:2]
  pca_loadings <- PCA.G$loadings[,1:2]
  outliers_by_tukey <- unique(as.vector(unlist(apply(pca_scores,2, function(x) which(x >  quantile(x)[4] + IQR(x)*1.5 | x < quantile(x)[2] - IQR(x)*1.5)))))
  variances <- round(PCA.G$sdev^2 / sum(PCA.G$sdev^2),3)[1:2]
  variance_labels <- paste0('Comp.',1:2,', %Variance ', variances*100)
  plot_limit <- ceiling(max(abs(pca_scores)))
  
  par(pty = 's')
  
  plot(PCA.G$scores[,1], PCA.G$scores[,2], xlab = variance_labels[1], ylab = variance_labels[2], yaxt = 'n',
       xlim = c(-plot_limit,plot_limit),
       ylim = c(-plot_limit,plot_limit));axis(2, las = 2)
  print(outliers_by_tukey)
  if(length(outliers_by_tukey) > 0) {
    points(PCA.G$scores[outliers_by_tukey,1], PCA.G$scores[outliers_by_tukey,2], pch = 16)
  }
  text(PCA.G$scores[outliers_by_tukey,1], PCA.G$scores[outliers_by_tukey,2], G[outliers_by_tukey,1])
  par(new = T)
  plot(0,0,pch = NA, xlim = c(-1,1), ylim = c(-1,1), axes = F, ylab = '', xlab = '')
  arrows(0,0,pca_loadings[,1], pca_loadings[,2], length = 0.075)
  text(pca_loadings[,1], pca_loadings[,2], rownames(pca_loadings), pos = 4)
  legend('topright', legend = 'outlier', pch = 16)
  title(adj = 0, paste0('Hero: ',hero))
  
}
