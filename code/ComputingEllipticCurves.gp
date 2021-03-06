\\ ---------------  GP code  ---------------------------------------
\\
\\ Time-stamp: <2014-11-20 09:52:35 jec>
\\ Description: Routine for computing curves of a given conductor
\\
\\
\\ Original Author:  Ariel Pacetti
\\			    apacetti@dm.uba.ar
\\			    Universidad de Buenos Aires
\\
\\ Created:             12 Nov. 2014
\\

\\ Computation of 2-isogenies and chains of these
read("isogs2.gp");
\\ Computation of general isogenies
read("isogs.gp");
\\ Reduction of cubics with negative discriminant
read("reduce_cubic.gp");

\\======================================================================
\\ Exponent bound assuming some explicit Szpiro's conjecture with
\\ exponent 6.1 and constant 1. Ninfty is the maximum conductor. Note
\\ that if N is odd, then we have an exponent 8 due to the bad model.
\\======================================================================

SzpiroBound(N)=
	{local(fact,Ninfty,expbound,ans);
	fact=factor(N);
	Ninfty=prod(j=1,matsize(fact)[1],if(fact[j,1]==2,2^8,if(fact[j,1]==3,3^5,fact[j,1]^2)));
	expbound=vector(matsize(fact)[1],j,if(fact[j,1]==2,floor(6.1*(log(Ninfty)-log(squarefree(N)/fact[j,1]))/log(fact[j,1])),floor(3*(log(Ninfty)-log(squarefree(N)/fact[j,1]))/log(fact[j,1]))));
	ans=prod(j=1,matsize(fact)[1],fact[j,1]^expbound[j]);
	if(N%2!=0,2^8*ans,ans)
};


\\======================================================================
\\ Routine to given N, compute (using CFT) all extensions with Galois
\\ group S3 ramified only at primes dividing N. This can be improved
\\ to get rid of the extensions which are not S3 (now uses Allomberts
\\ script).


S3extensions(N)=
	{local(quadext,candidates,S3,GaloisData,CubicOnes);
	if(issquarefree(N),,N=squarefree(N));
	quadext=quadraticextensions(N);
	candidates=[];
	for(j=1,length(quadext),
		candidates=concat(candidates,cubicextensions(quadext[j],N)));
	S3=[];
	for(k=1,length(candidates),GaloisData=polgalois(candidates[k]); 
	if([GaloisData[1],GaloisData[2],GaloisData[3]]==[6,-1,2],S3=concat(S3,candidates[k])));
	CubicOnes=[];
	for(k=1,length(S3),CubicOnes=concat(CubicOnes,polredabs(nfsubfields(S3[k],3)[1][1])));
	CubicOnes
};

\\======================================================================
\\ We saturate the ray class group by ideal generators to be able to
\\ apply the Galois action   


C3extensions(N)=
	{local(modulo,QQ,Clgp,subgrupos,C3);
	if(issquarefree(N),,N=squarefree(N));
	QQ=bnfinit(y);
	modulo=if(N%3==0,3*N,N); 
	Clgp=bnrinit(QQ,[modulo,[1]],1);
	subgrupos=setminus(Set(subgrouplist(Clgp.clgp,3)),Set(subgrouplist(Clgp.clgp,2)));
	C3=vector(length(subgrupos),i,rnfkummer(Clgp,subgrupos[i]));
	C3
};

\\======================================================================
\\ Note that K is assumed to be quadratic!

cubicextensions(K,N)=
	{local(modulo,Clgp,subgrupos);
	K=bnfinit(K,1);
	if(issquarefree(N),,N=squarefree(N));
	modulo=N*if(valuation(K.disc,3)==0,3,3^3); 
	if(K.sign[1]!=0,modulo=concat([modulo],[[1,1]]));
	K=subst(K,variable(K),y);
	Clgp=bnrinit(K,modulo,1); 
	subgrupos=setminus(Set(subgrouplist(Clgp.clgp,3)),Set(subgrouplist(Clgp.clgp,2)));
	vector(length(subgrupos),i,(rnfequation(K,rnfpolredbest(K,rnfkummer(Clgp,subgrupos[i])))))
};

