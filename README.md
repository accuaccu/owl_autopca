# owl_autopca
Automated principal component analysis for overwatch league official data for anomaly detection

The function requires data from source: https://assets.blz-contentstack.com/v3/assets/blt321317473c90505c/blt9c4758838b4aa467/5f850357dd835814abdf5e6d/phs_2020.zip (no API available at the time of writing this in 5th of March 2021)

The function requires input:
X = data, as downloaded from the link, (as .CSV)
hero = Overwatch hero name to be used in the analysis (single hero, e.g., Reinhardt)
alpha = confidence level for Jarque-Bera normality test; 0.05 would be quite a regular choice
statistic = how to aggregate statistics over the dataset, e.g., median, mean, sum, max, min, IQR, sd, would be 'appropriate' choices

The function performs:
1. Aggregates the data, based on the argument 'statistic'
2. Does a normality test; reduces, based on argument 'alpha', the data such that only normally distributed covariates are passed forward
3. Does principal component analysis
4. Defines outliers in first two principal components using Tukey's definition (as in boxplot default)

The function outputs:
1. Plots first two principal components and prinicpal component loadings for easier interpretation
2. Highlight the outliers and indicates 'their' player names

This type of approach could potentially be used to detect anomalies in FPS games in general, for example, in anti-cheat applications.
