#!/usr/bin/env python
import sys
from collections import namedtuple 

" This script generates load for the worker to d'load the content
  Usage : generate_work.py <from #> <to #> <window size>
  example : generate_work.py 444444 555555 100
"

def computeFactor(u_obj):
    
    __diff=  u_obj.last - u_obj.first
    __chunk= __diff / u_obj.factor
    #print "Chunk size = %d :: Diff size = %d "%(__chunk,__diff)
    __to = u_obj.first
    __from = u_obj.first
    while ( __from < u_obj.last) :
        __to = __from 
        __from = __to + u_obj.factor
        print "${WORKER} %d %d &"%(__to,__from)

def main():
    f_ = int(sys.argv[1])
    s_ = int(sys.argv[2])
    fact_ =  int(sys.argv[3])
    lst = [] 
    lst.extend( ( min(f_,s_),max(f_,s_),fact_) )
    u_para = ('first','last','factor')
    u_rule = namedtuple('u_rul',u_para )

    u_obj = u_rule._make(lst)
    computeFactor(u_obj)

if __name__ == "__main__":
    main()
