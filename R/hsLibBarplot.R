# Created: 2011-12-07
# Updated: 2012-08-31

# hsBpDefaultXlim --------------------------------------------------------------
hsBpDefaultXlim <- function
### hsBpDefaultXlim
(
  position, barGroupWidth=1
) 
{
  c(min(position)-max(barGroupWidth)/2, 
    max(position)+max(barGroupWidth)/2)
}

# hsBpGetXlim ------------------------------------------------------------------
hsBpGetXlim <- function
### hsBpGetXlim
(
  myData, 
  myWidth=1, 
  mySpace=NULL, 
  myBeside=FALSE
) 
{
  # Get number of bar groups and number of bars per group
  Nn <- hsBpNumBars(myData, myBeside)
  N <- Nn[1]
  print(paste("N =", N))

  # Default spaces
  if (is.null(mySpace)) {
    if (is.matrix(myData) & myBeside) {
      mySpace = 1
    }
    else {
      mySpace = 0.2
    }
  }
  
  # scaling factor
  sf <- mean(myWidth)

  print(paste("scaling factor:", sf))
  
  # minimum is after first space
  mi <- mySpace[1] * sf
  
  # maximum is after N bar groups and N spaces
  s1 <- sum(rep(mySpace, length.out = N))
  s2 <- sum(rep(myWidth, length.out = N))
  ma <- sf * s1 + s2
  print(paste("s1 =", s1, " s2 =", s2, " ma =", ma))
  c(mi, ma)
}

# hsBpBargroupWidth ------------------------------------------------------------
hsBpBargroupWidth <- function
### hsBpBargroupWidth
(
  myWidth, 
  myBarsPerGroup, 
  myInnerSpace
) 
{
  # The widths given in w represent the widths of the bars in one group. 
  # The width W of the total bar group is calculated as 
  # W = sum of bar widths in group minus (n-1)*spi with n = number of bars 
  # per group and spi = inner space between bars in a bar group.  

  # Make myWidth as long as needed
  if (length(myWidth) > myBarsPerGroup) {
    myWidth <- myWidth[1:myBarsPerGroup] # Shorten myWidth
  }
  else {
    # By multiplying with a vector of as many ones as there are bars per group
    # we guarantee to calculate the correct sum of bar widths, even if the 
    # number of elements given in w does not correspond to the number of bars 
    # per group.
    myWidth <- myWidth*rep(1, myBarsPerGroup) # Enlarge myWidth
  }
  
  # Calculate the bar group width
  sum(myWidth) + (myBarsPerGroup-1)*myInnerSpace
}

# hsBpNumBars ------------------------------------------------------------------
hsBpNumBars <- function
### Number of bar groups (N) and bars per group (n) produced by barplot()
### depending on given data and parameter "beside"
(myData, myBeside) {
  if(is.matrix(myData)) {
    if(myBeside) {
      c(N=ncol(myData), n=nrow(myData))
    }
    else {
      c(N=ncol(myData)*nrow(myData), n=1)
    }    
  }
  else {
    c(N=length(myData), n=1)
  }
### Returns tupel containing N = number of bar groups and n = number of bars
### per group
}

