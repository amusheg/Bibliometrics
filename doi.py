import bs4, requests, urllib
import urllib.request as urlreq
import openpyxl
import csv
import tkinter
from tkinter import filedialog
from tkinter import *


while True:
    a=input("Enter a URL or type 'file' to enter a list of URLs as a CSV file: ")
    if a=='file':
        root = Tk()
        root.withdraw()
        root.update()
        root.filename =  filedialog.askopenfilename(initialdir = "/",title = "Select file",filetypes = (("csv files","*.csv"),("all files","*.*")))
        print(root.filename)
        print('Looking up DOIs...')
        outputFile=open('DOIs.csv','w',newline='')
        outputWriter=csv.writer(outputFile)
        with open(root.filename) as f:
            wb = [line.strip() for line in f]
            urls=list(wb)
        for row in urls:
            a=str(row)
            link = urlreq.urlopen(a)
            fullURL = link.url
            res=requests.get(fullURL)
            res.raise_for_status()
            jbcarticle=bs4.BeautifulSoup(res.text, 'html.parser')
            articletitle=jbcarticle.select('title')
            at=articletitle[0].getText().encode('utf-8')
            print(at)
            try:
                doi = jbcarticle.find("meta", {"name":"DC.Identifier"})['content']
            except:
                doi =str('No doi')
            outputWriter.writerow([a,doi,at])
            #urls=urls+[doi]
            #urls=urls+[at]
        print('Written to DOIs.csv')
        outputFile.close()
    else:
        print('Looking up doi...')
        link = urlreq.urlopen(a)
        fullURL = link.url
        res=requests.get(fullURL)
        res.raise_for_status()
        jbcarticle=bs4.BeautifulSoup(res.text, 'html.parser')
        articletitle=jbcarticle.select('title')
        at=articletitle[0].getText()
        try:
            doi = jbcarticle.find("meta", {"name":"DC.Identifier"})['content']
        except:
            doi =str('No doi')
        print(doi)
    



#a1="http://"+a
#link = urlreq.urlopen(a)
#fullURL = link.url
#res=requests.get(fullURL)
#res.raise_for_status()
#jbcarticle=bs4.BeautifulSoup(res.text, 'html.parser')
#articletitle=jbcarticle.select('title')
#at=articletitle[0].getText()
#print(at)

#doi = jbcarticle.find("meta", {"name":"DC.Identifier"})['content']
#print('doi: ' + doi)

