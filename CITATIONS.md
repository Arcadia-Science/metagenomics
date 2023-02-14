# Arcadia-Science/metagenomics Citations

Below are citations of tools used in the pipeline that you should cite in your work when using this pipeline.

## Nextflow and Reporting Tools

- [nf-core](https://pubmed.ncbi.nlm.nih.gov/32055031/)

> Ewels PA, Peltzer A, Fillinger S, Patel H, Alneberg J, Wilm A, Garcia MU, Di Tommaso P, Nahnsen S. The nf-core framework for community-curated bioinformatics pipelines. Nat Biotechnol. 2020 Mar;38(3):276-278. doi: 10.1038/s41587-020-0439-x. PubMed PMID: 32055031.

- [Nextflow](https://pubmed.ncbi.nlm.nih.gov/28398311/)

> Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. Nat Biotechnol. 2017 Apr 11;35(4):316-319. doi: 10.1038/nbt.3820. PubMed PMID: 28398311.

- [MultiQC](https://pubmed.ncbi.nlm.nih.gov/27312411/)
  > Ewels P, Magnusson M, Lundin S, Käller M. MultiQC: summarize analysis results for multiple tools and samples in a single report. Bioinformatics. 2016 Oct 1;32(19):3047-8. doi: 10.1093/bioinformatics/btw354. Epub 2016 Jun 16. PubMed PMID: 27312411; PubMed Central PMCID: PMC5039924.

## Pipeline tools

Below are pipeline-specific tools, categorized by tools for Illumina preprocessing, Nanopore preprocessing, and general software tools.

### Illumina Pipeline Tools

- [Fastp](https://doi.org/10.1093/bioinformatics/bty560)
  > Shifu Chen, Yanqing Zhou, Yaru Chen, Jia Gu; fastp: an ultra-fast all-in-one FASTQ preprocessor, Bioinformatics, Volume 34, Issue 17, 1 September 2018, Pages i884–i890
- [SPAdes](https://currentprotocols.onlinelibrary.wiley.com/doi/abs/10.1002/cpbi.102)
  > Andrey Prjibelski,Dmitry Antipov,Dmitry Meleshko,Alla Lapidus,Anton Korobeynikov. Using SPAdes De Novo Assembler. Current Protocols in Bioinformatics. 2020.
- [Bowtie2](https://www.nature.com/articles/nmeth.1923)
  > Ben Langmead and Steven L Salzberg. Fast-gapped read alignment with bowtie2. Nature Methods. 2012.

### Nanopore Pipeline Tools

- [NanoPlot](https://academic.oup.com/bioinformatics/article/34/15/2666/4934939)
  > NanoPack: visualizing and processing long-read sequencing data. Bioinformatics. 2018.
- [Porechop_ABI](https://www.biorxiv.org/content/10.1101/2022.07.07.499093v1)
  > Bonenfant Q, Noe L, Touzet H. Porechop_ABI: discovering unknown adapters in ONT sequencing reads for downstream trimming. bioRxiv. 2022. doi:10.1101/2022.07.07.499093. -[Flye](https://www.nature.com/articles/s41587-019-0072-8)
  > Kolmogorov M, Yuan J, Lin Y, Pevzner P. Assembly of long, error-prone reads using repeat graphs. Nature Biotechnology. 2019; 540-546. doi:10.1038/s41587-019-0072-
- [minimap2](https://academic.oup.com/bioinformatics/article/34/18/3094/4994778)
  > Li H. Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics. Sept 2018; 34(18): 3094-3100
- [Racon](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5411768/)
  > Vaser R, Sovic I, Nagarajan N, Sikic M. Fast and accurate de novo genome assembly from long uncorrected reads. Genome Research. 2017; 27(5): 737-746. doi:10.1101/gr.214270.116

### General Pipeline Tools

- [QUAST](https://academic.oup.com/bioinformatics/article/29/8/1072/228832?login=false)
  > Gurevich A, Saveliev V, Vyahhi N, Tesler G. QUAST: quality assessment tool for genome assemblies. Bioinformatics. April 2013; 29(8): 1072-1075. doi:10.1093/bioinformatics/btt086
- [metabat2 JGI Summarize Contigs](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6662567/)
  > Dongwan D. Kang,1 Feng Li,2 Edward Kirton,1 Ashleigh Thomas,1 Rob Egan,1 Hong An,2 and Zhong Wang. MetaBAT 2: an adaptive binning algorithm for robust and efficient genome reconstruction from metagenome assemblies. PeerJ. 2019.
- [Samtools](https://academic.oup.com/gigascience/article/10/2/giab008/6137722?login=false)
  > Petr Danecek, James K Bonfield, Jennifer Liddle, John Marshall, Valeriu Ohan, Martin O Pollard, Andrew Whitwham, Thomas Keane, Shane A McCarthy, Robert M Davies, Heng Li. Twelve years of SAMtools and BCFtools. GigaScience. 2021.

## Software packaging/containerisation tools

- [Anaconda](https://anaconda.com)

  > Anaconda Software Distribution. Computer software. Vers. 2-2.4.0. Anaconda, Nov. 2016. Web.

- [Bioconda](https://pubmed.ncbi.nlm.nih.gov/29967506/)

  > Grüning B, Dale R, Sjödin A, Chapman BA, Rowe J, Tomkins-Tinch CH, Valieris R, Köster J; Bioconda Team. Bioconda: sustainable and comprehensive software distribution for the life sciences. Nat Methods. 2018 Jul;15(7):475-476. doi: 10.1038/s41592-018-0046-7. PubMed PMID: 29967506.

- [BioContainers](https://pubmed.ncbi.nlm.nih.gov/28379341/)

  > da Veiga Leprevost F, Grüning B, Aflitos SA, Röst HL, Uszkoreit J, Barsnes H, Vaudel M, Moreno P, Gatto L, Weber J, Bai M, Jimenez RC, Sachsenberg T, Pfeuffer J, Alvarez RV, Griss J, Nesvizhskii AI, Perez-Riverol Y. BioContainers: an open-source and community-driven framework for software standardization. Bioinformatics. 2017 Aug 15;33(16):2580-2582. doi: 10.1093/bioinformatics/btx192. PubMed PMID: 28379341; PubMed Central PMCID: PMC5870671.

- [Docker](https://dl.acm.org/doi/10.5555/2600239.2600241)

- [Singularity](https://pubmed.ncbi.nlm.nih.gov/28494014/)
  > Kurtzer GM, Sochat V, Bauer MW. Singularity: Scientific containers for mobility of compute. PLoS One. 2017 May 11;12(5):e0177459. doi: 10.1371/journal.pone.0177459. eCollection 2017. PubMed PMID: 28494014; PubMed Central PMCID: PMC5426675.
