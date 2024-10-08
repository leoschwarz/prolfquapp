if (!require("prolfqua", quietly = TRUE))
  remotes::install_github("prolfqua/prolfquapp", dependencies = TRUE)
if (!require("prolfqua", quietly = TRUE))
  remotes::install_github("prolfqua/prolfquapp", dependencies = TRUE)
if (!require("optparse", quietly = TRUE))
  install.packages("optparse", dependencies = TRUE)

logger::log_info("LIBRARY PATHS (.libPaths()):",paste(.libPaths(), collapse = "\n"))

library("optparse")
option_list <- list(
  make_option( c("-i", "--indir"), type = "character", default = ".",
               help = "folder containing fasta file and output of the quantification software.",
               metavar = "string"),
  make_option(c("-t","--pattern_decoys"), type = "character", default = "^REV_|^rev_",
              help = " (optional) R library path",
              metavar = "string"),
  make_option( c("-p", "--project"), type = "character", default = "",
               help = "your project identifier",
               metavar = "string"),
  make_option( c("-w", "--workunit"), type = "character", default = "",
               help = "workunit identifier",
               metavar = "string"),
  make_option( c("-d", "--dataset"), type = "character", default = "dataset.csv",
               help = "name of annotation",
               metavar = "string"),
  make_option(c("-O", "--order"), type = "character", default = "",
              help = "order ID",
              metavar = "character"),
  make_option( c("-o", "--outdir"), type = "character", default = "qc_dir",
               help = "folder to write the results to.",
               metavar = "string"),
  make_option(c("-s", "--software"), type = "character", default = "DIANN",
              help = "possible options DIANN, FP_TMT, MAXQUANT",
              metavar = "character"),
  make_option(c("--libPath"), type = "character", default = NULL,
              help = " (optional) R library path",
              metavar = "string")
)

parser <- OptionParser(usage = "%prog --indir . ", option_list = option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)

lobstr::tree(arguments)

opt <- arguments$options

if (FALSE) {
  opt$indir <- "2532162/"
}
if (FALSE) {
  opt$indir <- "DIANN_1.9_tsv/"
  opt$dataset <- "dataset.xlsx"
}
if (FALSE) {
  opt$indir <- "."
  opt$dataset <- "dataset.csv"
}
if (FALSE) {
  opt$indir <- "."
  opt$dataset <- "dataset2.csv"
}
if (FALSE) {
  opt$indir <- "FragPipe_f20"
  opt$software <- "MSSTATS_FP_DIA"
  opt$dataset <- "FragPipe_f20/dataset_msstats20_parallel.xlsx"
  opt$outdir <- "qc_dir_msstats20"
}

# set library path
if (!is.null(opt$libPath) && dir.exists(opt$libPath)) {
  prolfquapp::set_lib_path(opt$libPath)
}

library(prolfquapp)
library(logger)

logger::log_info("using : ", system.file(package = "prolfqua"))
logger::log_info("using : ", system.file(package = "prolfquapp"))

GRP2 <- prolfquapp::make_DEA_config_R6(
  PATH = opt$outdir,
  ORDERID = opt$order,
  PROJECTID =  opt$project,
  WORKUNITID = opt$workunit,
  application = opt$software,
  prefix = "QC"
  )

dir.create(GRP2$path)

logger::log_info(GRP2$get_zipdir())
if (!dir.exists(GRP2$get_zipdir())) {
  dir.create(GRP2$get_zipdir())
}

output_dir <- GRP2$get_zipdir()
path <- opt$indir

if (!file.exists( opt$dataset)) {stop("No annotation file found : ", opt$dataset)}

annotation <- file.path( opt$dataset) |>
  prolfquapp::read_table_data() |> prolfquapp::read_annotation(QC = TRUE)

#debug(preprocess_software)
result <- tryCatch({
  # Attempt to run the function
  procsoft <- preprocess_software(
    opt$indir,
    annotation,
    prolfquapp::prolfq_preprocess_functions,
    pattern_contaminants = GRP2$processing_options$pattern_contaminants,
    pattern_decoys = GRP2$processing_options$pattern_decoys,
    software = opt$software
  )
  # Return the result if successful
  list(value = procsoft, error = NULL, stack_trace = NULL)
}, error = function(e) {
  # On error, capture the stack trace as text
  stack_trace <- capture.output(traceback())
  # Return the error message and stack trace
  list(
    value = NULL,
    error = conditionMessage(e),
    stack_trace = paste(stack_trace, collapse = "\n")
  )
})


if (!is.null(result$error)) {
  logger::log_error(result$error, "\n")
  logger::log_error("Stack trace:\n")
  logger::log_error(result$stack_trace, "\n")
  stop("error occured")
} else {
  xd <- result$value$xd
  files <- result$value$files
}

GRP2$get_zipdir()
pap <- QC_generator$new(xd$lfqdata, xd$protein_annotation, GRP2)

pap$write_xlsx()
pap$render_QC_protein_abundances()
pap$render_sample_size_QC()