# hsBpSpace --------------------------------------------------------------------
hsBpSpace <- function
### Calculates the spaces between bars of widths w at positions x as 
### difference between the x values minus half the width of the bars/bar groups.
(
myWidth, 
### Bar widths. If bars are to be stacked (isp = NULL, see below) w represents 
### the widths of the different (stacked) bars. If bars are to be arranged 
### side by side (isp >= 0) w represents the widths of the bars within 
### one and the same bar group. Corresponding bars of different groups will 
### always have the same width.
position, 
### X-positions of bars/bar groups
myXlim=NULL,
### Vector containing minimum and maximum x-value to be shown in the plot.
myBeside=FALSE,
### If TRUE, bars of a bar group are not stacked but arranged side by side.
### Then, myWidth contains the widths of the bars within one group. Otherwise
### (myBeside = FALSE) myWidth contains the widths of the (stacked) bars.
barsPerGroup=1,
### Number of bars per group. If this parameter is greater than 1, it means 
### that bars are to be arranged side by side instead of stacked.
innerSpace=0,
### "Inner" space between bars of the same group (only used if bpg > 1). 
dbg=FALSE
) {  
  # Calculation of the widths W of the bars/bar groups. 
  # If bars are to be arranged side by side, the (constant) width W of a whole
  # bar group is calculated. If bars are to be stacked, the width(s) W of the 
  # bar groups are given in myWidth
  if(myBeside) {
    print("Calling hsBpBargroupWidth with:")
    print(myWidth)
    print(barsPerGroup)
    print(innerSpace)
    W <- hsBpBargroupWidth(myWidth, barsPerGroup, innerSpace)
  }
  else {
    W <- myWidth
  }
  
  if (dbg) {
    print(paste("width(s) of bar group(s):", paste(W, collapse=",")), quote=FALSE)
    print(W)
  }
    
  # If no limits are given, set limits to minimal and maximal value
  if (is.null(myXlim)) {
    myXlim <- hsBpDefaultXlim(position, W)
  }

  if (dbg) {
    print(paste("Limits:", paste(myXlim[1], myXlim[2], sep=",")), quote=FALSE)
  }
  
  # Calculation of spaces between bars/bar groups.
  s <- c((position-W/2), myXlim[2]) - c(myXlim[1], (position+W/2))

    if (dbg) {
      print("all Spaces:", quote=FALSE)
      print(s)
    }
        
    # Cut-off the last element of the space vector since it is not needed by the
    # barplot function to be called.
    s <- s[1:(length(position))]
    
    if (dbg) {
      print("spaces without last:", quote=FALSE)
      print(s)
    }
    
    # If bars are arranged in goups and if the bars within one group shall be 
    # arranged side by side ("innner" space isp is given) then we have to 
    # prepare a new space vector s to be passed to R's barplot function. 
    # That vector not only contains the spaces between the bar groups but also 
    # the spaces between the bars within one group.
    # E.g. for 2 groups of 3 bars each: s = c(s1, s2, s3, s4, s5, s6) with
    #   s1: space before 1st bar of 1st group, 
    #   s2: space between 1st and 2nd bar of 1st group, 
    #   s3: space between 2nd and 3rd bar of 1st group, 
    #   s4: space between 3rd bar of 1st group and 1st bar of 2nd group, 
    #   s5: space between 1st and 2nd bar of 2nd group, 
    #   s6: space between 2nd and 3rd bar of 2nd group.  
    if (myBeside) {
      n <- barsPerGroup # nrow(y) # number of bars per group
      N <- length(position) # ncol(y) # number of bar groups
  
      # Initialise a new vector with as many elements as there are bars in 
      # total (number of elements in the matrix y), giving each element the 
      # value of the "inner" space isp.
      tmp <-rep(innerSpace, n*N)
  
      # Overwrite the elements at position 1+0*n, 1+1*n, 1+2*n, ... 1+(N-1)*n
      # with the spaces between the different bar groups.
      tmp[1+(0:(N-1))*n] <- s
  
      # Set the new space vector
      s <- tmp
    }
    # R's barplot function interprets the space values as multiples of the mean
    # bar width. However, we calculated the spaces in units of x.
    s/mean(myWidth)
### Returns a space vector as needed to be passed to the barplot function
}

