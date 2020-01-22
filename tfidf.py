
import re
from nltk.tokenize import RegexpTokenizer
from nltk import bigrams, trigrams
import math


class TfIdf:

    tokenizer = RegexpTokenizer("[\w’]+", flags=re.UNICODE)

    def __init__(self, stopwords=[]):
        self.stopwords = stopwords
        self.vocabulary = []
        self.docs = {}
        self.all_tips = []

    def freq(self, word, doc):
        return doc.count(word)

    def word_count(self, doc):
        return len(doc)

    def tf(self, word, doc):
        return (self.freq(word, doc) / float(self.word_count(doc)))

    def num_docs_containing(self, word, list_of_docs):
        count = 0
        for document in list_of_docs:
            if self.freq(word, document) > 0:
                count += 1
        return 1 + count

    def idf(self, word, list_of_docs):
        return math.log(len(list_of_docs) / float(self.num_docs_containing(word, list_of_docs)))

    def tf_idf(self, word, doc, list_of_docs):
        return (self.tf(word, doc) * self.idf(word, list_of_docs))

    def parse(self, sourceDocs=[]):
        for doc in sourceDocs:
            tokens = self.tokenizer.tokenize(doc)

            bi_tokens = bigrams(tokens)
            tri_tokens = trigrams(tokens)

            tokens = [token.lower() for token in tokens if len(token) > 2]
            tokens = [token for token in tokens if token not in self.stopwords]

            final_tokens = []
            final_tokens.extend(tokens)
            final_tokens.extend(bi_tokens)
            final_tokens.extend(tri_tokens)
            self.docs[doc] = {'freq': {}, 'tf': {}, 'idf': {}, 'tf-idf': {}, 'tokens': []}

            for token in final_tokens:
                # The frequency computed for each tip
                self.docs[doc]['freq'][token] = self.freq(token, final_tokens)
                # The term-frequency (Normalized Frequency)
                self.docs[doc]['tf'][token] = self.tf(token, final_tokens)
                self.docs[doc]['tokens'] = final_tokens

            self.vocabulary.append(final_tokens)
        for doc in self.docs:
            for token in self.docs[doc]['tf']:
                # The Inverse-Document-Frequency
                self.docs[doc]['idf'][token] = self.idf(token, self.vocabulary)
                # The tf-idf
                self.docs[doc]['tf-idf'][token] = self.tf_idf(token, self.docs[doc]['tokens'], self.vocabulary)

        # Now let's find out the most relevant words by tf-idf.
        words = {}
        for doc in self.docs:
            for token in self.docs[doc]['tf-idf']:
                if token not in words:
                    words[token] = self.docs[doc]['tf-idf'][token]
                else:
                    if self.docs[doc]['tf-idf'][token] > words[token]:
                        words[token] = self.docs[doc]['tf-idf'][token]

        x = 0
        for item in sorted(words.items(), key=lambda x: x[1], reverse=True):
            print(f"{item[1]} <= {item[0]}")
            x += 1
            if x % 50 == 0:
                break
