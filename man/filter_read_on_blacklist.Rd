% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_bamfile.R
\name{filter_read_on_blacklist}
\alias{filter_read_on_blacklist}
\title{Filter out reads on blacklist regions}
\usage{
filter_read_on_blacklist(sample_bin, blacklist_files = NULL, genome = "hg19")
}
\arguments{
\item{sample_bin}{SampleBam; Object from function read_bamfile}

\item{blacklist_files}{Character; Filepath to file containing blacklist regions}

\item{genome}{Character; Abbreviation of reference genome; Either hg19 or mm10. default:hg19}
}
\value{
SampleBam after filtering out read on balck list regions
}
\description{
Filter out reads on blacklist regions
}