\\======================================================================
\\ Routine to compute all quadratic extensions of Q unramified outside N.

quadraticextensions(N)=
	{local(modulo,QQ,Clgp,subgrupos,candidatos2);
	if(issquarefree(N),,N=squarefree(N));
	QQ=bnfinit(y);
	modulo=if(N%2==0,4*N,N); 
	Clgp=bnrinit(QQ,[modulo,[1]],1);
	subgrupos=subgrouplist(Clgp.clgp,2);
	vector(length(subgrupos)-1,i,rnfkummer(Clgp,subgrupos[i]))
};

\\======================================================================	
\\ Stupid routine to remove multiple factors (already in GP?)

squarefree(N)=
	{local(factorization);
	factorization=factor(N)[,1]~;
	prod(i=1,length(factorization),factorization[i])
};


\\======================================================================
\\ Scripts to compute curves with 2-torsion up to 2-isogeny with the
\\ new approach of conductor N, given as its factorization (up to
\\ sign). N is assumed to be an array consisting of pairs [prime,
\\ exponent].


CurvesWith2TorsionofDiscriminant(N)=
	{local(a,b,Disc,curves,bExponents,n);
	curves=[];
	Disc=prod(k=1,length(N),N[k][1]^N[k][2]);
	bExponents=vector(length(N),k,
	    if(N[k][1]==2,
	        if(N[k][2]==5,[0,1],[0]),
    		if(N[k][2]%2==0,[0,N[k][2]/2],
 	            if(N[k][2]==3,[0,1],[0]))));
	b=[1];
	while(bExponents!=[],
	    n=length(b);
	    for(j=1,length(bExponents[length(bExponents)]),
	        b=concat(b,vector(n,k,b[k]*N[length(bExponents)][1]^bExponents[length(bExponents)][j])));
	    bExponents=vectorkill(bExponents,length(bExponents)));
	for(k=1,length(b),
	    if(issquare(Disc/b[k]^2+4*b[k],&a),curves=concat(curves,x^3+a*x^2+b[k]*x));
	    if(issquare(Disc/b[k]^2-4*b[k],&a),curves=concat(curves,x^3+a*x^2-b[k]*x));
	    if(issquare(-Disc/b[k]^2+4*b[k],&a),curves=concat(curves,x^3+a*x^2+b[k]*x));
	    if(issquare(-Disc/b[k]^2-4*b[k],&a),curves=concat(curves,x^3+a*x^2-b[k]*x)));
	curves
};


\\======================================================================
\\ First flag is to use Szpiro or not. Second flag is to compute
\\ twists or not.


CurvesWith2Torsion(N,flag,flag2)=
	{local(discbound,primedivisors,answer,V2T);
	answer=[];
	primedivisors=factor(N)[,1]~;
	if(flag!=0, 
	    discbound=Vec(factor(SzpiroBound(N))~),
	    N=squarefree(2*N);
	    discbound=[[2,if(N%2!=0,6,24)]];
	    if(N%3==0,discbound=concat(discbound,[[3,18]]));
	    for(l=1,length(primedivisors),if(primedivisors[l]%2!=0&&primedivisors[l]%3!=0,discbound=concat(discbound,[[primedivisors[l],12]]))));
        forvec(X=vector(length(discbound),k,[0,discbound[k][2]]),
	    answer=concat(answer,CurvesWith2TorsionofDiscriminant(vector(length(primedivisors),k,[primedivisors[k],X[k]]))));
	answer=Set(answer);
	for(k=1,length(primedivisors),primedivisors[k]*=kronecker(-1,primedivisors[k]));
	answer=vector(length(answer),k,Ell(answer[k]));
	answer=ComputeTwists(answer,primedivisors);
	V2T=answer; 
	if(flag2==0,
	    for(k=1,length(answer),
	        V2T=concat(V2T,two_power_isogs(answer[k]))));
	Set(V2T)
};





\\======================================================================
\\ Curves with one 2-torsion point. If flag=1, use Szpiro's conjecture
\\ routine, if not a "naive bound".

