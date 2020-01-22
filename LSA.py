from numpy import zeros
from scipy import spatial
from scipy.linalg import svd
import scipy.misc as m
# following needed for TFIDF
from math import log, sqrt
from numpy import asarray, sum, asscalar


titles = ["The Neatest Little Guide to Stock Market Investing",
          "Investing For Dummies, 4th Edition",
          "The Little Book of Common Sense Investing: The Only Way to Guarantee Your Fair Share of Stock Market Returns",
          "The Little Book of Value Investing",
          "Value Investing: From Graham to Buffett and Beyond",
          "Rich Dad's Guide to Investing: What the Rich Invest in, That the Poor and the Middle Class Do Not!",
          "Investing in Real Estate, 5th Edition",
          "Stock Investing For Dummies",
          "Rich Dad's Advisors: The ABC's of Real Estate Investing: The Secrets of Finding Hidden Profits Most Investors Miss"
          ]
stopwords = ['and', 'edition', 'for', 'in', 'little', 'of', 'the', 'to']
ignorechars = ''',:'!'''


def cosine_similarity(vector1, vector2):
    _len_ = len(vector1)
    # Calculate numerator of cosine similarity
    dot = sum([vector1[i] * vector2[i] for i in range(_len_)])
    print(f'>>>{dot}')
    # Normalize the first vector
    a1 = sqrt(sum([x*x for x in vector1]))
    a2 = sqrt(sum([x*x for x in vector2]))
    print(f"{dot} / {a1}  * {a2}")

    return (dot / (a1*a2))


class LSA(object):
    def __init__(self, stopwords, ignorechars):
        self.stopwords = stopwords
        self.ignorechars = ignorechars
        self.wdict = {}
        self.dcount = 0
        self.docs = []

    def parse(self, doc):
        words = doc.split()
        for w in words:
            w = w.lower().translate(None, self.ignorechars)
            if w in self.stopwords:
                continue
            elif w in self.wdict:
                self.wdict[w].append(self.dcount)
            else:
                self.wdict[w] = [self.dcount]
        self.docs.append(doc)
        self.dcount += 1

    def build(self):
        self.keys = [k for k in self.wdict.keys() if len(self.wdict[k]) > 1]
        self.keys.sort()
        self.A = zeros([len(self.keys), self.dcount])
        for i, k in enumerate(self.keys):
            for d in self.wdict[k]:
                self.A[i, d] += 1

    def calc(self):
        self.U, self.S, self.Vt = svd(self.A)

    def TFIDF(self):
        WordsPerDoc = sum(self.A, axis=0)
        DocsPerWord = sum(asarray(self.A > 0, 'i'), axis=1)
        rows, cols = self.A.shape
        for i in range(rows):
            for j in range(cols):
                self.A[i, j] = (self.A[i, j] / WordsPerDoc[j]) * log(float(cols) / DocsPerWord[i])

    def printA(self):
        print('Here is the count matrix')
        print(self.A)

    def printSVD(self):
        print('Here are the singular values')
        print(self.S)
        print('Here are the first 3 columns of the U matrix')
        print(-1*self.U[:, :])
        print('Here are the first 3 rows of the Vt matrix')
        print(-1*self.Vt[:, :])

    def toImage(self):
        m.toimage(self.Vt).show()

    def computeSimilarity(self, method='cosine'):

        print('-------')

        i = 2
        j = 3

        ai = [asscalar(x) for x in self.Vt[i]]
        aj = [asscalar(x) for x in self.Vt[j]]
        print()
        print(self.docs[i])
        print(ai)
        print(self.docs[j])
        print(aj)
        cos = spatial.distance.jaccard(ai, aj)
        print(f"{i} --> {j} : {cos}")
        cos = cosine_similarity(ai, aj)
        print(f"{i} --> {j} : {cos}")
        # for i in range(len(self.Vt)):
        #     for j in range(len(self.Vt)):
        #         print
        #         print self.docs[i]
        #         print self.Vt[i]
        #         print self.docs[j]
        #         print self.Vt[j]
        #         cos = spatial.distance.jaccard(self.Vt[i], self.Vt[j])
        #         print '%d --> %d : %f' % (i,j,cos)


# mylsa = LSA(stopwords, ignorechars)
# for t in titles:
#     mylsa.parse(t)
# mylsa.build()
# mylsa.printA()
# mylsa.calc()
# mylsa.printSVD()
