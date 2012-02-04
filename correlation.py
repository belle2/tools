#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import gv


class Graph:
    """
    A class for generating a correlation diagram that illustrates
    the data flow and relations between data objects
    """

    def __init__(self, name=None):
        """
        @type  name: string
        @param name: the name of the graph; default is th base file name
        """

        if not name:
            name = os.path.splitext(os.path.basename(sys.argv[0]))[0]
        self.name = name
        self.file_name = name
        if len(sys.argv) > 1:
            self.file_name = sys.argv[1]
        self.graph = gv.digraph(name)
        gv.setv(self.graph, 'pad', '0.5')
        self.output_lists = []

    def url(self, name):
        """
        @type  name: string
        @param name: the name of the data object
        @return: the url pointing to the doxygen documentation of the class
        """

        return 'http://ekpbelle2.physik.uni-karlsruhe.de' \
               '/internal/software/development/classBelle2_1_1' + \
               name.replace('::', '_1_1') + '.html'

    def data(self, name):
        """
        Creates a node for a data object
        @type  name: string
        @param name: the name of the data object
        @return: the node object
        """

        node = gv.node(self.graph, name)
        gv.setv(node, 'style', 'filled')
        gv.setv(node, 'color', 'gold')
        gv.setv(node, 'shape', 'box')
        gv.setv(node, 'URL', self.url(name))
        return node

    def external_data(self, name):
        """
        Creates a node for a data object belonging to another package
        @type  name: string
        @param name: the name of the external data object.
        @return: the node object
        """

        node = self.data(name)
        gv.setv(node, 'style', 'filled')
        gv.setv(node, 'color', 'grey90')
        return node

    def relation(self, from_data, to_data):
        """
        Creates an edge for a relation between two data objects
        @type  from: node
        @param from: the data object from which the relation points from.
        @type  to: node
        @param to: the data object to which the relation points to.
        @return: the edge object
        """

        edge = gv.edge(from_data, to_data)
        gv.setv(edge, 'style', 'bold,dashed')
        gv.setv(edge, 'color', 'firebrick4')
        for output_data in self.output_lists:
            if from_data in output_data and to_data in output_data:
                return edge
        gv.setv(edge, 'constraint', 'false')
        return edge

    def module(self, name, input_data, output_data):
        """
        Creates a node for a module
        @type  name: string
        @param name: the name of the module.
        @type  input_data: list
        @param input_data: the input data nodes.
        @type  output_data: list
        @param output_data: the output data nodes.
        @return: the node object
        """

        node = gv.node(self.graph, name)
        gv.setv(node, 'style', 'filled')
        gv.setv(node, 'fillcolor', 'lightskyblue')
        gv.setv(node, 'URL', self.url(name + 'Module'))
        for data in input_data:
            edge = gv.edge(data, node)
            gv.setv(edge, 'color', 'blue')
        for data in output_data:
            edge = gv.edge(node, data)
            gv.setv(edge, 'color', 'blue')
        self.output_lists.append(output_data)
        return node

    def write(self, file_name=None):
        """
        Creates an image and an html page for the correation diagram
        @type  file_name: string
        @param file_name: the base file name; default is the graph name
        """

        if not file_name:
            file_name = self.file_name

        gv.layout(self.graph, 'dot')
        gv.render(self.graph, 'png', file_name + '.png')

        html = open(file_name + '.html', 'w')
        html.write('<html>\n<head>\n<title>%s</title>\n</head>\n' % self.name)
        html.write('<body>\n<div align="center">\n')
        html.write('<img src="%s.png" border="0" usemap="#%s"/>\n' %
                   (file_name, self.name))
        html.write(gv.renderdata(self.graph, 'cmapx'))
        html.write('</div></body>\n</html>\n')
        html.close()
