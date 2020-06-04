metadata_file = 'metadata.txt' #adjust this based on your file location
metadata = read.csv(metadata_file,sep='\t',stringsAsFactors = F,row.names = 1)

tpm_file = 'tpm_gene.txt' #adjust this based on your file location
tpm = read.csv(tpm_file,sep='\t',stringsAsFactors = F,row.names = 1)[,rownames(metadata)] # make sure that sequence of metadata is the same with tpm


PCA=prcomp(t(tpm), scale=F)
plot(PCA$x,pch = 15,col=c('blue','blue','red','red','lightgreen','lightgreen','black','black'))
