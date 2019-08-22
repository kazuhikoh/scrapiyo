#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
from bs4 import BeautifulSoup
import hashlib
from itertools import chain

def messages_of(html):
    try:
        bs = BeautifulSoup(html, "html.parser")
        messagebodys = bs.select(".message_body")
        headline = map(lambda it: [
            # path : /USER/ID
            it.select(".time_stamp")[0].a["href"],
            # time : YYYY-MM-DDThh:mm
            it.parent.parent.parent
                .select(".entry_date")[0].p.text[0:10]
                .replace("/", "-") + "T" + it.select(".time_stamp")[0].a.text,
            # message : .message_body without .posted
            clean_message(it)
        ], messagebodys)

        return headline

    except Exception as e:
        sys.stderr.write(e)
        exit(1)

def clean_message(bs):
    bs.find("ul", {"class":"posted"}).extract()
    return str(bs)

def message2lines(path, time, message_body):
    bs = BeautifulSoup(message_body, "html.parser")

    msgs = map(
        lambda it: "message=" + it,
        bs.get_text().strip().split("\n")
    )
    
    imgs = list(chain.from_iterable(
        map(lambda it: [
            "img-src="  + it["dumy"], 
            "img-thumb=" + it["src"],
        ], bs.select("img"))
    ))

    anchors = map(
        lambda it: "anchor=" + it["href"],
        bs.select("a")
    )

    out = [
        "url=" + path,
        "time=" + time,
    ]
    out += msgs
    out += imgs
    out += anchors

    return out

def gen_hash(s):
    return hashlib.md5(s.encode('utf-8')).hexdigest()

def main():
    if __name__ == '__main__': return

    # args
    parser = argparse.ArgumentParser(
        description='''
scrapiyo : piyo scraper
curl http://piyo.fc2.com/user/ | scrapiyo
'''.strip(),
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        '-d', '--digest',
        action='store_true',
        default=False,
        help='show message digest instead of message'
    )
    parser.add_argument(
        '-l', '--latest',
        action='store_true',
        default=False,
        help='show only latest message'
    )
    args = parser.parse_args()

    stdin = sys.stdin.read()

    if args.digest:
        for it in messages_of(stdin):
            out = gen_hash(it[0] + it[1] + it[2])
            print(out)
    elif args.latest:
        it = list(messages_of(stdin))[0]
        for line in message2lines(it[0], it[1], it[2]):
            print(line)
    else:
        for it in messages_of(stdin):
            for line in message2lines(it[0], it[1], it[2]):
                print(line)

