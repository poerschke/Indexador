#!/usr/bin/env python

import requests
import re
import sys
import mysql.connector
import signal
from bs4 import BeautifulSoup

url = sys.argv[1]
signal.alarm(90)

def getURL(page):
    start_link = page.find("a href")
    if start_link == -1:
        return None, 0
    start_quote = page.find('"', start_link)
    end_quote = page.find('"', start_quote + 1)
    url = page[start_quote + 1: end_quote]
    return url, end_quote


links = []
externos = []

try:
    response = requests.get('http://'+url)
    page = str(BeautifulSoup(response.content, "lxml"))
    while True:
        url2, n = getURL(page)
        page = page[n:]
        if url2:
            if re.match('^//', url2) is not None:
                url2 = 'http:' + url2
                if re.match(url, url2) is not None:
                    links.append(url2)
                else:
                    externos.append(url2)
            elif re.match('^/', url2) is not None:
                url2 = url + url2
                if re.match(url, url2) is not None:
                    links.append('http://'+url2)
                else:
                    externos.append(url2)
            elif re.match('^https?://', url2) is not None:
                if re.match(url, url2) is not None:
                    links.append('http://'+url2)
                else:
                    externos.append(url2)
        else:
            break
except:
    None

x=0

for link in links:
    x = x+1
    if x == 15:
        break
    try:
        response = requests.get(link)
        page = str(BeautifulSoup(response.content, "lxml"))
        while True:
            url2, n = getURL(page)
            page = page[n:]
            if url2:
                if re.match('^//', url2) is not None:
                    url2 = 'http' + url2
                    if re.match(url, url2) is None:
                        externos.append(url2)
                elif re.match('^/', url2) is not None:
                    url2 = url + url2
                    if re.match(url, url2) is None:
                        externos.append(url2)
                elif re.match('^https?://', url2) is not None:
                    if re.match(url, url2) is None:
                        externos.append(url2)
            else:
                break
    except:
        None


hosts = []

for ext in externos:
    re.sub('https?://', '', ext)
    try:
        found = re.search('https?://(.+?)/', ext).group(1)
    except AttributeError:
        found = ''
    if found not in hosts:
        hosts.append(found)



mydb = mysql.connector.connect(
  host="localhost",
  user="user",
  passwd="pass",
  database="sites"
)

for site in hosts:
    try:
        if re.match('.+blogspot.+', site) is None and re.match('.+wordpress.+', site) is None:
            mycursor = mydb.cursor()
            sql = "INSERT INTO site (url) VALUES ('"+site+"')"
            mycursor.execute(sql)
            mydb.commit()
            print("[+] Novo site no banco: "+ site)
    except:
        None