CurvesWith2Torsion2(N,flag)=
	{local(Disc,K,discbound,primedivisors,loopbound,indexbound,answer,Rootvalue,F,Acandidates,V2T,Isogs);
	answer=[];
	primedivisors=factor(N)[,1]~;
	if(flag!=0, 
	    discbound=Vec(factor(SzpiroBound(N))~),
	    N=squarefree(2*N);
	    discbound=[[2,if(N%2!=0,6,24)]];
	    if(N%3==0,discbound=concat(discbound,[[3,18]]));
	    for(l=1,length(primedivisors),if(primedivisors[l]%2!=0&&primedivisors[l]%3!=0,discbound=concat(discbound,[[primedivisors[l],12]]))));

\\ Note that the discbound is a vector whose elements are [prime,exponent]

	forvec(X=vector(length(primedivisors),n,[0,1]),
	  if(X!=vector(length(X)),
	    loopbound=discbound;
	    Disc=prod(t=1,length(X),primedivisors[t]^X[t]);
	    for(k=1,length(X),loopbound[k][2]-=X[k]);
	    if(Disc%4!=1,loopbound[1][2]-=if(Disc%2==0,2,1));
	    indexbound=loopbound;
	    for(k=1,length(loopbound),loopbound[k][2]=(loopbound[k][2]\2));
	    K=if(Disc%4==1,x^2-x+(1-Disc)/4,x^2-Disc);
	    forvec(Y=vector(length(loopbound),k,[0,loopbound[k][2]]),
		Acandidates=indexbound;
		for(k=1,length(Acandidates),Acandidates[k][2]-=2*Y[k]);
		F=prod(k=1,length(primedivisors),primedivisors[k]^(Y[k]));
		Rootvalue=PossibleRoot2(Minimal(K,F),Acandidates);
		for(l=1,length(Rootvalue),answer=concat(answer,(x+Rootvalue[l])*Minimal(K,F))))));
	forvec(X=vector(length(primedivisors),n,[0,1]),
	    loopbound=discbound;
	    Disc=-prod(t=1,length(X),primedivisors[t]^X[t]);
	    for(k=1,length(X),loopbound[k][2]-=X[k]);
	    if(Disc%4!=1,loopbound[1][2]-=if(Disc%2==0,2,1));
	    indexbound=loopbound;
	    for(k=1,length(loopbound),loopbound[k][2]=(loopbound[k][2]\2));
	    K=if(Disc%4==1,x^2-x+(1-Disc)/4,x^2-Disc);
	    forvec(Y=vector(length(loopbound),k,[0,loopbound[k][2]]),
		Acandidates=indexbound;
		for(k=1,length(Acandidates),Acandidates[k][2]-=2*Y[k]);
		F=prod(k=1,length(primedivisors),primedivisors[k]^(Y[k]));
		Rootvalue=PossibleRoot2(Minimal(K,F),Acandidates);
		for(l=1,length(Rootvalue),answer=concat(answer,(x+Rootvalue[l])*Minimal(K,F)))));

	answer=vector(length(answer),k,Ell(answer[k])); print(length(answer));
	answer=Set(vector(length(answer),k,vector(5,j,answer[k][j])));
	for(k=1,length(primedivisors),primedivisors[k]*=kronecker(-1,primedivisors[k]));
	answer=ComputeTwists(answer,primedivisors);
	V2T=answer; 
	for(k=1,length(answer),Isogs=listisog(answer[k]);
	    V2T=concat(V2T,vector(length(Isogs),i,Isogs[i][3])));
	Set(V2T)
};

\\======================================================================
\\ Stupid routine to compute the minimal poly of a*x given that of x

Minimal(pol,a)=
	{local(var);
	var=variable(pol);
	subst(pol,var,var/a)*a^(poldegree(pol))
};



\\======================================================================
\\ Stupid routine to compute rational roots of a polynomial

polrationalroots(P)=
	{local(Fact,ans);
	ans=[];
	Fact=factor(P);
	for(k=1,matsize(Fact)[1],if(poldegree(Fact[k,1])==1,ans=concat(ans,-subst(Fact[k,1],x,0))));
	ans
};

\\======================================================================
\\ Give the possible discriminants. We can ask gcd(a,b,c)=1, so we
\\ check this property.

