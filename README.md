# cmpe492-Transcriptomics_Analysis

Applied Data Quantification, Differential Expression and Functional analysis to analyze transcriptomics data of mus musculus over a diet data.

_By FarukOzderim_  

# Data:  
https://www.ebi.ac.uk/ena/data/view/PRJNA292382

This data has 3 diets + 1 control diet over musmusculus. 

It is a study with name "Omega-3 fatty acids partially revert the metabolic gene expression profile induced by long-term calorie restriction". 

Dataset contains single raw RNA-sequences from liver and muscle.


# Run
You can run all the steps except deseq2 analysis with

```shell
bash scriptForAll.sh
```

be careful that it will download 40gb of data and run ~8 hours after download on a standard pc.

You can use metadataLike.txt and differentiate liver and muscle data like in 

-results/muscle/data

-results/liver/data

-results/muscle/metadata.txt

-results/liver/metadata.txt


and run script1.r to script4.r with R. This will apply deseq2 and functional analysis.


##


My results are under results segment.


# _Reference:_

I used this workshop as a reference for my work:

https://github.com/sysmedicine/phd2020
