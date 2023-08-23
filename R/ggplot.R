
#' Set theme to comply with TN branding with options for coloring plot elements. Gives warnings on non-approved colors
#'
#' @param title_color Color name, TN color name, or hex. Will warn if not an approved color.
#' @param subtitle_color Color name, TN color name, or hex. Will warn if not an approved color.
#' @param axis_text_color Color name, TN color name, or hex. Will warn if not an approved color.
#' @param axis_line_color Color name, TN color name, or hex. Will warn if not an approved color.
#' @param caption_color Color name, TN color name, or hex. Will warn if not an approved color.
#' @param background_color Color name, TN color name, or hex. Will warn if not an approved color.
#'
#'
#' @export
#'

theme_tn <- function(title_color=NA
                     ,subtitle_color=NA
                     ,axis_text_color=NA
                     ,axis_line_color=NA
                     ,caption_color=NA
                     ,background_color=NA){
  font<-'Open Sans'
  sysfonts::font_add_google(font,font)
  showtext::showtext_auto()

  for(i in c('title_color','subtitle_color','axis_text_color','axis_line_color','caption_color','background_color')){
    if(i=='background_color'){
      if(is.na(get(i))) assign(i,'white')
    }
    assign(i,tn_validate_color(get(i)))
  }

  ggplot2::theme_classic() %+replace%
    theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill=background_color, color=NA),
      plot.background = ggplot2::element_rect(fill=background_color, color=NA),
      legend.background = ggplot2::element_rect(fill=background_color, color=NA),
      legend.box.background = ggplot2::element_rect(fill=background_color, color=NA),
      plot.title = ggplot2::element_text(family = font,size = 20,face = 'bold',vjust = 1,color=title_color),
      plot.subtitle = ggplot2::element_text(family = font,size = 12,vjust = .5,color=subtitle_color),
      plot.caption = ggplot2::element_text(family = font,size = 9,color=caption_color),
      axis.title = ggplot2::element_text(family = font,size = 10,color=axis_text_color),
      axis.text = ggplot2::element_text(family = font,size = 9,color=axis_text_color),
      axis.line = ggplot2::element_line(color=axis_line_color,linewidth = 1,lineend = 'round'),
      axis.ticks = ggplot2::element_line(color=axis_line_color,lineend = 'round'),
      legend.title = ggplot2::element_text(family = font,size = 10,color=axis_text_color),
      legend.text = ggplot2::element_text(family = font,size = 9,color=axis_text_color)
    )
}

#' Check that a color is branding compliant
#'
#' @param color Color string, hex, or TN name
#'
#' @return Hex color if valid TN color, original input otherwise
#' @export
tn_validate_color<-function(color){
  color<-tolower(color)
    if(is.na(color)){ return('black')
    }else if(color %in% tn_colors$Name1 ){return(tn_colors$hex[tn_colors$Name1==color])
    }else if(color %in% tn_colors$Name2 ){return(tn_colors$hex[tn_colors$Name2==color])
    }else if(color %in% c(tn_colors$hex,'white','black','transparent') ){return(color)
    }else{
      color_rec<-''
      if(color %in% tn_colors$Family){
        alt_col<-unique(tn_colors$Name1[tn_colors$Family==color])
        alt_col<-alt_col[alt_col!='']
        color_rec<-paste0(' Branding compliant options that are similar include: ', paste0(alt_col, collapse = ', '))
      }
      warning(paste0(color,' is not compliant with TN branding.',color_rec))
    }
    return(color)
}

#' List of TN logo names
#'
#' List of TN logo names
#'
#' @export
tn_logo_names<-function(){
  return(tn_logo_name_list)
}

#' List of TN palette names
#'
#' @export
tn_palette_names<-function(){
names(tn_palettes)
  }


#' Load a TN logo
#'
#' @param name Name of logo from tn_logo_names
#'
#' @export
tn_logo_fetch <- function(name) {
    magick::image_read(system.file(paste0("logos/",name,".png"), package="TNTools"))
}


