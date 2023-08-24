.onLoad <- function(libname, pkgname) {

  gcol<-c("#0022a1","#fc0a2d","#6a7f8c","#66ffd6","#d4ff40","#ff6108","#cdddf4","#2f470e","#4c90d3","#ed9924","#780000","#132742","#4f897b","#ffa799", "#c24e13","#a4ce40","#f2cd47","#ed6053" ,"#174a7c" ,"#659737")
  options(
    ggplot2.discrete.fill= list(gcol)
    ,ggplot2.discrete.colour= list(gcol)
  )

  invisible()
}



.onAttach <- function(libname, pkgname) {
  packageStartupMessage("I solemnly swear that I am up to no good")
}
