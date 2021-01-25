#' Functions to generate identicons
#'
#' Produce a randomly generated pattern identicon for a given seed input
#'
#' The main functions are:
#'      \describe{
#'        \item{\code{\link{generateIdenticon}}:}{to randomly generate an assortment of shapes from a given seed}
#'        \item{\code{\link{plotIdenticon}}:}{plot the assortment of shapes}
#'      }
#'
#' @docType package
#' @name identiconr
#' @author Scott Sherrill-Mix, \email{shescott@@upenn.edu}
#' @examples
#' par(mfrow=c(3,3),mar=c(.1,.1,.1,.1))
#' for(ii in 1:9)plotIdenticon()
#' par(mfrow=c(2,2),mar=c(.1,.1,.1,.1))
#' plotIdenticon(generateIdenticon('test'))
#' plotIdenticon(generateIdenticon('not test'))
#' plotIdenticon(generateIdenticon('test'))
#' plotIdenticon(generateIdenticon('not test'))
NULL


#pdf('pieces.pdf',width=15,height=3)
#par(mfrow=c(3,15))
#par(mar=c(0,0,0,0))
#for(ii in identiconr::pieces){
  #plot(1,1,type='n',xlim=c(-.5,.5),ylim=c(-.5,.5),xlab='',ylab='',xaxt='n',yaxt='n')
  #lapply(ii,function(xx)polygon(identiconr::points[xx,c('x','y')],col='black'))
#}
#plot(1,1,type='n',xlim=c(-.5,.5),ylim=c(-1,1),xlab='',ylab='',xaxt='n',yaxt='n')
#text(identiconr::points$x,identiconr::points$y,identiconr::points$id)
#dev.off()

#' Randomly generate identicon pieces for a given seed
#' 
#' Take a seed and generate an random pattern identicon.
#'
#' @param seed Either an integer or character seed for generating the identicon. If a character seed then the seed is converted to an integer through a portion of the md5 hash 
#' @param nSquare An integer giving the dimensions of the identicon to be generated. The identicon will be formed of 'nSquare' x 'nSquare' pieces
#' @param col A color for the foreground of the identicon 
#' @param back A color for the background of the identicon 
#'
#' @return A list of three items: 'types' giving a data.frame of the color and shape selected for each position of the identicon, 'centers' giving arbitrary positions for the centers of identicon pieces, 'nSquare' giving the number of squares in the identicon
#'
#' @export
#' 
#' @examples
#' id1<-generateIdenticon('emailNumber1@email.com')
#' id2<-generateIdenticon('emailNumber2@email.com')
#' id3<-generateIdenticon('emailNumber1@email.com')
#' all(mapply(identical,id1,id2))
#' all(mapply(identical,id1,id3))
#' par(mfrow=c(1,3))
#' plotIdenticon(id1)
#' plotIdenticon(id2)
#' plotIdenticon(id3)
#'
generateIdenticon<-function(seed=(stats::runif(1,0,1e9)),nSquare=4,col=grDevices::rgb(stats::runif(1,0,.95),stats::runif(1,0,.95),stats::runif(1,0,.95)),back='white'){
  if(is.character(seed))seed<-eval(parse(text=sprintf('0x%s',substring(digest::digest(seed),1,8)))) %% .Machine$integer.max
  stats::runif(1) #make sure .Random.seed exists
  oldSeed <- .Random.seed
  on.exit(.Random.seed <<- oldSeed)
  set.seed(seed)
  centers<-data.frame('id'=1:nSquare^2,'x'=rep(1:nSquare,nSquare),'y'=rep(1:nSquare,each=nSquare),stringsAsFactors=FALSE)
  centers$type<-paste(ceiling(abs(centers$x-(nSquare+1)/2)), ceiling(abs(centers$y-(nSquare+1)/2)))
  centers$rot<-stats::ave(centers$x,centers$type,FUN=function(xx)if(length(xx)==1)0 else if(length(xx)==2)c(0,2) else c(0,1,3,2)) #assume 1 or 4 repititions
  types<-data.frame('id'=unique(centers$type))
  types$shape<-sample(1:length(identiconr::pieces),nrow(types),TRUE)
  types$invert<-sample(c(TRUE,FALSE),nrow(types),TRUE)
  types$col<-ifelse(types$invert,back,col)
  types$back<-ifelse(types$invert,col,back)
  types$rotate<-sample(1:4,nrow(types),TRUE)
  rownames(types)<-types$id
  return(list('types'=types,'centers'=centers,'nSquare'=nSquare))
}

#' Plot an identicon for a given assortment of pieces or seed
#' 
#' Plot a given identicon pattern
#'
#' @param identicon An identicon list output from generateIdenticon
#' @param ... Additional arguments to generateIdenticon
#'
#' @return NULL
#'
#' @export
#' 
#' @examples
#' plotIdenticon(seed='emailNumber1@email.com')
#' plotIdenticon(seed='emailNumber2@email.com')
#' plotIdenticon(seed='emailNumber1@email.com')
#' par(mfrow=c(4,4),mar=c(0,0,0,0))
#' for(ii in 1:16)plotIdenticon()
plotIdenticon<-function(identicon=generateIdenticon(...),...){
  rotCols<-c('rot1','rot2','rot3','rot4')
  types<-identicon$types
  centers<-identicon$centers
  plot(1,1,type='n',xlim=c(.5,identicon$nSquare+.5),ylim=c(.5,identicon$nSquare+.5),xlab='',ylab='',xaxt='n',yaxt='n',bty='n',xaxs='i',yaxs='i')
  graphics::rect(centers$x-.5,centers$y-.5,centers$x+.5,centers$y+.5,col=types[centers$type,'back'],border=types[centers$type,'back'],lwd=ifelse(types[centers$type,'invert'],.01,.02))
  for(ii in 1:nrow(types)){
    thisCenters<-centers[centers$type==types[ii,'id'],]
    thisShape<-identiconr::pieces[[types[ii,'shape']]]
    sapply(thisShape,function(xx){
      thisPoints<-lapply(thisCenters$rot,function(rot)c(identiconr::points[xx,rotCols[((types[ii,'rotate']+rot) %%4)+1]],NA)) #rotate and add NA for polygon breaks
      repPoints<-unlist(thisPoints)
      graphics::polygon(rep(thisCenters$x,each=length(thisPoints[[1]]))+identiconr::points[repPoints,'x'],rep(thisCenters$y,each=length(thisPoints[[1]]))+identiconr::points[repPoints,'y'],col=types[ii,'col'],border=types[ii,'col'],lwd=ifelse(types[ii,'invert'],.02,.01))
    })
  }
  return(NULL)
}

#' Coordinates for identicon points
#'
#' A data.frame containing x, y coordinates and rotation conversions for points used in drawing identicon shapes
#'
#' @docType data
#' @format A data.frame with columns id, x, y and rot1, rot2, 
#' @source system.file("data-raw", "makePieces.R", package = "identiconr")
"points"


#' Shapes for indenticon generation
#'
#' A data.frame containing x, y coordinates and rotation conversions for points used in drawing identicon shapes
#'
#' @docType data
#' @format A list with each item containing a list of shapes where each item is a list definining the point IDs for a potential shape selected in identicon
#' @source system.file("data-raw", "makePieces.R", package = "identiconr")
"pieces"

