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


source('data-raw/makePieces.R')
pdf('pieces.pdf',width=15,height=3)
par(mfrow=c(3,15))
par(mar=c(0,0,0,0))
for(ii in pieces){
  plot(1,1,type='n',xlim=c(-.5,.5),ylim=c(-.5,.5),xlab='',ylab='',xaxt='n',yaxt='n')
  lapply(ii,function(xx)polygon(points[xx,c('x','y')],col='black'))
}
plot(1,1,type='n',xlim=c(-.5,.5),ylim=c(-1,1),xlab='',ylab='',xaxt='n',yaxt='n')
text(points$x,points$y,points$id)
dev.off()

generateIdenticon<-function(seed=(runif(1,0,1e9)),nSquare=4,col=rgb(runif(1,0,.95),runif(1,0,.95),runif(1,0,.95)),back=NA){
  if(is.character(seed))seed<-eval(parse(text=sprintf('0x%s',digest::digest(seed,algo='murmur32')))) %% .Machine$integer.max
  print(seed)
  runif(1) #make sure .Random.seed exists
  oldSeed <- .Random.seed
  on.exit(.Random.seed <<- oldSeed)
  set.seed(seed)
  centers<-data.frame('id'=1:nSquare^2,'x'=rep(1:nSquare,nSquare),'y'=rep(1:nSquare,each=nSquare),stringsAsFactors=FALSE)
  centers$type<-paste(ceiling(abs(centers$x-(nSquare+1)/2)), ceiling(abs(centers$y-(nSquare+1)/2)))
  centers$rot<-ave(centers$x,centers$type,FUN=function(xx)if(length(xx)==1)0 else(c(0,1,3,2))) #assume 1 or 4 repititions
  types<-data.frame('id'=unique(centers$type))
  types$shape<-sample(1:length(pieces),nrow(types),TRUE)
  types$invert<-sample(c(TRUE,FALSE),nrow(types),TRUE)
  types$col<-ifelse(types$invert,back,col)
  types$back<-ifelse(types$invert,col,back)
  types$rotate<-sample(1:4,nrow(types),TRUE)
  rownames(types)<-types$id
  return(list('types'=types,'centers'=centers,'nSquare'=nSquare))
}

plotIdenticon<-function(identicon=generateIdenticon(...),...){
  rotCols<-c('rot1','rot2','rot3','rot4')
  types<-identicon$types
  centers<-identicon$centers
  plot(1,1,type='n',xlim=c(.5,identicon$nSquare+.5),ylim=c(.5,identicon$nSquare+.5),xlab='',ylab='',xaxt='n',yaxt='n',bty='n')
  rect(centers$x-.5,centers$y-.5,centers$x+.5,centers$y+.5,col=types[centers$type,'back'],border=types[centers$type,'back'],lwd=ifelse(types[centers$type,'invert'],.01,.02))
  for(ii in 1:nrow(types)){
    thisCenters<-centers[centers$type==types[ii,'id'],]
    print(thisCenters)
    thisShape<-pieces[[types[ii,'shape']]]
    sapply(thisShape,function(xx){
      thisPoints<-lapply(thisCenters$rot,function(rot)c(points[xx,rotCols[((types[ii,'rotate']+rot) %%4)+1]],NA)) #rotate and add NA for polygon breaks
      repPoints<-unlist(thisPoints)
      polygon(rep(thisCenters$x,each=length(thisPoints[[1]]))+points[repPoints,'x'],rep(thisCenters$y,each=length(thisPoints[[1]]))+points[repPoints,'y'],col=types[ii,'col'],border=types[ii,'col'],lwd=ifelse(types[ii,'invert'],.02,.01))
    })
  }
  print(types)
}
pdf('test.pdf')
for(ii in 1:10)plotIdenticon(nSquare=4,col='red',back=NA)
for(ii in 1:10)plotIdenticon(nSquare=4,col='red',back='blue')
dev.off()
