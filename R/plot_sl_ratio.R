
#' Plot Short/Long-fragment Ratio
#'
#' @param fragment_profile list
#' @param ylim plot y-axis limit
#' @param genome Character; version of reference genome (default hg19)
#' @return plot
#' @export
#'
#' @examples
#' example_file <-  system.file("extdata","example_patientcfDNA_SampleBam.RDS",package = "cfdnakit")
#' sample_bambin <- readRDS(example_file)
#' sample_profile <- get_fragment_profile(sample_bambin,sample_id = "Patient1")
#' plot_sl_ratio(fragment_profile = sample_profile)
#'
#' ### change plot y-axis
#' plot_sl_ratio(fragment_profile = sample_profile,  ylim=c(0.1,0.5))
#'
#' ### change reference genome
#' plot_sl_ratio(fragment_profile = sample_profile,  genome="hg38")
#' @importFrom utils read.table
#' @importFrom rlang .data
plot_sl_ratio = function(fragment_profile,
                          ylim=c(0,0.4), genome="hg19"){
  if(! genome %in% c("hg19","hg38"))
    stop("Only hg19 or hg38 genome are possible")

  chrTotalLength_file <- paste0(genome,"_chrTotalLength.tsv")
  chrLength_file <-
    system.file("extdata",
                chrTotalLength_file,
                package = "cfdnakit")
  chrLength_df <- read.table(file = chrLength_file,
                             header=FALSE, sep="\t")
  chrLength_info <- util.get_chrLength_info(chrLength_df)
  per_bin_profile <- util.rowname_to_columns(fragment_profile$per_bin_profile)
  per_bin_profile <-
    dplyr::mutate(per_bin_profile,
                  scaledPos = (.data$start + .data$end)/2 +
                    chrLength_info$chroffsets[.data$chrom])

  sl_plot <- ggplot2::ggplot(per_bin_profile,
                            ggplot2::aes_(~ scaledPos,
                                          ~ `S/L.Ratio.corrected`))
  sl_plot <- sl_plot +
    ggplot2::geom_point(fill="grey20", size = 1)
  sl_plot <- sl_plot +
    ggplot2::geom_hline(yintercept =
                          median(per_bin_profile$`S/L.Ratio.corrected`,
                                 na.rm = TRUE),
                        size=0.5)
  sl_plot <- sl_plot +
    ggplot2::scale_x_continuous(breaks = chrLength_info$chrMids,
                                labels = chrLength_info$chrNames,
                                position = "bottom",expand=c(0,0))
  sl_plot <- sl_plot +
    ggplot2::geom_vline(xintercept = chrLength_info$chroffsets,
                        linetype="dotted",size=0.5)
  sl_plot <- sl_plot + ggplot2::xlab("Chromosome number") +
    ggplot2::ylab("Short/Long-Fragment Ratio")
  y_upperbound <-
    ifelse(ylim[2] <=
             median(per_bin_profile$`S/L.Ratio.corrected`,na.rm = TRUE),
           median(per_bin_profile$`S/L.Ratio.corrected`,na.rm = TRUE) + 1,
           ylim[2])
  sl_plot <-
    sl_plot + ggplot2::scale_y_continuous(
      limits=c(ylim[1],y_upperbound))

  regionsOffTheChart <- per_bin_profile[
    per_bin_profile$`S/L.Ratio.corrected` > y_upperbound,]
  sl_plot <- sl_plot +
    ggplot2::geom_point(data=regionsOffTheChart,
                        ggplot2::aes_(~scaledPos,
                                     ~y_upperbound),
                        shape=2, size = 1)
  sl_plot <- sl_plot +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   panel.background = ggplot2::element_blank(),
                   axis.title=ggplot2::element_text(size=14),
                   axis.text.x=ggplot2::element_text(size=14),
                   axis.text.y=ggplot2::element_text(size=14))
  return(sl_plot)
}

