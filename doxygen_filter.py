#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
from correlation import Graph

correlation_diagram_re = \
    re.compile(r'\\correlationdiagram([\w\W]*?)\\endcorrelationdiagram', re.M)

content = open(sys.argv[1]).read()
result = content

base_name = os.path.splitext(os.path.basename(sys.argv[1]))[0]
index = 0

for entry in correlation_diagram_re.findall(content):
    indent = len(entry.lstrip('\n')) - len(entry.lstrip('\n '))
    file_name = base_name
    if index > 0:
        file_name += '_' + str(index)
    graph = Graph(file_name)
    try:
        exec entry.replace('\n' + ' ' * indent, '\n')
    except Exception, exception:
        sys.stderr.write('Error in %s: %s\n' % (sys.argv[1], str(exception)))
        continue
    html = graph.generate(file_name)

    result = result.replace('\\correlationdiagram' + entry
                            + '\\endcorrelationdiagram', '\htmlonly\n' + html
                            + '\endhtmlonly')
    index += 1

print result
