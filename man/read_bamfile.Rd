% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_bamfile.R
\name{read_bamfile}
\alias{read_bamfile}
\title{Read a bam file
Read a bam file from give path. Alignment and sequencing read information
will be binned into non-overlapping size}
\usage{
read_bamfile(
  bamfile_path,
  binsize = 1000,
  blacklist_files = NULL,
  genome = "hg19",
  target_bedfile = NULL,
  min_mapq = 20,
  apply_blacklist = TRUE
)
}
\arguments{
\item{bamfile_path}{Character; Path to sample bamfile}

\item{binsize}{Int; Size of non-overlapping windows in KB. Only 100,500 and 1000 is available; Default 1000}

\item{blacklist_files}{Character; Filepath to file containing blacklist regions}

\item{genome}{Character; abbreviation of reference genome; available genome: hg19,hg38, mm10. default:hg19}

\item{target_bedfile}{Character; Path to exon/target bedfile; Default NULL}

\item{min_mapq}{Int; minimum read mapping quality; Default 20}

\item{apply_blacklist}{Logical; To exclude read on the blacklist regions Default TRUE}
}
\value{
SampleBam Object; A list object containing read information from the BAM file.
}
\description{
Read a bam file
Read a bam file from give path. Alignment and sequencing read information
will be binned into non-overlapping size
}
\examples{
fl <- system.file("extdata","ex.plasma.bam",package = "cfdnakit")
### read bam file with default params (hg19, 1000K binsize)
sample.bam <-read_bamfile(fl, apply_blacklist=FALSE)
}
