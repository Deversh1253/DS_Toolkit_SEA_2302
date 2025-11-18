# COVID-19 Data Visualization Analysis (SEA-2302)
# Following best practices from data-to-viz.com and R Graph Gallery
# Dataset: Country-wise COVID-19 latest statistics

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

# Read the COVID-19 dataset
getwd()
setwd("F:/3rd year__resources/3rd Yr.[sem-5] reference books/[IMC-503]_Data Science Toolkit books/All_submissions_lab/DS_Toolkit_SEA_2302")
covid_data <- read.csv("country_wise_latest.csv")

# Display column names to verify
cat("Column names in dataset:\n")
print(colnames(covid_data))

# Data preprocessing - Create derived metrics
covid_data <- covid_data %>%
  mutate(
    Mortality_Rate = (Deaths / Confirmed) * 100,
    Recovery_Rate = (Recovered / Confirmed) * 100,
    Active_Rate = (Active / Confirmed) * 100
  )

# ==============================================================================
# PLOT 1: HORIZONTAL BAR CHART (Top 20 countries by confirmed cases)
# ==============================================================================
# Use when: You want to compare values across categories
# Why: Horizontal orientation works better with long country names
# Best Practice: Always order bars for better insight
# Decision: "Which countries have the MOST cases?"

top20_confirmed <- covid_data %>%
  arrange(desc(Confirmed)) %>%
  head(20)

