metadata_file = 'metadata.txt' #adjust this based on your file location
metadata = read.csv(metadata_file,sep='\t',stringsAsFactors = F,row.names = 1)

count_file = 'count_gene.txt' #adjust this based on your file location
count = read.csv(count_file,sep='\t',stringsAsFactors = F,row.names = 1)[,rownames(metadata)] # make sure that sequence of metadata is the same with tpm

library('DESeq2')
conds=as.factor(metadata$condition)
coldata <- data.frame(row.names=rownames(metadata),conds)
dds <- DESeqDataSetFromMatrix(countData=round(as.matrix(count)),colData=coldata,design=~conds)
dds <- DESeq(dds)

cond1 = 'soy' #First Condition
cond2 = 'lard' #second Condition
cond3 = 'fish' #third Condition
cond4 = 'control' #reference Condition
res1=results(dds,contrast=c('conds',cond1,cond4))
res2=results(dds,contrast=c('conds',cond2,cond4))
res3=results(dds,contrast=c('conds',cond3,cond4))
res1=data.frame(res1)
res2=data.frame(res2)
res3=data.frame(res3)

write.table(res1,file='deseq_soy.txt',sep = '\t', na = '',row.names = T,col.names=NA)
write.table(res2,file='deseq_lard.txt',sep = '\t', na = '',row.names = T,col.names=NA)
write.table(res3,file='deseq_fish.txt',sep = '\t', na = '',row.names = T,col.names=NA)

