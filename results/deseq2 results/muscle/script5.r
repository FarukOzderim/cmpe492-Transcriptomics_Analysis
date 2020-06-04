metadata_file = 'metadata_multi.txt' #adjust this based on your file location
metadata = read.csv(metadata_file,sep='\t',stringsAsFactors = F,row.names = 1)

count_file = 'count_gene.txt' #adjust this based on your file location
count = read.csv(count_file,sep='\t',stringsAsFactors = F,row.names = 1)[,rownames(metadata)] # make sure that sequence of metadata is the same with tpm

library('DESeq2')
model=model.matrix(~MI+day,metadata)

dds <- DESeqDataSetFromMatrix(countData=round(as.matrix(count)),colData=coldata,design=~conds)
dds <- DESeq(dds)

cond = 'MI1' #First Condition
res=results(dds,contrast=list(c(cond)))
res=data.frame(res)

write.table(res,file='deseq_multifactor.txt',sep = '\t', na = '',row.names = T,col.names=NA)