plot1 <- ggplot(top20_confirmed, 
                aes(x = reorder(Country, Confirmed), 
                    y = Confirmed,
                    fill = WHO_Region)) +
  geom_bar(stat = "identity", color = "black", alpha = 0.85) +
  geom_text(aes(label = comma(Confirmed)), 
            hjust = -0.1, size = 3, fontface = "bold") +
  coord_flip() +
  scale_y_continuous(labels = comma, 
                     expand = expansion(mult = c(0, 0.15))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Top 20 Countries by Confirmed COVID-19 Cases",
    subtitle = "US leads globally with over 4 million cases, followed by Brazil and India",
    x = "Country",
    y = "Confirmed Cases",
    caption = "Data Source: Country-wise COVID-19 latest statistics | Ordered by total confirmed cases",
    fill = "WHO Region"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    axis.text.y = element_text(size = 10),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

print(plot1)
# Save plot to file
ggsave("plot1_top20_countries.png", plot = plot1, width = 14, height = 10, dpi = 300)


# ==============================================================================
# PLOT 2: SCATTER PLOT (Mortality Rate vs Recovery Rate with Bubble Size)
# ==============================================================================
# Use when: Examining correlation between two variables
# Enhancement: Add size (bubble chart) for third variable (confirmed cases)
# Enhancement: Add color for categorical grouping (WHO Region)
# Decision: "Is there a RELATIONSHIP between mortality and recovery?"
# Best Practice: Filter to countries with >1000 cases to avoid noise

filtered_data <- covid_data %>%
  filter(Confirmed > 1000)

plot2 <- ggplot(filtered_data, 
                aes(x = Recovery_Rate, 
                    y = Mortality_Rate)) +
  geom_point(aes(size = Confirmed, color = WHO_Region), 
             alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, 
              color = "red", linetype = "dashed", linewidth = 1) +
  geom_text(data = filtered_data %>% 
              filter(Mortality_Rate > 10 | Country %in% c("US", "India", "Brazil")),
            aes(label = Country), 
            vjust = -1, size = 3, fontface = "bold") +
  scale_size_continuous(range = c(2, 20), 
                        labels = comma,
                        name = "Confirmed Cases") +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Mortality Rate vs Recovery Rate by Country",
    subtitle = "Countries with >1,000 cases | Bubble size represents total confirmed cases",
    x = "Recovery Rate (%)",
    y = "Mortality Rate (%)",
    caption = "Data Source: COVID-19 country statistics | Trend line shows negative correlation",
    color = "WHO Region"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

print(plot2)
# Save plot to file
ggsave("plot2_mortality_vs_recovery.png", plot = plot2, width = 14, height = 10, dpi = 300)


# ==============================================================================
# PLOT 3: HISTOGRAM (Distribution of Mortality Rates)
# ==============================================================================
# Use when: You want to see the frequency distribution
# Best Practice: Try different bin sizes - it can lead to different insights
# Decision: Shows how mortality rates are distributed globally
# Filter: Countries with >500 cases for reliable statistics

mortality_filtered <- covid_data %>%
  filter(Confirmed > 500)

plot3 <- ggplot(mortality_filtered, 
                aes(x = Mortality_Rate)) +
  geom_histogram(binwidth = 1, 
                 fill = "#E74C3C", 
                 color = "black", 
                 alpha = 0.8) +
  geom_vline(aes(xintercept = mean(Mortality_Rate)), 
             color = "blue", 
             linetype = "dashed", 
             linewidth = 1.2) +
  geom_vline(aes(xintercept = median(Mortality_Rate)), 
             color = "darkgreen", 
             linetype = "dotted", 
             linewidth = 1.2) +
  annotate("text", 
           x = mean(mortality_filtered$Mortality_Rate) + 1.5, 
           y = Inf, 
           label = paste0("Mean: ", round(mean(mortality_filtered$Mortality_Rate), 2), "%"),
           vjust = 2, 
           color = "blue", 
           fontface = "bold") +
  annotate("text", 
           x = median(mortality_filtered$Mortality_Rate) - 1.5, 
           y = Inf,
           label = paste0("Median: ", round(median(mortality_filtered$Mortality_Rate), 2), "%"),
           vjust = 4, 
           color = "darkgreen", 
           fontface = "bold") +
  scale_x_continuous(breaks = seq(0, 30, 2)) +
  labs(
    title = "Distribution of COVID-19 Mortality Rates Across Countries",
    subtitle = "Countries with >500 confirmed cases | Most countries cluster between 0-5% mortality",
    x = "Mortality Rate (%)",
    y = "Number of Countries",
    caption = "Data Source: COVID-19 statistics | Bin width = 1%"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    panel.grid.minor = element_blank()
  )

print(plot3)
# Save plot to file
ggsave("plot3_mortality_distribution.png", plot = plot3, width = 14, height = 10, dpi = 300)


# ==============================================================================
# PLOT 4: STACKED BAR CHART (Case Status: Deaths + Recovered + Active)
# ==============================================================================
# Use when: Showing composition of totals
# Why: Shows both total burden and breakdown simultaneously
# Decision: "What's the COMPOSITION of cases (Active/Dead/Recovered)?"
# Best Practice: Put most important category at baseline

top15_status <- covid_data %>%
  arrange(desc(Confirmed)) %>%
  head(15) %>%
  select(Country, Confirmed, Deaths, Recovered, Active) %>%
  pivot_longer(cols = c(Deaths, Recovered, Active), 
               names_to = "Status", 
               values_to = "Count")

# Reorder factor levels for stacking order (Deaths at bottom as most critical)
top15_status$Status <- factor(top15_status$Status, 
                              levels = c("Active", "Recovered", "Deaths"))

plot4 <- ggplot(top15_status, 
                aes(x = reorder(Country, -Confirmed), 
                    y = Count, 
                    fill = Status)) +
  geom_bar(stat = "identity", 
           color = "black", 
           alpha = 0.85,
           linewidth = 0.3) +
  scale_fill_manual(values = c("Deaths" = "#d62728", 
                               "Recovered" = "#2ca02c", 
                               "Active" = "#ff7f0e"),
                    labels = c("Active Cases", "Recovered", "Deaths")) +
  geom_text(data = top15_status %>% 
              group_by(Country, Confirmed) %>% 
              summarise(Total = sum(Count), .groups = "drop"),
            aes(x = Country, y = Total, label = comma(Total)),
            inherit.aes = FALSE,
            vjust = -0.5, 
            size = 3, 
            fontface = "bold") +
  coord_flip() +
  scale_y_continuous(labels = comma, 
                     expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "COVID-19 Case Status Breakdown - Top 15 Countries",
    subtitle = "Stacked composition showing Deaths, Recovered, and Active cases",
    x = "Country",
    y = "Number of Cases",
    caption = "Data Source: COVID-19 country statistics | Ordered by total confirmed cases",
    fill = "Case Status"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

print(plot4)
# Save plot to file
ggsave("plot4_case_status_breakdown.png", plot = plot4, width = 14, height = 10, dpi = 300)


# ==============================================================================
# PLOT 5: BOX PLOT (Mortality Rate Distribution by WHO Region)
# ==============================================================================
# Use when: Comparing distributions across groups
# Decision: "How does mortality VARY BY REGION?"
# Best Practice: Filter to countries with sufficient cases for reliable stats
# Caveat: Boxplots hide sample size - consider adding annotations

regional_mortality <- covid_data %>%
  filter(Confirmed > 500)

# Calculate sample sizes for annotation
sample_sizes <- regional_mortality %>%
  group_by(WHO_Region) %>%
  summarise(n = n(), .groups = "drop")

plot5 <- ggplot(regional_mortality, 
                aes(x = WHO_Region, 
                    y = Mortality_Rate, 
                    fill = WHO_Region)) +
  geom_boxplot(alpha = 0.7, 
               outlier.shape = 21, 
               outlier.size = 3,
               outlier.fill = "red",
               outlier.alpha = 0.5) +
  stat_summary(fun = mean, 
               geom = "point", 
               shape = 23, 
               size = 4, 
               fill = "white",
               color = "black") +
  geom_text(data = sample_sizes,
            aes(x = WHO_Region, y = -1, label = paste0("n=", n)),
            inherit.aes = FALSE,
            size = 3,
            fontface = "italic") +
  scale_fill_brewer(palette = "Pastel1") +
  labs(
    title = "COVID-19 Mortality Rate Distribution by WHO Region",
    subtitle = "Countries with >500 cases | Diamond = mean, horizontal line = median, red dots = outliers",
    x = "WHO Region",
    y = "Mortality Rate (%)",
    caption = "Data Source: COVID-19 statistics | Sample sizes shown at bottom",
    fill = "WHO Region"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    legend.position = "none",
    panel.grid.minor = element_blank()
  )

print(plot5)
# Save plot to file
ggsave("plot5_regional_mortality_boxplot.png", plot = plot5, width = 14, height = 10, dpi = 300)


# ==============================================================================
# SUMMARY STATISTICS
# ==============================================================================

cat("\n========== COVID-19 GLOBAL SUMMARY ==========\n")
cat(sprintf("Total Countries Analyzed: %d\n", nrow(covid_data)))
cat(sprintf("Total Confirmed Cases: %s\n", format(sum(covid_data$Confirmed), big.mark = ",")))
cat(sprintf("Total Deaths: %s\n", format(sum(covid_data$Deaths), big.mark = ",")))
cat(sprintf("Total Recovered: %s\n", format(sum(covid_data$Recovered), big.mark = ",")))
cat(sprintf("Total Active Cases: %s\n", format(sum(covid_data$Active), big.mark = ",")))
cat(sprintf("\nGlobal Mortality Rate: %.2f%%\n", 
            (sum(covid_data$Deaths) / sum(covid_data$Confirmed)) * 100))
cat(sprintf("Global Recovery Rate: %.2f%%\n", 
            (sum(covid_data$Recovered) / sum(covid_data$Confirmed)) * 100))

cat("\n========== TOP 5 COUNTRIES BY CONFIRMED CASES ==========\n")
top5 <- covid_data %>% 
  select(Country, Confirmed, Deaths, Recovered, Active) %>% 
  arrange(desc(Confirmed)) %>%
  head(5)
print(top5)

cat("\n========== HIGHEST MORTALITY RATES (>10%) ==========\n")
high_mortality <- covid_data %>%
  filter(Confirmed > 1000, Mortality_Rate > 10) %>%
  select(Country, Confirmed, Deaths, Mortality_Rate) %>%
  arrange(desc(Mortality_Rate))
print(high_mortality)

cat("\n========== WHO REGIONAL BREAKDOWN ==========\n")
regional_stats <- covid_data %>%
  group_by(WHO_Region) %>%
  summarise(
    Countries = n(),
    Total_Cases = sum(Confirmed),
    Total_Deaths = sum(Deaths),
    Avg_Mortality = mean(Mortality_Rate),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Cases))
print(regional_stats)

