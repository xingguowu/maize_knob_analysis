# 1. 加载必要的包
library(ggplot2)
setwd("/Users/samguinewu/工作/analysis/03_cluster/")
# 2. 读入刚才在 Linux 端生成的长度数据
# 1. 强行不读取表头 (header = FALSE)，这样第一行就会乖乖变成第一行数据
length_data <- read.table("tr1_all_groups_lengths.txt", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# 2. 强制手动锁死三个标准列名
colnames(length_data) <- c("ID", "Length", "Group")

# 3. 将 Group 转换为有顺序的因子，并赋予和您的发育树/PCoA 严格一致的名称
length_data$Group <- factor(length_data$Group, 
                            levels = c("group1", "group2", "group3"),
                            labels = c("Group 1: Temperate Inbreds", 
                                       "Group 2: Tropical & Subtropical", 
                                       "Group 3: Landraces & Teosinte"))

# 查看数据摘要，核对最大、最小长度
print(summary(length_data))
# 4. 绘图（已去除柱子描边）
p_facet <- ggplot(length_data, aes(x = Length, fill = Group)) +
  geom_histogram(binwidth = 1, alpha = 0.85, color = "black", linewidth = 0.2) +
  facet_wrap(~Group, scales = "free_y", ncol = 1) + 
  scale_fill_manual(values = group_colors) + # 请确保您在代码上下文里定义了 group_colors
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  theme_bw() + 
  coord_cartesian(xlim = c(100, 380)) +
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    panel.border = element_rect(color = "black", fill = NA, size = 0.8),
    axis.ticks = element_line(color = "black", size = 0.5),
    
    strip.background = element_blank(),
    strip.text = element_text(face = "bold", size = 11, color = "black"),
    legend.position = "none"
  ) +
  labs(x = "Sequence Length (bp)", y = "", title = "Histogram of knob180 Lengths by Group")

print(p_facet)

# 保存为 PDF
ggsave(
  filename = "tr1_length_density.pdf",
  plot = p_facet,
  width = 8, 
  height = 5, 
  dpi = 300 
)


top20_per_group <- length_data %>%
  group_by(Group, Length) %>%
  tally(name = "Count") %>%                  # 统计各组内每个长度的频数
  group_by(Group) %>%                        # 重新按 Group 分组
  slice_max(order_by = Count, n = 20) %>%    # 提取每组内 Count 最大的一前 20 行
  mutate(Rank = row_number()) %>%            # 添加组内排名
  select(Group, Rank, Length, Count) %>%     # 调整列顺序
  arrange(Group, desc(Count))                # 排序让高频排在前面
groups_list <- unique(top20_per_group$Group)
for(g in groups_list) {
  cat("\n==================================================\n")
  cat(paste("📊", g, "中富集最高的前 20 个序列长度：\n"))
  cat("==================================================\n")
  
  sub_table <- top20_per_group %>% 
    filter(Group == g) %>% 
    ungroup() %>% 
    select(Rank, Length, Count)
  
  print(sub_table, row.names = FALSE)
}