#' Add a TN logo to a plot
#'
#' @param plot ggplot object to add on to
#' @param logo Name of logo from tn_logo_names
#' @param size Vertical size of logo in relation to entire plot. size=.1 means the logo will take up a tenth of the vertical space
#' @param position String specifying top/bottom and left/center/right position of logo
#' @param margin Space around entire output in mm
#' @param vjust Vertical justification 0-1. 0 places the logo entirely inside the plot. 1 places the logo entirely outside.
#'
#' @export
#'
add_tn_logo<-function(plot,logo,size=.1,position = 'bottom left', margin = 1, vjust=1){

  if(grepl('image',class(logo), ignore.case = T)){

  }else if(class(logo)=='character'){
    if(tolower(logo) %in% tolower(tn_logo_names())){
      logo<-tn_logo_fetch(logo)
    }else{
    logo <- image_magick::image_read(logo)
    }
  }else {
    stop('Invalid logo. Must be an image object, file path, or one of tn_logo_names()')
  }

lfi<-image_magick::image_info(logo)
ar<-lfi$height/lfi$width

top<-F

if(grepl('top',position, ignore.case = T)){
  top<-T
  l_y<-1
  l_vjust<-1
}else if(grepl('bottom',position, ignore.case = T)){
  l_y<-0
  l_vjust<-0
}else{
  stop('Position must include top or bottom')
}

if(grepl('left',position, ignore.case = T)){
  l_x<-0
  l_hjust<-0
}else if(grepl('right',position, ignore.case = T)){
  l_x<-1
  l_hjust<-1
}else if(grepl('center',position, ignore.case = T)){
  l_x<-.5
  l_hjust<-.5
}else{
  stop('Position must include left, right, or center')
}

  p_h<- 1-(size*vjust)
  p_y<-size*vjust
  if(top) p_y<-0

cowplot::ggdraw() +
  cowplot::draw_plot(plot, x=0, y=p_y, width=1, height=p_h) +
  cowplot::draw_image(logo, x=l_x,y=l_y, width=size/ar, height=size, hjust=l_hjust, vjust=l_vjust) +
  ggplot2::theme(plot.margin = ggplot2::unit(rep(margin/10,4),'lines'))

}


#' Show all branding approved colors organized by palette
#'
#' @param palette Optional filter to limit colors to certain palettes
#' @param labels Boolean indicating whether color info should be shown
#' @param duplicates Boolean indicating whether to show each color once, even if it is in multiple palettes
#'
#' @export
#'
tn_palette_show<-function(palette=NA){
color_df<-tn_colors

if(!any(is.na(palette))){
  if (any(!palette %in% names(tn_palettes))) stop(paste0('Invalid palette: palette must be NA or selection from ',paste0(names(tn_palettes), collapse = ', ')))
  color_df<-color_df[color_df$Palette %in% palette,]
}

color_df$Palette<-factor(color_df$Palette, levels = rev(unique(color_df$Palette)))
color_df$Position<-factor(nrow(color_df):1)
tn_color_hex<-color_df$hex
names(tn_color_hex)<-color_df$Position

ggplot2::ggplot(color_df, ggplot2::aes(y=Palette, fill=Position)) +
  ggplot2::geom_bar(color='black', width=1,position='fill', show.legend = F) +
  ggplot2::scale_fill_manual(values=tn_color_hex) +
  ggplot2::coord_cartesian(xlim=c(0,1), expand = F) +
  ggplot2::scale_x_reverse() +
  ggplot2::theme(axis.title = ggplot2::element_blank(),
                            axis.text.x = ggplot2::element_blank(),
                            axis.ticks = ggplot2::element_blank(),
                            plot.background = ggplot2::element_rect(color = 'white', fill = 'white'),
                            panel.background = ggplot2::element_rect(color = 'white', fill = 'white'))
}


