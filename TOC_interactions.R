library(dplyr)
library(ggnetwork)
library(ggplot2)
library(readr)
library(stringr)
library(tnet)
library(network)

#code from Francois Briatte; http://f.briatte.org/r/turning-keywords-into-a-co-occurrence-network

articles<-read.csv("Articles.csv", header=TRUE)
articles$Article_DOI<-as.character(articles$Article_DOI)
articles$TOC_Section<-as.factor(articles$TOC_Section)
articles$TOC2<-as.factor(articles$TOC2)
TOCdata<-cbind.data.frame(articles$Article_DOI, articles$TOC_Section, articles$TOC2)
colnames(TOCdata)<-c("DOI","TOC1","TOC2")

TOCdata$combination<-paste(TOCdata$TOC1, TOCdata$TOC2, sep=",")

r<-sample_n(TOCdata, 5000, replace=FALSE)
r$combination<-gsub(" ","",r$combination)

r$combination %>%
  str_split(",") %>%
  unlist %>%
  table %>%
  data.frame %>%
  arrange(-Freq) %>%
  filter(Freq > 1)

e <- r$combination %>%
  str_split(",") %>%
  lapply(function(x) {
    expand.grid(x, x, w = 1 / length(x), stringsAsFactors = FALSE)
  }) %>%
  bind_rows

e <- apply(e[, -3], 1, str_sort) %>%
  t %>%
  data.frame(stringsAsFactors = FALSE) %>%
  mutate(w = e$w)

e <- group_by(e, X1, X2) %>%
  summarise(w = sum(w)) %>%
  filter(X1 != X2)
n <- network(e[, -3], directed = FALSE)

stopifnot(nrow(e) == network.edgecount(n))
set.edge.attribute(n, "weight", e$w)

# weighted degree at alpha = 1
t <- as.edgelist(n, attrname = "weight") %>%
  symmetrise_w %>%
  as.tnet %>%
  degree_w

stopifnot(nrow(t) == network.size(n))
set.vertex.attribute(n, "degree_w", t[, "output" ])

l <- n %v% "degree_w"
l<- network.vertex.names(n)

stopifnot(length(l) == network.size(n))
set.vertex.attribute(n, "label", l)

ggplot(n, aes(x, y, xend = xend, yend = yend)) +
  geom_edges(aes(color = weight), angle=0) +
  geom_nodes(color = "grey50") +
  geom_nodelabel(aes(size = degree_w, label = label),
                 label.size = 0.1) +
  scale_size_continuous(range = c(1, 5)) +
  scale_color_gradient2(low="lightgray", high="black") +
  guides(size = FALSE, color = FALSE) + theme_blank()
