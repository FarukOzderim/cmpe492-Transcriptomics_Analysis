result_dir = 'data/' # The directory that includes the extracted folders

count_tr = data.frame()
tpm_tr = data.frame()

for(i in list.dirs(result_dir,recursive=F)){
  temp = read.csv(paste0(i,'/abundance.tsv'),sep='\t',stringsAsFactors = F)
  temp_count = data.frame(temp$est_counts)
  temp_tpm = data.frame(temp$tpm)
  colnames(temp_count) = gsub(paste0(result_dir,"/"), "", i)
  colnames(temp_tpm) = gsub(paste0(result_dir,"/"), "", i)
  if(ncol(count_tr) == 0){
    count_tr = temp_count
    rownames(count_tr) = temp$target_id
    tpm_tr = temp_tpm
    rownames(tpm_tr) = temp$target_id
  } else {
    count_tr = cbind(count_tr, temp_count)
    tpm_tr = cbind(tpm_tr,temp_tpm)
  }
}


biomart_file = 'mart_export.txt' #adjust this based on your file location
mapping = read.csv(biomart_file,sep='\t',stringsAsFactors = F,row.names = 1)
count_gn = merge(count_tr,mapping['Gene.name'], by=0,all=F) # merge only for the shared row names
count_gn = count_gn[,2:ncol(count_gn)]
count_gn = aggregate(.~Gene.name, count_gn, sum)
rownames(count_gn) = count_gn$Gene.name 
tpm_gn = merge(tpm_tr,mapping['Gene.name'], by=0,all=F) # merge only for the shared row names
tpm_gn = tpm_gn[,2:ncol(tpm_gn)]
tpm_gn = aggregate(.~Gene.name, tpm_gn, sum)
rownames(tpm_gn) = tpm_gn$Gene.name


write.table(count_gn,file='count_gene.txt',sep = '\t', na = '',row.names = F)
write.table(tpm_gn,file='tpm_gene.txt',sep = '\t', na = '',row.names = F)