# hsBarplot --------------------------------------------------------------------
hsBarplot <- function
### Extended version of R barplot function, enabling x positioning of the bars.
(
  myHeight,
  ### Vector or matrix containing the bar heights, see R's barplot function.
  myWidth = 1,
  ### Bar widths. If bars are to be stacked (isp = NULL, see below) w represents 
  ### the widths of the stacked bars. If bars shall be plotted side by side 
  ### instead of stacked (isp >= 0) w represents the widths of the bars within 
  ### one and the same bar group. Corresponding bars of different groups will 
  ### always have the same width.
  myPosition = NULL,
  ### Vector containing the x-positions of the bars/bar groups.
  myXlim = NULL,
  ### Vector containing minimum and maximum x-value to be shown in the plot.
  myBeside = FALSE,
  ### If TRUE, bars within a bar group are arranged side by side instead of
  ### stacked.
  myReverse = FALSE, 
  ### If TRUE, the bars in the plot will reverted, i.e. they will be arranged 
  ### according to decreasing x-values.
  myInnerSpace = 0,
  ### "Inner" space between bars of the same bar group (only relevant if y is 
  ### a matrix and not a vector). If NULL, bars of the same bar group will be 
  ### stacked
  myAxis = TRUE,
  dbg = FALSE,
  myYlim = NULL,
  myValLabs = FALSE,
  ...
) 
{
  if (dbg) {
    cat("-------------------------------\n")
    cat("In hsBarplot():\n")
    cat(sprintf("*** myHeight:\n"))
    print(myHeight)
    cat(sprintf("*** myWidth:      %f\n", myWidth))
    cat(sprintf("*** myPosition:   %s\n", myPosition))
    cat(sprintf("*** myXlim:       %s\n", paste(myXlim)))
    cat(sprintf("*** myBeside:     %s\n", myBeside))
    cat(sprintf("*** myReverse:    %s\n", myReverse))
    cat(sprintf("*** myInnerSpace: %f\n", myInnerSpace))
    cat(sprintf("*** myAxis:       %s\n", myAxis))
  }
  
  # Init vector containing spaces
  mySpace <- NULL
  
  # If x positions of bars are given, calculate spaces and limits
  if (! is.null(myPosition)) {
    
    # Calculate the spaces between the bars/bar groups.
    if (is.null(nrow(myHeight))) {
      n <- 1
    }
    else {
      n <- ifelse(myBeside, nrow(myHeight), 1) # number of bars per group
    }
    
    if (dbg) {
      print(paste("number of bars per group:", n), quote=FALSE)
    }
    
    mySpace <- hsBpSpace(myWidth=myWidth, position=myPosition, 
                         myXlim=myXlim, myBeside=myBeside,barsPerGroup=n, innerSpace=myInnerSpace)
    
    # Calculate the limits
    if (is.null(myXlim)) {
      if (myBeside) {
        myXlim <- hsBpDefaultXlim(myPosition, 
                                  hsBpBargroupWidth(myWidth, n, myInnerSpace))
      }
      else {
        myXlim <- hsBpDefaultXlim(myPosition, myWidth)
      }
    }    
    if (dbg) {
      print(paste("xlim before transition:", paste(myXlim,collapse=",")),quote=FALSE)
    }
    
    # R's barplot function only works as expected (my personal experience)
    # if the x range starts at 0. Therefore why we "shift" the myXlim range to
    # (0,Xmax-Xmin) here.
    myXlim <- c(0, myXlim[2] - myXlim[1])  
  }
  else {
    # If no positions are given, we do not give limits to barplot()
    myXlim = NULL
  }
  
  # R's barplot function is able to arrange the bars "decreasingly" by just
  # switching the x limits...  
  if (myReverse) {
    myXlim = rev(myXlim)
  }
  
  if (dbg) {
    print("Running barplot with:", quote=FALSE)
    print(paste("space =", paste(mySpace,collapse=","), 
                ", xlim =", paste(myXlim,collapse=",")), quote=FALSE)
    print("myHeight:")
    print(myHeight)
  }
  
  # Finally call R's barplot function...  
  barplot(
    height = myHeight, 
    width  = myWidth, 
    space  = mySpace,
    xlim   = myXlim, 
    ylim   = myYlim,
    beside = myBeside,
    ...)
  
  # Add an axis on top
  if (myAxis) {
    if (!is.null(myXlim)) {
      ma <- abs(myXlim[2] - myXlim[1])
      axis(side=3, xaxp=c(0,ma,ma))
    }
    else {
      axis(side=3)
    }
  }
  
  if (myValLabs && myBeside) {
    hsPutValueLabels(myHeight, myPosition, myWidth, mySpace, myYlim[2])
  }
}

# hsPutValueLabels -------------------------------------------------------------
hsPutValueLabels <- function
### Put values on top of the bars
(
  myHeight, 
  myPosition, 
  myWidth, 
  mySpace, 
  myYmax
) 
{
  # Put the values on top of the bars
  i <- 1
  for (myVal in (myHeight)) {
    if (! is.null(myPosition)) {    
      myx <- myPosition[i] - min(myPosition) + myWidth/2
    }
    else {
      ms <- myWidth * ifelse(is.null(mySpace), 0.2, mySpace)
      myx <- ms + (i-1)*(myWidth + ms) + myWidth/2
    }
    myy <- myVal + 0.06 * myYmax
    text(myx, myy, myVal)
    i <- i + 1
  }
}

