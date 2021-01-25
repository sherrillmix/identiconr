# DNAPlotR

[![Build Status](https://travis-ci.org/sherrillmix/identiconr.svg?branch=master)](https://travis-ci.org/sherrillmix/identiconr)
[![codecov.io](https://codecov.io/github/sherrillmix/identiconr/coverage.svg?branch=master)](https://codecov.io/github/sherrillmix/identiconr?branch=master)

##Install
An R library to generate random identicon patterns. To install directly from github, use the [<code>devtools</code>](https://github.com/hadley/devtools) library and run:


```r
devtools::install_github("sherrillmix/identiconr")
```
Then load the library as normal using:

```r
library(dnaplotr)
```

```
## Error in library(dnaplotr): there is no package called 'dnaplotr'
```

## Main functions
### generateIdenticon 
<code>generateIdenticon(seqs)</code> takes an integer or character seed and generates a corresponding assortment of shapes and colors. For example:


```r
generateIdenticon("test@email.com")
```

```
## Error in generateIdenticon("test@email.com"): could not find function "generateIdenticon"
```

This isn't particularly useful by itself but will usually be used with the following function.

### plotIdenticon
<code>plotIdenticon(seqs)</code> takes the output from <code>generateIdenticon</code> (or a seed directly) and plots them to the current device. For example:


```r
plotIdenticon(generateIdenticon("test@email.com"))
```

```
## Error in plotIdenticon(generateIdenticon("test@email.com")): could not find function "plotIdenticon"
```

```r
plotIdenticon(seed = "abc")
```

```
## Error in plotIdenticon(seed = "abc"): could not find function "plotIdenticon"
```

See [doc/example.pdf](the vignette) for complete plotting details.

