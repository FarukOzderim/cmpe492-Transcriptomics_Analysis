# cmpe492-Transcriptomics_Analysis

This is my Bachelor Degree Senior Project.

I Applied Data Quantification, Differential Expression and Functional analysis to analyze transcriptomics data of mus musculus over a diet data.

Please look into the [project poster](https://github.com/FarukOzderim/cmpe492-Transcriptomics_Analysis/blob/master/cmpe492_poster.pdf) for more information.

_By FarukOzderim_  

# Data:  
https://www.ebi.ac.uk/ena/data/view/PRJNA292382

This data has 3 diets + 1 control diet over musmusculus. 

It is a study with name "Omega-3 fatty acids partially revert the metabolic gene expression profile induced by long-term calorie restriction". 

Dataset contains single raw RNA-sequences from liver and muscle.


# Run
You can run download dataset and data quantification steps with

```shell
bash scriptForAll.sh
```

be careful that this will download 40gb of data and run ~8 hours after download on a standard pc.


After this step for differential expression and functional analysis
You can move kallisto outputs into a data directory, and use metadataLike.txt and differentiate liver and muscle data like in 

-results/deseq2 results/muscle/data

-results/deseq2 results/liver/data

-results/deseq2 results/muscle/metadata.txt

-results/deseq2 results/liver/metadata.txt


and run script1,2,3,4.r one by one with R in that directory. This will apply deseq2 and functional analysis.

# Results


You can find my kallisto, differential expression, functional analysis results are under [results](https://github.com/FarukOzderim/cmpe492-Transcriptomics_Analysis/tree/master/results) segment.


# _Reference:_

I used this workshop as a reference for my work:

https://github.com/sysmedicine/phd2020
