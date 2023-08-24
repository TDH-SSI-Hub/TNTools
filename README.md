TNTools
================

# Overview

This package is a collection of convenience functions and data for TN
Department of Health users. There are several areas addressed, and more
may be added periodically:

- Email: Helper functions for installing RDCOMClient and
  drafting/sending emails using Outlook
- Geocoding: Functions which interface with the TN Geocoding API (needs
  work), as well as TN shapefiles
- ggplot2: Themes, color palettes, and TN logos

### Download this package

``` r
devtools::install_github("TDH-SSI-Hub/TNTools")
library("TNTools")
```

If you can’t install this package, you likely need to install `devtools`
and/or the correct version of `rtools` for your R.

## Sending Emails

Sending Outlook emails in R is very useful, but the `RDCOMClient`
package which enables this is often not available for the current
versions of R on CRAN, and `RDCOMClient` is a very general interface to
many applications with syntax and documentation different from most
other R functions. This package helps you install `RDCOMClient` and
makes sending emails more intuitive. You also need Outlook on your
machine.

### Install `RDCOMClient`

`RDCOMClient` is not a dependency of `TNTools`, since the package is
often not available on CRAN for recent versions of R. You likely need to
install the package from github. I recommend the
[bschamberger](https://github.com/bschamberger/RDCOMClient) or
[omegahat](https://github.com/bschamberger/RDCOMClient) repositories.
`email_setup()` is designed to help install RDCOMClient.

### Sending emails

`email_send()` is a wrapper around `email_draft()`. They both take the
same parameters. By default, `email_draft` will open the email in the
visual editor without sending the email. In contrast, `email_send()`
defaults to sending an email without showing it in the visual editor.
Either function can act as the other if you change the `send` and
`visible` parameters.

``` r
# Send a basic email
email_send(to = 'example@gmail.com',
            subject = 'Automated Email',
            body='Final email body.'
           )
```

Each function also creates 2 objects in the global environment:

1.  `outApp` represents the Outlook Application

2.  `outMail` represents the created email

So you can use adapted methods and properties from the [Outlook VBA
guide](https://learn.microsoft.com/en-us/office/vba/api/overview/outlook)
to work with the email.

``` r
# Draft and open an email
email_draft(to = 'example@gmail.com',
            subject = 'Automated Email',
            body=''
            )
# Make manual edits in the Outlook visual editor

# Or make edits in R
outMail[['body']] <- 'Please do not respond'

# Send the email using RDCOMClient syntax
outMail$Send()
```

## TN Geocoding

The TN geocoding API should be used for geocoding whenever possible,
since it is updated monthly. The goal for this section of TNTools is to
make an easy interface to the geocoder. This area is under active
development.

## `ggplot2` and Branding

TN branding requirements specify certain fonts and colors for public
facing reports and dashboards. The `theme_tn()` function sets plot fonts
to Open Sans and simplifies the default theme.

``` r
flowers <- ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  ggtitle('Flowers') +
  theme_tn()
  
flowers
```

![](README_files/figure-commonmark/theme_basic-1.png)

In addition, you can set the color for various plot elements using the
function parameters. If a color is not branding compliant, a warning
will be generated.

``` r
flowers <- ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  ggtitle('Flowers') +
  theme_tn(axis_line_color = 'OfficialBlue',
           axis_text_color = 'OfficialRed',
           title_color = 'OfficialBlue') 

flowers
```

![](README_files/figure-commonmark/theme_color-1.png)

Official hex colors can be found using `tn_color_names()` or
`tn_colors_show()`. This function can be filtered by palette to make it
less crowded. It includes the hex code, palette, and TN specific names
for the colors.

``` r
tn_color_show()
```

![](README_files/figure-commonmark/color_show-1.png)

### Color Palettes

Color palettes are also available for use. Use `tn_palette_show()` to
see them.

``` r
tn_palette_show()
```

![](README_files/figure-commonmark/palette_show-1.png)

These palettes can be used with another set of custom functions:
`scale_fill_tn()` and `scale_color_tn()`. When the `TNTools` package is
loaded, the default ggplot discrete palette is changed to the ‘Default’
TN palette. This is also the default palette for the `scale_*_tn`
functions, but other palettes can be supplied.

``` r
flowers <- flowers +
  scale_color_tn('Contrast')

flowers
```

![](README_files/figure-commonmark/scales-1.png)

For continuous scales, use `discrete=FALSE`. This will result in colors
on the plot which do not conform to the branding standard because
intermediate colors are interpolated from the chosen palette. Unlike its
effect on discrete scales, loading `TNTools` does not change the
continuous scale color or fill defaults.

To disable or enable the TN default scale coloring, you can use
`tn_ggplot_color_off()` and `tn_ggplot_color_on()`.

### Logos

Finally, the `add_tn_logo()` function can place one of several logos
onto a plot object. The logo can be specified as a string from
`tn_logo_names()` and the position can be on the top or bottom of the
plot, in the left, right, or center (using the `position` parameter).

``` r
add_tn_logo(plot = flowers
            , logo = "TN Dept of Health Color"
            , position = 'top right')
```

![](README_files/figure-commonmark/logos-1.png)

The logo can be moved inside the plot area by setting `vjust = 0`.

``` r
add_tn_logo(plot = flowers
            , logo = "TN Dept of Health Color"
            , position = 'top right'
            , vjust = 0)
```

![](README_files/figure-commonmark/logos_vjust-1.png)
