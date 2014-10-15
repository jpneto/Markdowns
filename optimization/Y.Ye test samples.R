#################################################################################
##
##   R package Rsolnp by Alexios Ghalanos and Stefan Theussl Copyright (C) 2009
##   This file is part of the R package Rsolnp.
##
##   The R package Rsolnp is free software: you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##
##   The R package Rsolnp is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
#################################################################################
#rm(list=ls())
#setwd("C:/users/agh710/documents/eclipse/Rsolnp/R/")
#source("misc.R")
#source("subnp.R")
#source("solnp.R")


#---------------------------------------------------------------------------------
# POWEL Problem
fn1=function(x)
{
	exp(x[1]*x[2]*x[3]*x[4]*x[5])
}

Jn1=function(x){
	z1=x[1]*x[1]+x[2]*x[2]+x[3]*x[3]+x[4]*x[4]+x[5]*x[5]
	z2=x[2]*x[3]-5*x[4]*x[5]
	z3=x[1]*x[1]*x[1]+x[2]*x[2]*x[2]
	return(c(z1,z2,z3))
}


pars1=c(-2,2,2,-1,-1)
ctrl=list(TOL=1e-6,DELTA=1e-8)
powell=solnp(pars1, Jfun=fn1, Efun=Jn1, EQ=c(10,0,-1), control=ctrl))
#---------------------------------------------------------------------------------
# WRIGHT4 Problem
fn2=function(x)
{
	(x[1]-1)^2+(x[1]-x[2])^2+(x[2]-x[3])^3+(x[3]-x[4])^4+(x[4]-x[5])^4
}

Jn2=function(x){
	z1=x[1]+x[2]*x[2]+x[3]*x[3]*x[3]
	z2=x[2]-x[3]*x[3]+x[4]
	z3=x[1]*x[5]
	return(c(z1,z2,z3))
}

pars2=c(1,1,1,1,1)
ctrl=list(TOL=1e-6,DELTA=1e-8)
wright4<-solnp(pars2, Jfun=fn2, Efun=Jn2, EQ=c(2+3*sqrt(2),-2+2*sqrt(2),2),
control=ctrl)
#---------------------------------------------------------------------------------
# WRIGHT9 Problem
fn3=function(x)
{
	10*x[1]*x[4]-6*x[3]*x[2]*x[2]+x[2]*(x[1]*x[1]*x[1])+
			9*sin(x[5]-x[3])+x[5]^4*x[4]*x[4]*x[2]*x[2]*x[2]
}

Jn3=function(x){
	z1=x[1]*x[1]+x[2]*x[2]+x[3]*x[3]+x[4]*x[4]+x[5]*x[5]
	z2=x[1]*x[1]*x[3]-x[4]*x[5]
	z3=x[2]*x[2]*x[4]+10*x[1]*x[5]
	return(c(z1,z2,z3))
}


jLB3=c(-100,-2,5)
jUB3=c(20,100,100)

pars3=c(1,1,1,1,1)
ctrl=list(TOL=1e-6,DELTA=1e-8)
wright9<-solnp(pars3, Jfun=fn3, Efun=NULL, EQ=NULL, Ifun=Jn3, ILB=jLB3, IUB=jUB3, 
control=ctrl)
#---------------------------------------------------------------------------------
# ALKYLA Problem
fn4=function(x,...)
{
	-0.63*x[4]*x[7]+50.4*x[1]+3.5*x[2]+x[3]+33.6*x[5]
}

Jn4=function(x,...){
	z1=(1.12*x[1]+0.13167*x[1]*x[8]-0.00667*x[1]*x[8]*x[8])/x[4]
	z2=(1.098*x[8]-0.038*x[8]*x[8]+0.325*x[6]+57.25)/x[7]
	z3=(-0.222*x[10]+35.82)/x[9]
	z4=(3*x[7]-133)/x[10]
	return(c(z1,z2,z3,z4))
}

Kn4=function(x,...){
	z1=98*x[3]-0.1*x[4]*x[6]*x[9]-x[3]*x[6]
	z2=1000*x[2]+100*x[5]-100*x[1]*x[8]
	z3=122*x[4]-100*x[1]-100*x[5]
	return(c(z1,z2,z3))
}
jLB4=c(0.99,0.99,0.9,0.99)
jUB4=c(100/99,100/99,10/9,100/99)
kEQ4=c(0,0,0)
xLB4=c(0,0,0,10,0,85,10,3,1,145)
xUB4=c(20,16,120,50,20,93,95,12,4,162)

pars4=c(17.45,12,110,30,19.74,89.2,92.8,8,3.6,155)
ctrl=list(RHO=0, TOL=1e-5,DELTA=1e-5)
alkyla<-solnp(pars4, Jfun=fn4, Efun=Kn4, EQ=kEQ4, Ifun=Jn4, ILB=jLB4, IUB=jUB4, LB=xLB4,
		UB=xUB4, control=ctrl)

#---------------------------------------------------------------------------------
# Entropy Problem
fn5<-function(x,...){
	m=length(x)
	f=0
	for(i in 1:m){
		f=f-log(x[i])
	}
	ans=f-log(.vnorm(x-1)+0.1)
	ans
}

Kn5<-function(x,...){
	sum(x)
}

xLB5=rep(0,10)
xUB5=rep(1000,10)

pars5=runif(10)
ctrl=list(TOL=1e-6,DELTA=1e-8)
entropy<-solnp(pars5, Jfun=fn5, Efun=Kn5, EQ=10, Ifun=NULL, ILB=NULL, IUB=NULL, LB=xLB5,
		UB=xUB5)

#---------------------------------------------------------------------------------
# Box Problem
fn6<-function(x,...){
	-x[1]*x[2]*x[3]
}

Kn6<-function(x,...){
	4*x[1]*x[2]+2*x[2]*x[3]+2*x[3]*x[1]
}

xLB6=rep(1,3)
xUB6=rep(10,3)

pars6=c(1.1,1.1,9)
ctrl=list(TOL=1e-6,DELTA=1e-8,MAJIT=50)
boxp<-solnp(pars6, Jfun=fn6, Efun=Kn6, EQ=100, Ifun=NULL, ILB=NULL, IUB=NULL, LB=xLB6,
		UB=xUB6,control=ctrl)

pars6=c(5.5,5.5,5.5)
ctrl=list(TOL=1e-6,DELTA=1e-8)
boxp<-solnp(pars6, Jfun=fn6, Efun=Kn6, EQ=100, Ifun=NULL, ILB=NULL, IUB=NULL, LB=xLB6,
		UB=xUB6, control=ctrl)
    