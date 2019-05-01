from collections import defaultdict
import sys
import csv


countLines = defaultdict(lambda: 0)
lineNumber = 0
with open(sys.argv[1], 'rb') as csvfile:
	spamreader = csv.reader(csvfile, delimiter='\t', quotechar='"')

	for row in spamreader:
		count = len(row)
		countLines[count] += 1
		lineNumber+= 1
		if count != 50:
			print (lineNumber, row)

for countComma in sorted(countLines.keys()):
	print( countComma, countLines[countComma] )
        