#' Show all branding approved colors
#'
#' @param palette Optional filter to limit colors to certain palettes
#' @param labels Boolean indicating whether color info should be shown
#' @param duplicates Boolean indicating whether to show each color once, even if it is in multiple palettes
#'
#' @export
#'
tn_color_show<-function (palette=NA ,labels = T, duplicates=T){
  color_df<-tn_colors[,c('Palette','hex','Name2','Name1')]
  color_df$Name2[color_df$Name2=='']<-color_df$Name1[color_df$Name2=='']
  if(!duplicates){
    color_df<-color_df[,c('hex','Name2')]
    color_df<-color_df[!duplicated(color_df),]
  }else{
    color_df<-color_df[,c('Palette','hex','Name2')]
  }

  if(!any(is.na(palette))){
    if (any(!palette %in% names(tn_palettes))) stop(paste0('Invalid palette: palette must be NA or selection from ',paste0(names(tn_palettes), collapse = ', ')))
    color_df<-color_df[color_df$Palette %in% palette,]
  }
  colours<-color_df$hex
  color_labels<-apply(color_df, 1, paste0, collapse='\n')
  n <- length(colours)
  ncol <- max(ceiling(sqrt(length(colours))),1)
  nrow <- ceiling(n/ncol)
  colours <- c(colours, rep(NA, nrow * ncol - length(colours)))
  colours <- matrix(colours, ncol = ncol, byrow = TRUE)
  color_labels <- c(color_labels, rep(NA, nrow * ncol - length(color_labels)))
  color_labels <- matrix(color_labels, ncol = ncol, byrow = TRUE)
  old <- par(pty = "s", mar = c(0, 0, 0, 0), cex=.5)
  on.exit(par(old))
  size <- max(dim(colours))
  plot(c(0, size), c(0, -size), type = "n", xlab = "", ylab = "",
       axes = FALSE)
  rect(col(colours) - 1, -row(colours) + 1, col(colours), -row(colours),
       col = colours)
  if (labels) {
    hcl <- farver::decode_colour(colours, "rgb", "hcl")
    label_col <- ifelse(hcl[, "l"] > 50, "black", "white")
    text(col(colours) - 0.5, -row(colours) + 0.5, color_labels, col = label_col)
  }
}


#' Return function to interpolate a TN color palette
#'
#' @param palette Character name of palette in tn_palettes
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Optional arguments passed on to colorRampPalette
#'
#' @export
tn_pal <- function(palette = "Primary", reverse = FALSE, ...) {
  pal <- tn_palettes[[palette]]
  if (reverse) pal <- rev(pal)
  pal<-colorRampPalette(pal, ...)
  return(pal)
}


#' Color scale constructor for TN colors
#'
#' @param palette Character name of palette in tn_palettes
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param interpolate Boolean indicating whether colors should be interpolated from the palette if the color aesthetic is discrete
#' @param ... Additional arguments passed to discrete_scale or
#'            scale_color_gradientn, used respectively when discrete is TRUE or FALSE
#' @export
#'
scale_color_tn <- function(palette = "Primary", discrete = TRUE, reverse = FALSE, interpolate=FALSE, ...) {

  if(!palette %in% names(tn_palettes)) stop(paste0('Invalid palette name. Options include: ', paste0(names(tn_palettes), collapse = ', ')))
  pal <- tn_pal(palette = palette, reverse = reverse)

  if (discrete) {
    if(interpolate){
    ggplot2::discrete_scale("color", paste0("tn_", palette), palette = pal, ...)
    }else{
      pal<-tn_palettes[[palette]]
      names(pal)<-NULL
      if(reverse) pal<-rev(pal)
      ggplot2::scale_color_manual(values = pal)
    }
  } else {
    ggplot2::scale_color_gradientn(colours = pal(256)
                                   , ...
                                   )
  }
}



#' Fill scale constructor for TN colors
#'
#' @param palette Character name of palette in tn_palettes
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param interpolate Boolean indicating whether colors should be interpolated from the palette if the color aesthetic is discrete
#' @param ... Additional arguments passed to discrete_scale or
#'            scale_fill_gradientn, used respectively when discrete is TRUE or FALSE
#' @export
#'
scale_fill_tn <- function(palette = "Primary", discrete = TRUE, reverse = FALSE, interpolate=FALSE, ...) {

  if(!palette %in% names(tn_palettes)) stop(paste0('Invalid palette name. Options include: ', paste0(names(tn_palettes), collapse = ', ')))


  pal <- tn_pal(palette = palette, reverse = reverse)

  if (discrete) {
    if(interpolate){
      ggplot2::discrete_scale("fill", paste0("tn_", palette), palette = pal
                              , ...
                              )
    }else{
      pal<-tn_palettes[[palette]]
      names(pal)<-NULL
      if(reverse) pal<-rev(pal)
      ggplot2::scale_fill_manual(values = pal)
    }
  } else {
    ggplot2::scale_fill_gradientn(colours = pal(256)
                                  , ...
                                  )
  }
}


