suppressPackageStartupMessages(library(cfdnakit))
suppressPackageStartupMessages(library(optparse))

option_list <- list(
  make_option(c("-b", "--bamfile"),
              action = "store", type = "character",
              default = NULL, help = "Path to bamfile"),
  make_option(c("-i", "--sampleid"),
              action = "store", type = "character",
              default = NULL, help = "Sample id"),
  make_option(c("--outdir"), action = "store", type = "character",
              default = NULL,
              help = "Output directory: Path to output directory, Created if doesn't exist."),
  make_option(c("--binsize"), action = "store", type = "integer",
              default = 1000,
              help = "Size of non-overlapping bin in Kilobase. default=1000 Available options: 100, 500, 1000"),
  make_option(c("--ponrds"), action = "store", type = "character",
              default = NULL,
              help = "Path to PoN rds file"),
  make_option(c("--fragmentinfo"), action = "store", type = "logical",
              default = TRUE,
              help = "TRUE : Print general fragment-length information into tab-separated file. default=TRUE"),
  make_option(c("--plot_dist"), action = "store", type = "logical",
              default = TRUE,
              help = "TRUE : Plot fragment-length distribution. default=TRUE"),
  make_option(c("--plot_SLRatio"), action = "store", type = "logical",
              default = TRUE,
              help = "TRUE : Plot genome-wide SLRatio . default=TRUE")
)

opt <- parse_args(OptionParser(option_list = option_list))

# >>>>> Checking input arguments
if(! file.exists(opt$bamfile)){
  stop("Input bamfile doesn't exist.")
}
if(! dir.exists(opt$outdir)){

  print(paste0("Output directory ", basename(opt$outdir) ,
               " doesn't exist: Create output directory"))
  print(opt$outdir)
  dir.create(opt$outdir)
} else {
  print(paste0("Output directory ",opt$outdir))
}

if(! file.exists(opt$ponrds)){
  stop("Input pon rds file doesn't exist.")
}
PoN_rdsfile = opt$ponrds

if(! opt$binsize %in% c(100,500,1000)){
  stop(paste0("Suggested binsize argument ",
              opt$binsize ," is not possible."))
}
# <<<<<<<
print(paste0("Reading Bamfile and split into ",opt$binsize, "KB"))
sample_bambin = read_bamfile(opt$bamfile,binsize = opt$binsize)


#  >>>>> Reading package's healthy control plasma profile
control_rds="BH01_CHR15.SampleBam.rds"
control_RDS_file =
  system.file("extdata",
              control_rds,
              package = "cfdnakit")
control_fragment_profile =
  readRDS(control_RDS_file)
# <<<<<<


# >>>>>> Making comparison list for ploting length distribution
readbam_list = list(sample_bambin,
                    control_fragment_profile)
names(readbam_list) = c(opt$sampleid,
                        "Healthy.control")
# <<<<<<<<<


print("Extracting fragment length profile")
sample_profile = get_fragment_profile(sample_bambin,
                                      sample_id = opt$sampleid)

print("Writing sample profile rds")
save_fragment_profile(sample_profile,
                      output_dir = opt$outdir,
                      overwrite = TRUE)

if(opt$fragmentinfo){
  print("Writing fragment info file")
  write.table(sample_profile$sample_profile,
              file = paste0(opt$outdir,"/",
                            sample_profile$Sample.ID,".fragmentinfo"),
              quote = FALSE,
              sep = "\t",row.names = FALSE,
              col.names = TRUE)
}


if(opt$plot_dist){
  print("Plotting fragment-length distribution")
  print(paste0(opt$outdir,"/",
               sample_profile$Sample.ID,".fragmentdist.png"))
  png(filename = paste0(opt$outdir,"/",
                        sample_profile$Sample.ID,".fragmentdist.png"),
      width = 700,height = 500)
  print(plot_fragment_dist(readbam_list))
  dev.off()
}


if(opt$plot_SLRatio){
  print("Plotting genome-wide SLRatio")
  print(paste0(opt$outdir,"/",
               sample_profile$Sample.ID,".SLRatio.png"))
  png(filename = paste0(opt$outdir,"/",
                        sample_profile$Sample.ID,".SLRatio.png"),
      width = 1000,height = 350)
  print(plot_sl_ratio(fragment_profile = sample_profile))
  dev.off()
}
print("Done")


print("Transform SL ratio")
sample_zscore = get_zscore_profile(sample_profile,
                                   PoN_rdsfile)
print("Segmentation by PSCBS")
sample_zscore_segment = segmentByPSCB(sample_zscore)

print("Calling CNV")
sample_cnv = call_cnv(sample_zscore_segment,sample_zscore)

# >>>> Calculating CPA score from the segmentation
print("Calculating CPA score")
CPA_score = calculate_CPA_score(sample_cnv[[1]]$solution_segmentation)

CPA_score_SLRatio =
  CPA_score * sample_profile$sample_profile$S.L.Ratio_corrected
CPA_score_df = data.frame("Sample.ID"=opt$sampleid,
                          "CPA.Score"=CPA_score,
                          "CPA.Score.SLRatio"=CPA_score_SLRatio)
# <<<<


print("Plotting distance matrix")
print(paste0(opt$outdir,"/",
             sample_profile$Sample.ID,".distance.png"))
png(filename = paste0(opt$outdir,"/",
                      sample_profile$Sample.ID,".distance.png"),
    width = 700,height = 700)
print(plot_distance_matrix(sample_cnv))
dev.off()


print("Plotting first CNV solution")
print(paste0(opt$outdir,"/",
             sample_profile$Sample.ID,".cnv.firstsol.png"))
png(filename = paste0(opt$outdir,"/",
                      sample_profile$Sample.ID,".cnv.firstsol.png"),
    width = 1000,height = 350)
print(plot_cnv_solution(sample_cnv,selected_solution = 1))
dev.off()





print("Writing solution table")
solution_table = get_solution_table(sample_cnv)
write.table(solution_table,
            file = paste0(opt$outdir,"/",
                          sample_profile$Sample.ID,".cnv.solution.tsv"),
            row.names = FALSE,col.names = TRUE,
            sep="\t",quote = FALSE)
print("Done")




print("Plotting ploidy 2 CNV solution")
print(paste0(opt$outdir,"/",
             sample_profile$Sample.ID,".cnv.2N.png"))
png(filename = paste0(opt$outdir,"/",
                      sample_profile$Sample.ID,".cnv.2N.png"),
    width = 1000,height = 350)
solution_2N = solution_table$rank[which(solution_table$rounded_ploidy==2)]
print(plot_cnv_solution(sample_cnv,selected_solution = solution_2N))
dev.off()



print("Writing segment file")
write.table(sample_zscore_segment,
            file = paste0(opt$outdir,"/",
                          sample_profile$Sample.ID,".segment.tsv"),
            row.names = FALSE,col.names = TRUE,
            sep="\t",quote = FALSE)

print("Writing CPA score table")
write.table(CPA_score_df,
            file = paste0(opt$outdir,"/",
                          sample_profile$Sample.ID,".CPAScore.tsv"),
            row.names = FALSE,col.names = TRUE,
            sep="\t",quote = FALSE)

print("Done")
