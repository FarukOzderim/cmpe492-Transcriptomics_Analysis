deseq_file='deseq_soy.txt'
deseq = read.csv(deseq_file,sep='\t',stringsAsFactors = F,row.names = 1)

library('piano')
library('Biobase')
library('snow')
library('RColorBrewer')
library('gplots')
library('visNetwork')

GSC='KEGG.gmt'
y=loadGSC(GSC)

input_file=deseq[ ,c('log2FoldChange','pvalue')]
logFC=as.matrix(input_file[,1])
pval=as.matrix(input_file[,2])
rownames(logFC)=toupper(rownames(input_file))
rownames(pval)=toupper(rownames(input_file))
logFC[is.na(logFC)] <- 0
pval[is.na(pval)] <- 1
gsaRes <- runGSA(pval,logFC,gsc=y, geneSetStat="reporter", signifMethod="nullDist", nPerm=1000)

res_piano=GSAsummaryTable(gsaRes)


pdf("heatmap.pdf") 
hm = GSAheatmap(gsaRes, adjusted = T)
dev.off()

pdf("network_plot.pdf") 
nw = networkPlot(gsaRes, class="distinct", direction="both",significance=0.00005, label="names")
dev.off()

nw_int = networkPlot2(gsaRes, class="distinct", direction="both", significance=0.00005)
#if you want to show it without saving in R, type "nw_int"
visSave(nw_int, file = "network_plot_interactive.html", background = "white")

