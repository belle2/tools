'''
Just a simple steering file for testing if b2execute works.
'''

import basf2


main = basf2.Path()
main.add_module('EventInfoSetter')
main.add_module('Progress')
basf2.process(main)
print(basf2.statistics)