# hsBarplot2 -------------------------------------------------------------------
hsBarplot2 <- function
### Extended version of R barplot function, enabling x positioning of the bars.
(
  myHeight, 
  ### Vector or matrix containing the bar heights, see R's barplot function.
  myPos = NULL, 
  ### Vector containing the x-positions of the bars/bar groups.
  myWidth = 1, 
  ### Bar widths. If bars are to be stacked (isp = NULL, see below) w represents 
  ### the widths of the stacked bars. If bars shall be plotted side by side 
  ### instead of stacked (isp >= 0) w represents the widths of the bars within 
  ### one and the same bar group. Corresponding bars of different groups will 
  ### always have the same width.
  myBeside = FALSE, 
  ### If TRUE, bars within a bar group are arranged side by side instead of
  ### stacked.
  myInnerSpace = 0, 
  ### "Inner" space between bars of the same bar group (only relevant if y is 
  ### a matrix and not a vector). If NULL, bars of the same bar group will be 
  ### stacked
  myValLabs = TRUE, 
  dx = 0, 
  dy = 0, 
  dbg = FALSE, 
  ...
) 
{

  if (dbg) {
    cat("-------------------------------\n")
    cat("In hsBarplot2():\n")
    cat(sprintf("*** myHeight:     %s\n", paste(myHeight, collapse = ",")))
    print(str(myHeight))
    cat(sprintf("*** myPos:        %s\n", paste(myPos, collapse = ",")))
    cat(sprintf("*** myWidth:      %f\n", myWidth))
    cat(sprintf("*** myBeside:     %s\n", myBeside))
    cat(sprintf("*** myInnerSpace: %f\n", myInnerSpace))
  }
  
  # We expect that all bars have the same width!
  if (length(myWidth) != 1) {
    #@2011-12-19: stop instead of "print" and "return"
    stop("All bars must have the same width (length of myWidth must be one)!\n")
  }
  
  mySpace <- NULL
  N <- ncol(myHeight)
  n <- 1
  if (myBeside) {
    n <- nrow(myHeight)
  }
  cat(paste("N =", N, " (columns), n =", n, " (rows)\n"))  
  
  if (!is.null(myPos)) {
    cat("Positions: ")
    print(myPos)
    w <- n * myWidth + (n-1) * myInnerSpace
    c1 <- c(myPos - w/2, NA) 
    c2 <- c(0, myPos + w/2)
    mySpace <- (c1 - c2)[1:length(myPos)]
    if (myBeside) {
      mySpaceTmp <- mySpace
      mySpace <- rep(myInnerSpace, n * N)
      mySpace[1 + n*(0:(N-1))] <- mySpaceTmp
    }
    mySpace <- mySpace / mean(myWidth)
  }  
  
  # Call barplot   
  barplot(
    height = myHeight, 
    width  = myWidth, 
    space  = mySpace, 
    beside = myBeside,
    ...)
  axis(1)
  grid()

  # If desired, put value labels above the bars  
  if (myValLabs) {
    if (! myBeside) {
      myx <- rep(myPos, nrow(myHeight))
      myy <- 0.5 * myHeight[1,]
      mycum <- myHeight[1,]
      if (nrow(myHeight) > 1) {
        for (i in (2:nrow(myHeight))) {
          myy <- c(myy, mycum + 0.5 * myHeight[i,])
          mycum <- mycum + myHeight[i,]
        }
      }
    }
    else {
      mySpace <- mySpace * mean(myWidth)
      myy <- as.vector(t(myHeight))
      myx <- myPos
      myx <- mySpace[1] + myWidth / 2
      mycum <- mySpace[1] + myWidth
      if (length(myy) > 1) {
        for (i in (2:length(myy))) {
          myx <- c(myx, mycum + mySpace[i] + myWidth/2)
          mycum <- mycum + mySpace[i] + myWidth
        }
      }
    }

    myv <- as.character(as.vector(t(myHeight)))
    myv[myv == 0] <- NA
    if (dbg) {
      cat(sprintf("mySpace: %s\n", paste(mySpace, collapse = ",")))
      cat(sprintf("myx: %s\n", paste(myx, collapse = ",")))
      cat(sprintf("myy: %s\n", paste(myy, collapse = ",")))
      cat(sprintf("myv: %s\n", paste(myv, collapse = ",")))
    }
    # adj = c(0, 0.5): horizontally left justified and vertically centered
    text(x = myx+dx, y = myy+dy, labels = myv, adj = c(0,0.5), cex = 0.7)
    
  }
}