PossibleRoot2(pol,loopbound)=
	{local(Div,Values,d,Gcd,End);
	Gcd=gcd(polcoeff(pol,1),polcoeff(pol,0));
	End=1;
	while(End<=length(loopbound),if(Gcd%loopbound[End][1],loopbound=vectorkill(loopbound,End),End++));
	
	Values=[]; d=length(loopbound);
	forvec(X=vector(d,k,[0,loopbound[k][2]]),
		Div=prod(k=1,length(loopbound),loopbound[k][1]^X[k]);
		Values=concat(Values,polrationalroots(x^2-x*polcoeff(pol,1)+polcoeff(pol,0)-Div));
		Values=concat(Values,polrationalroots(x^2-x*polcoeff(pol,1)+polcoeff(pol,0)+Div)));
	Set(Values)
};



\\======================================================================
\\ Routines for no 2-torsion curves

\\======================================================================
\\ Compute the cases of big image (S3). Flag is non-zero uses Szpiro's
\\ conjecture.

CurvesWithS3Image(N,flag)=
	{local(fields,curves,K,Ninfty);
	if(issquarefree(N),,N=squarefree(N));
	if(flag!=0,
		Ninfty=SzpiroBound(N),
		N=squarefree(N);
		Ninfty=N^12*if(N%2==0,2^(12),2^6)*if(N%3==0,3^3,1));
	fields=S3extensions(2*N);
	curves=[];
	for(k=1,length(fields),
		K=nfinit(fields[k]);
		curves=concat(curves,CurvesBigImage(K,Ninfty)));
	vector(length(curves),k,Ell(curves[k]))
};

\\======================================================================
\\ Compute given a cubic field, and the discriminant bound, the
\\ elliptic curves whose defining polynomial has discriminant less than
\\ that bound.

CurvesBigImage(K,Ninfty)=
	{local(answer,Orders);
	answer=[]; 
	Orders=CubicFieldSuborders(K,Ninfty); 
	for(k=1,length(Orders),
	    answer=concat(answer,if(sign(K.disc)==1,CubicOrderGenerators1(K,Orders[k]),CubicOrderGenerators2(K,Orders[k]))));
	answer
};

\\======================================================================
\\ Compute the generators of a given oder using thue + reduction, in
\\ the case disc(K)>0 (so the quadratic form is positive definite)

CubicOrderGenerators1(K,Om)=
	{local(zk,Form,quadform,redbasis,redform);
	quadform=CubicFormQuadraticForm(CubicOrderForm(K,Om));
	quadform=Qfb(quadform[1],quadform[2],quadform[3]);
	redform=qfbredsl2(quadform);
	redbasis=CubicOrderGoodBasis(K,concat(concat([Om[1]],redform[2]~*[Om[2],Om[3]]~)~,Om[4]));
	Form=CubicOrderForm(K,redbasis);
	answer=[];
	zk=[redbasis[2],redbasis[3]]; \\print1("#");
\\	print(Form);
	thuevalues=thue(Form,1);
	for(j=1,length(thuevalues),
	        answer=concat(answer,minpoly(Mod(thuevalues[j]*zk~,K.pol))));
	answer
};


