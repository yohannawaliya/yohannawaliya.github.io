# ============================================================================
# QUANTITATIVE NARRATIVE ANALYSIS -- FRANZOSI SAO METHOD
# Full workshop script. Run top to bottom, or source() individual sections.
# Companion file: labour_corpus_1919_1922.csv (place in the same folder)
# ============================================================================

# ---- 0. SETUP --------------------------------------------------------------
# install.packages(c("tidyverse","igraph","ggraph","scales"))
library(tidyverse)
library(igraph)
library(ggraph)

# ---- 1. LOAD DATA -----------------------------------------------------------
# Option A: load the provided corpus
sao <- read_csv("labour_corpus_1919_1922.csv", show_col_types = FALSE)

# Option B: hand-code your own clauses directly (uncomment to use instead)
# sao <- tribble(
#   ~doc_id, ~subject, ~sub_type, ~verb, ~verb_type, ~object, ~obj_type,
#   ~year, ~place, ~quantity, ~intensity,
#   "DOC_01", "workers", "labor", "went on strike", "collective_action",
#   "factories", "target", 1919, "Pittsburgh", 5000, "high"
# )

glimpse(sao)
stopifnot(nrow(sao) > 0)                 # fail loudly if the file didn't load
stopifnot(all(c("subject","verb_type") %in% names(sao)))

# ---- 2. FREQUENCY ANALYSIS --------------------------------------------------
actor_freq <- sao |>
  count(subject, sub_type, sort = TRUE) |>
  rename(frequency = n)
print(actor_freq)

class_freq <- sao |>
  count(sub_type, sort = TRUE) |>
  mutate(pct = round(n / sum(n) * 100, 1))
print(class_freq)

action_dist <- sao |>
  count(verb_type, sort = TRUE) |>
  mutate(pct = round(n / sum(n) * 100, 1))

p_freq <- ggplot(action_dist, aes(x = reorder(verb_type, pct), y = pct)) +
  geom_col(fill = "#e85d42", alpha = 0.85) +
  geom_text(aes(label = sprintf("%.1f%%", pct)), hjust = -0.15, size = 3.2) +
  coord_flip() +
  labs(title = "Franzosi SAO -- Action Type Distribution",
       x = "", y = "% of coded clauses") +
  theme_minimal(base_size = 12)
print(p_freq)
ggsave("output_01_action_distribution.png", p_freq, width = 8, height = 5, dpi = 150)

# ---- 3. S x A CROSS-TABULATION ----------------------------------------------
who_does_what <- sao |>
  count(sub_type, verb_type) |>
  pivot_wider(names_from = verb_type, values_from = n, values_fill = 0)
print(who_does_what)

sxa_long <- sao |> count(sub_type, verb_type)
p_heat <- ggplot(sxa_long, aes(x = verb_type, y = sub_type, fill = n)) +
  geom_tile(colour = "white", linewidth = 0.5) +
  geom_text(aes(label = n), size = 3.5, fontface = "bold") +
  scale_fill_gradient(low = "#f4ede0", high = "#e85d42") +
  labs(title = "S x A Matrix -- Who Does What to Whom",
       x = "Action Type", y = "Actor Class", fill = "Clauses") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 35, hjust = 1))
print(p_heat)
ggsave("output_02_sxa_heatmap.png", p_heat, width = 10, height = 4, dpi = 150)

# ---- 4. ACTOR NETWORK -------------------------------------------------------
actor_edges <- sao |>
  filter(obj_type %in% c("actor", "person")) |>
  select(from = subject, to = object, action = verb, verb_type, year)

g <- graph_from_data_frame(actor_edges, directed = TRUE)

p_net <- ggraph(g, layout = "stress") +
  geom_edge_arc(
    aes(label = action, colour = verb_type),
    arrow = arrow(length = unit(3, "mm"), type = "closed"),
    end_cap = circle(5, "mm"), start_cap = circle(5, "mm"),
    label_size = 2.8, strength = 0.25
  ) +
  geom_node_point(size = 9, colour = "#1a2744", alpha = 0.85) +
  geom_node_text(aes(label = name), repel = TRUE, size = 3.4, fontface = "bold",
                 colour = "#1B7A3D") +
  theme_graph() +
  labs(title = "SAO Actor Network", colour = "Action Type")
print(p_net)
ggsave("output_03_actor_network.png", p_net, width = 9, height = 7, dpi = 150)

cat("\n--- In-degree (most acted-upon) ---\n")
print(sort(degree(g, mode = "in"), decreasing = TRUE))
cat("\n--- Out-degree (most active) ---\n")
print(sort(degree(g, mode = "out"), decreasing = TRUE))
cat("\n--- Betweenness (brokers) ---\n")
print(round(sort(betweenness(g), decreasing = TRUE), 3))

# ---- 5. PROTEST INTENSITY INDEX (PII) --------------------------------------
pii <- sao |>
  mutate(
    intensity_score = case_when(
      intensity == "high"   ~ 3,
      intensity == "medium" ~ 2,
      intensity == "low"    ~ 1),
    action_weight = case_when(
      verb_type %in% c("collective_action","confrontation","occupation") ~ 3,
      verb_type %in% c("repression","dismissal","refusal")               ~ 2,
      verb_type %in% c("demand","petition","intervention")               ~ 2,
      TRUE                                                                ~ 1),
    pii_score = intensity_score * action_weight)

pii_summary <- pii |>
  group_by(year, sub_type) |>
  summarise(total_pii = sum(pii_score), .groups = "drop")
print(pii_summary)

p_pii <- ggplot(pii_summary, aes(x = year, y = total_pii, colour = sub_type, group = sub_type)) +
  geom_line(linewidth = 1.3) + geom_point(size = 3.5) +
  scale_colour_manual(values = c(labor = "#e85d42", state = "#1a2744", capital = "#c8a96e")) +
  labs(title = "Protest Intensity Index by Actor Class",
       x = "Year", y = "Total PII", colour = "Actor Class") +
  theme_minimal(base_size = 12)
print(p_pii)
ggsave("output_04_pii_trajectory.png", p_pii, width = 9, height = 5, dpi = 150)

# ---- 6. AUDIT (run this on YOUR data before trusting results) -------------
completeness <- sao |>
  summarise(across(everything(), ~round(mean(!is.na(.)) * 100, 1))) |>
  pivot_longer(everything(), names_to = "field", values_to = "pct_complete") |>
  arrange(pct_complete)
print(completeness)

valid_sub_types  <- c("labor","state","capital")
vocab_errors <- sao |> filter(!sub_type %in% valid_sub_types)
cat("\nRows with unexpected sub_type:", nrow(vocab_errors), "\n")

duplicates <- sao |> group_by(doc_id, subject, verb, object) |> filter(n() > 1)
cat("Duplicate clauses:", nrow(duplicates), "\n")

cat("\n============================================================\n")
cat("DONE. Four PNGs saved to your working directory:\n")
cat("  output_01_action_distribution.png\n")
cat("  output_02_sxa_heatmap.png\n")
cat("  output_03_actor_network.png\n")
cat("  output_04_pii_trajectory.png\n")
cat("============================================================\n")