\\======================================================================
\\ Compute the generators of a given order using thue + reduction in
\\ the case where disc(K)<0 (using's Cremona algorithm)

CubicOrderGenerators2(K,Om)=
	{local(zk,Form,redbasis);
\\	print(CubicOrderForm(K,Om));
	Form=reduce_negative_cubic(CubicOrderForm(K,Om));
	redbasis=CubicOrderGoodBasis(K,concat(concat([Om[1]],Form[2]~*[Om[2],Om[3]]~)~,Om[4]));
	answer=[];
	zk=[redbasis[2],redbasis[3]]; \\print1("*");
\\	print(Form);
	thuevalues=thue(Form[1],1);
	for(j=1,length(thuevalues),
	        answer=concat(answer,minpoly(Mod(thuevalues[j]*zk~,K.pol))));
	answer
};

\\======================================================================
\\ Compute curves with 3-cyclic image. Flag if non-zero uses Szpiro's bound

CurvesWithC3Image(N,flag)=
	{local(fields,curves,K,Ninfty);
	if(issquarefree(N),,N=squarefree(N));
	if(flag!=0,
		Ninfty=SzpiroBound(N),
		N=squarefree(N);
		Ninfty=N^12*if(N%2==0,2^(6),2^12)*if(N%3==0,3^3,1));
	fields=C3extensions(2*N);
	curves=[];
	for(k=1,length(fields),
		K=nfinit(fields[k]);
		curves=concat(curves,CurvesBigImage(K,Ninfty)));
	vector(length(curves),k,Ell(curves[k]))
};


\\======================================================================
\\ Routines to compute with cubic orders

\\======================================================================
\\ Routine for given a cubic field and a bound, to compute all
\\ suborders whose conductor divides the bound.

CubicFieldSuborders(K,Ninfty)=
	{local(Fact,FF,answer,aux,aux2);
	if(Ninfty%(K.disc)!=0,error("the field discriminant does not divide the bound"));
	if(abs(Ninfty/K.disc)==1,return([CubicOrderGoodBasis(K,concat(K.zk,K.disc))]));
	Fact=factor(abs(Ninfty/K.disc));
	FF=[];for(k=1,matsize(Fact)[1],if(Fact[k,2]!=1,FF=concat(FF,[[Fact[k,1],Fact[k,2]\2]])));

/* Here we need to get all the vertices of the tree. It is done by
 constructing a tree, and then looping over all the constructed
 elements to get the new branches.*/

	aux2=aux=answer=[CubicOrderGoodBasis(K,concat(K.zk,K.disc))];
	while(FF!=[],
	    if(abs(answer[length(answer)][4]<abs(Ninfty)),
	    if(FF[1][2]!=0,aux2=[]; 
	        for(j=1,length(aux),aux2=concat(aux2,CubicOrderSuborder(K,aux[j],FF[1][1])));
		answer=concat(answer,aux2);aux=aux2;
		FF[1][2]--,aux=answer;FF=vectorkill(FF,1)),FF=[]));
	answer
};

\\======================================================================
\\ Cubic orders are 4 coordinate vectors, where the first 3 are the
\\ generators and the last one the discriminant of the order. 

CubicOrderForm(K,R,flag)=
	{local(goodorder,form);
	goodorder=CubicOrderGoodBasis(K,R);
	form=CubicOrderCoordinates(goodorder,lift(goodorder[2]^2*Mod(1,K.pol)));
	form=concat(form,CubicOrderCoordinates(goodorder,lift(goodorder[3]^2*Mod(1,K.pol))));
	if(flag==0,-form[3]*x^3+form[2]*x^2-form[6]*x+form[5],-form[3]*x^3+form[2]*x^2*y-form[6]*x*y^2+form[5]*y^3)
};

\\======================================================================
\\ Routine to compute coordinates

CubicOrderCoordinates(R,v)=
	{local(ordermat);
	ordermat=Mat(vector(3,k,polcoeff(R[1],3-k))~);
	ordermat=concat(ordermat,vector(3,k,polcoeff(R[2],3-k))~);
	ordermat=concat(ordermat,vector(3,k,polcoeff(R[3],3-k))~);
	matinverseimage(ordermat,vector(3,k,polcoeff(v,3-k))~)
};

\\======================================================================
\\ Routine to compute a good basis of an order. Always assumed the
\\ first element to be 1.

CubicOrderGoodBasis(K,R)=
	{local(coord);
	coord=CubicOrderCoordinates(R,lift(R[2]*R[3]*Mod(1,K.pol)));
	[R[1],R[2]-coord[3],R[3]-coord[2],R[4]]
};

\\======================================================================
\\ The order given is of the form [1,a,b]. Computes ONLY primitives
\\ suborders, using Belabas suggestion.

CubicOrderSuborder(K,Order,p)=
	{local(CF,answer,candidate,COC);
	answer=[];
	Order=CubicOrderGoodBasis(K,Order);
	if(isprime(p),,error("not prime index"));
	CF=CubicOrderForm(K,Order);
	CF=subst(CF,x,x/y)*y^3;
	if(subst(subst(CF,x,0),y,1)%p==0,
	    candidate=[1,p*Order[2],Order[3],Order[4]*p]; 
	    COC=[CubicOrderCoordinates(K.zk,candidate[2])~,CubicOrderCoordinates(K.zk,candidate[3])~];
	    if((COC[1]%p!=[COC[1][1]%p,0,0])||(COC[2]%p!=[COC[2][1]%p,0,0]),answer=concat(answer,[candidate])));
	for(i=0,p-1,if(subst(subst(CF,x,1),y,i)%p==0,
	    candidate=[1,Order[2]+i*Order[3]+i*polcoeffvar(CF,[1,2])+i^2*polcoeffvar(CF,[0,3]),p*Order[3]-i*p*polcoeffvar(CF,[0,3]),Order[4]*p];
	    COC=[CubicOrderCoordinates(K.zk,candidate[2]),CubicOrderCoordinates(K.zk,candidate[3])];
	    if(COC[1]%p!=[COC[1][1]%p,0,0]~||COC[2]%p!=[COC[2][1]%p,0,0]~,answer=concat(answer,[candidate]))));
	answer
};

\\======================================================================
\\ Stupid routine to compute a coef. in a 2 variable polynomial

polcoeffvar(P,vec)=polcoeff(polcoeff(P,vec[1],x),vec[2],y);


\\======================================================================
\\ Routine to compute the quadratic form attached to the cubic one.

CubicFormQuadraticForm(F)=
	{local(a,b,c,d);
	a=polcoeff(F,3);b=polcoeff(F,2);c=polcoeff(F,1);d=polcoeff(F,0);	
	[(b^2-3*a*c),(b*c-9*a*d),(c^2-3*b*d)]
};

\\======================================================================
\\ Stupid routines to deal with vectors.

\\======================================================================
\\ Given a vector, and an index i, removes the i-th coordinate

vectorkill(v,i)=vector(length(v)-1,x,if(x<i,v[x],v[x+1]));

\\======================================================================
\\ Given a vector, answers the first position whether the element
\\ appears. If the element isn't on the vector, answers []

vectorfind(v,elmnt)=
	{for(k=1,length(v),if(v[k]==elmnt,return(k)));
	[]
};



\\======================================================================
\\ Algorithm to compute all curves of a given N. The flag is cero,
\\uses a naive bound for the curves with 2-torsion. If non-cero tries
\\ to use Szpiro's bound (not recommended so far). Second flag to
\\ avoid computing twists (if non-zero).

ComputeCurves(N,flag,flag2)=
	{local(V2T,VC3,VS3,curves2T,curvesC3,curvesS3,Fact,Isogs,aux);
	N=squarefree(N);
	Fact=factor(2*N)[,1]~;
	for(k=1,length(Fact),Fact[k]*=kronecker(-1,Fact[k]));
\\	gettime();	
	curves2T=CurvesWith2Torsion(N,flag,flag2);\\print(1," ",gettime());

	curvesC3=CurvesWithC3Image(N,1);\\print(2," ",gettime());
	curvesC3=ComputeTwists(curvesC3,Fact);
	VC3=curvesC3;
	if(flag2==0,
	    for(k=1,length(curvesC3),Isogs=listisog(curvesC3[k]);
	        VC3=concat(VC3,vector(length(Isogs),i,Isogs[i][3]))));
	VC3=Set(VC3);

	curvesS3=CurvesWithS3Image(N,1);
	curvesS3=ComputeTwists(curvesS3,Fact);
	VS3=curvesS3;
	if(flag2==0,
	    for(k=1,length(curvesS3),Isogs=listisog(curvesS3[k]);
	        VS3=concat(VS3,vector(length(Isogs),i,Isogs[i][3]))));
	VS3=Set(VS3);
	if(N%2!=0,
	    aux=length(curves2T);
	    for(k=1,aux,if(ellglobalred(ellinit(curves2T[aux+1-k]))[1]%2==0,curves2T=vectorkill(curves2T),aux-k+1));
	    aux=length(VC3);
	    for(k=1,aux,if(ellglobalred(ellinit(VC3[aux+1-k]))[1]%2==0,VC3=vectorkill(VC3),aux-k+1));
	    aux=length(VS3);
	    for(k=1,aux,if(ellglobalred(ellinit(VS3[aux+1-k]))[1]%2==0,VS3=vectorkill(VS3,aux-k+1))));


\\	print();
\\	print("Curves with 2-torsion  ",length(curves2T));	
\\	print("Curves without 2-torsion  ",length(VC3)+length(VS3));
	concat(concat(curves2T,VC3),VS3)
};

\\======================================================================
\\ Check if the curves constructed are all of them. If flag =1, test
\\ only the ones without2-torsion, if flag =2, test the 2-torsion
\\ ones.

TestTable(N,Curves,flag)=
	{local(S,aux,Vap,fact,Ninfty,A,Missing);
	if(Curves,Curves=vector(length(Curves),k,ellinit(Curves[k])),Curves=ComputeCurves(N));
	Missing=[]; S=[]; aux=3;
	while(length(S)<30,aux=nextprime(aux+2);
		if(N%aux!=0,S=concat(S,aux)));
	Vap=vector(length(Curves),k,(vector(length(S),j,abs(ellap(Curves[k],S[j])))));
	fact=factor(N);
	Ninfty=prod(j=1,matsize(fact)[1],if(fact[j,1]==2,2^8,if(fact[j,1]==3,3^5,fact[j,1]^2)));	
	fordiv(Ninfty,a,if(a<300000,A=ellsearch(a);
	   for(k=1,length(A),aux=ellinit(A[k][2]);
		if(vectorfind(Vap,vector(length(S),i,abs(ellap(aux,S[i]))))==[],
		    if(flag==0,Missing=concat(Missing,[aux]),
		        if(elltors(aux)[1]%2!=0,if(flag==1,Missing=concat(Missing,[aux])), Missing=concat(Missing,[aux])))))));
			    
	Missing
};

\\======================================================================

IsPrincipalGenus(K,Order,N)=
	{local(Form,Fact,a,c);
	Form=CubicFormQuadraticForm(CubicOrderForm(K,Order));
	Form=Qfb(Form[1],Form[2],Form[3]);
	Fact=factor(abs(N)); a=Vec(Form)[1];c=Vec(Form)[3];
	if(a%2!=0,if(a%8!=1,return(-1)),if(c%2!=0&&c%8!=1,return(-1)));
	for(k=1,matsize(Fact)[1],if(kronecker(a,Fact[k,1])==-1,return(-1)));
	1
};

\\======================================================================
\\ The output in most routines is a cubic polynomial. This script puts
\\ it into a weierstrass equation (and minimal model).


Ell(pol,aux)=aux=ellminimalmodel(ellinit([0,polcoeff(pol,2),0,polcoeff(pol,1),polcoeff(pol,0)]));vector(5,k,aux[k]);


\\======================================================================
\\ Given a vector of elliptic curves, and a vector of discriminants,
\\ computes twists for the given conductors. If twists by -4,8,-8,
\\ first prime element must be 2.

ComputeTwists(V,W)=
	{my(aux,MMC);
	aux=V;
	if(W[1]==2,
	    for(k=1,length(aux),MMC=ellminimalmodel(ellinit(ellquadtwist(aux[k],-4)));
	    aux=concat(aux,[vector(5,j,MMC[j])]));
	    for(k=1,length(aux),MMC=ellminimalmodel(ellinit(ellquadtwist(aux[k],8)));
	    aux=concat(aux,[vector(5,j,MMC[j])]));
	    W=vectorkill(W,1));
	for(k=1,length(W),
	    for(j=1,length(aux),MMC=ellminimalmodel(ellinit(ellquadtwist(aux[j],W[k])));
	    aux=concat(aux,[vector(5,i,MMC[i])])));
	Set(aux)
};

\\======================================================================
\\ This routine computes the coeficients of a quadratic twist of an
\\ elliptic curve.

ellquadtwist(E,D)=
	{if(D%4!=0&&D%4!=1,error("not a discriminant"));
	[E[1]*D,D*(E[2]-E[1]^2/4*(D-1)),E[3]*D^2,D^2*(E[4]-E[1]*E[3]/2*(D-1)),
	D^3*(E[5]-E[3]^2/4*(D-1))]
};

